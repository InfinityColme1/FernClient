"""Proceso hijo con el que FeRN entrena y reconoce.

Habla por stdin y stdout con una linea de JSON por mensaje. No abre puertos ni
escribe en ningun sitio que no le digan: todo lo que necesita saber llega en los
parametros de cada peticion.

Formato:

    peticion   {"id": "a1", "method": "predict", "params": {...}}
    respuesta  {"id": "a1", "ok": true, "result": {...}}
    error      {"id": "a1", "ok": false, "error": {"code": "...", "message": "..."}}
    progreso   {"id": "a1", "event": "progress", "data": {...}}

El fichero se escribe en ASCII a proposito: acaba en disco por la ruta que elija
el usuario y no hay forma de saber con que codificacion lo va a leer Python en
un equipo cualquiera.
"""

import json
import os
import sys
import time
import traceback

SIDECAR_VERSION = "1"

# Lo que se esta ejecutando ahora mismo, para poder cancelarlo desde otra
# peticion. Ultralytics no acepta una senal de fuera, asi que lo que se hace es
# levantar una bandera que los callbacks miran entre epoca y epoca.
_cancelled = set()

# Modelos ya cargados, por ruta de pesos. Recorrer el arbol de modelos carga
# varios seguidos y volver a leerlos del disco cada vez cuesta segundos.
_models = {}
_MAX_CACHED_MODELS = 3


def _send(payload):
    sys.stdout.write(json.dumps(payload) + "\n")
    sys.stdout.flush()


def _ok(request_id, result):
    _send({"id": request_id, "ok": True, "result": result})


def _error(request_id, code, message):
    _send({
        "id": request_id,
        "ok": False,
        "error": {"code": code, "message": message},
    })


def _progress(request_id, data):
    _send({"id": request_id, "event": "progress", "data": data})


class SidecarError(Exception):
    """Un fallo que la interfaz sabe contar de una forma concreta."""

    def __init__(self, code, message):
        super(SidecarError, self).__init__(message)
        self.code = code
        self.message = message


def _load_model(weights):
    if not weights or not os.path.exists(weights):
        raise SidecarError("MODEL_NOT_FOUND", "No weights at %s" % weights)

    cached = _models.get(weights)
    if cached is not None:
        return cached

    from ultralytics import YOLO

    model = YOLO(weights)

    if len(_models) >= _MAX_CACHED_MODELS:
        _models.pop(next(iter(_models)))
    _models[weights] = model

    return model


def handle_ping(request_id, params):
    return {"pong": True, "version": SIDECAR_VERSION}


def handle_env_info(request_id, params):
    import platform

    info = {
        "python": platform.python_version(),
        "platform": sys.platform,
        "machine": platform.machine(),
        "sidecar": SIDECAR_VERSION,
    }

    try:
        import torch

        info["torch"] = torch.__version__

        if torch.cuda.is_available():
            info["device"] = "cuda:0"
            info["device_name"] = torch.cuda.get_device_name(0)
            info["vram_mb"] = int(
                torch.cuda.get_device_properties(0).total_memory / (1024 * 1024)
            )
        elif getattr(torch.backends, "mps", None) is not None and \
                torch.backends.mps.is_available():
            # En los Mac con Apple Silicon la aceleracion viene de serie con la
            # rueda normal: no hay descarga extra que ofrecer.
            info["device"] = "mps"
            info["device_name"] = "Apple Silicon"
        else:
            info["device"] = "cpu"
            info["device_name"] = platform.processor() or "CPU"
    except Exception as error:
        info["torch_error"] = str(error)

    try:
        import ultralytics

        info["ultralytics"] = ultralytics.__version__
    except Exception as error:
        info["ultralytics_error"] = str(error)

    return info


def handle_train(request_id, params):
    dataset = params.get("dataset")
    if not dataset or not os.path.exists(dataset):
        raise SidecarError("DATASET_INVALID", "No data.yaml at %s" % dataset)

    from ultralytics import YOLO

    started = time.time()
    model = YOLO(params.get("backbone", "yolo11n.pt"))
    epochs = int(params.get("epochs", 100))

    def on_epoch_end(trainer):
        if request_id in _cancelled:
            # Es la unica forma de parar por dentro: ultralytics comprueba esto
            # al cerrar cada epoca y sale del bucle.
            trainer.stop_training = True
            return

        metrics = getattr(trainer, "metrics", None) or {}
        losses = getattr(trainer, "label_loss_items", None)
        data = {
            "epoch": int(getattr(trainer, "epoch", 0)) + 1,
            "epochs": epochs,
            "map50": float(metrics.get("metrics/mAP50(B)", 0.0) or 0.0),
            "map50_95": float(metrics.get("metrics/mAP50-95(B)", 0.0) or 0.0),
        }

        if callable(losses):
            try:
                for key, value in losses(trainer.tloss).items():
                    data[key.replace("train/", "")] = float(value)
            except Exception:
                pass

        _progress(request_id, data)

    model.add_callback("on_train_epoch_end", on_epoch_end)

    try:
        results = model.train(
            data=dataset,
            epochs=epochs,
            imgsz=int(params.get("imgsz", 640)),
            batch=params.get("batch", -1),
            device=params.get("device", "cpu"),
            project=params.get("project"),
            name=params.get("name"),
            workers=int(params.get("workers", 0)),
            patience=int(params.get("patience", 20)),
            exist_ok=True,
            plots=True,
            verbose=False,
            **(params.get("augment") or {})
        )
    except RuntimeError as error:
        message = str(error).lower()
        if "out of memory" in message or "cuda" in message:
            raise SidecarError("OUT_OF_MEMORY", str(error))
        raise

    if request_id in _cancelled:
        raise SidecarError("CANCELLED", "Training cancelled")

    save_dir = str(getattr(results, "save_dir", params.get("project") or ""))
    weights = os.path.join(save_dir, "weights", "best.pt")

    metrics = {}
    box = getattr(getattr(results, "box", None), "__dict__", None)
    if box is not None:
        for source, target in (
            ("map50", "map50"),
            ("map", "map50_95"),
            ("mp", "precision"),
            ("mr", "recall"),
        ):
            value = getattr(results.box, source, None)
            if value is not None:
                metrics[target] = float(value)

    # Por clase, que es lo que dice **cual** de los fernies ha salido mal. La
    # media general puede ser buena con una clase que no reconoce nada.
    per_class = {}
    names = getattr(results, "names", None) or {}
    maps = getattr(getattr(results, "box", None), "maps", None)

    if maps is not None:
        for index, value in enumerate(maps):
            name = names.get(index) if hasattr(names, "get") else None
            per_class[str(name if name is not None else index)] = float(value)

    metrics["per_class"] = per_class
    metrics["curves_dir"] = save_dir
    metrics["elapsed_seconds"] = int(time.time() - started)

    return {"weights": weights, "metrics": metrics}


def handle_inspect(request_id, params):
    """Que sabe reconocer un fichero de pesos.

    Hace falta para los pesos traidos de fuera: sin saber que clases trae, la
    aplicacion no puede emparejarlas con fernies y el modelo no sirve de nada.
    """
    weights = params.get("weights")
    if not weights or not os.path.exists(weights):
        raise SidecarError("MODEL_NOT_FOUND", "No weights at %s" % weights)

    from ultralytics import YOLO

    try:
        model = YOLO(weights)
    except Exception as error:
        raise SidecarError("MODEL_INVALID", str(error))

    names = getattr(model, "names", None) or {}
    if hasattr(names, "items"):
        classes = [str(name) for _, name in sorted(names.items())]
    else:
        classes = [str(name) for name in names]

    return {
        "classes": classes,
        "task": str(getattr(model, "task", "") or ""),
    }


def _detections_of(result, conf):
    detections = []
    boxes = getattr(result, "boxes", None)
    if boxes is None:
        return detections

    for box in boxes:
        confidence = float(box.conf[0])
        if confidence < conf:
            continue

        # xywhn: centro y tamano ya normalizados, que es el formato con el que
        # trabaja FeRN al guardar las regiones.
        x, y, w, h = [float(value) for value in box.xywhn[0]]
        detections.append({
            "class": int(box.cls[0]),
            "conf": confidence,
            "box": [x, y, w, h],
        })

    return detections


def handle_predict(request_id, params):
    images = params.get("images") or []
    if not images:
        return {"results": []}

    conf = float(params.get("conf", 0.35))
    model = _load_model(params.get("weights"))
    imgsz = int(params.get("imgsz", 640))

    results = []
    total = len(images)

    for index, image in enumerate(images):
        if request_id in _cancelled:
            raise SidecarError("CANCELLED", "Prediction cancelled")

        if not os.path.exists(image):
            # Un fichero que ya no esta no puede tumbar el lote entero: se anota
            # y se sigue con el resto.
            results.append({"image": image, "detections": [], "missing": True})
            continue

        prediction = model.predict(
            image,
            conf=conf,
            imgsz=imgsz,
            verbose=False,
        )[0]

        results.append({
            "image": image,
            "detections": _detections_of(prediction, conf),
        })

        if total > 1:
            _progress(request_id, {"done": index + 1, "total": total})

    return {"results": results}


def handle_export(request_id, params):
    model = _load_model(params.get("weights"))
    path = model.export(format=params.get("format", "onnx"))

    return {"path": str(path)}


def handle_cancel(request_id, params):
    target = params.get("target")
    if target:
        _cancelled.add(target)

    return {"cancelled": True}


HANDLERS = {
    "ping": handle_ping,
    "env_info": handle_env_info,
    "train": handle_train,
    "predict": handle_predict,
    "predict_batch": handle_predict,
    "inspect": handle_inspect,
    "export": handle_export,
    "cancel": handle_cancel,
}


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
        except ValueError as error:
            _error("", "INTERNAL", "Bad request: %s" % error)
            continue

        request_id = request.get("id", "")
        method = request.get("method", "")
        params = request.get("params") or {}

        if method == "shutdown":
            _ok(request_id, {"bye": True})
            return

        handler = HANDLERS.get(method)
        if handler is None:
            _error(request_id, "INTERNAL", "Unknown method: %s" % method)
            continue

        try:
            _ok(request_id, handler(request_id, params))
        except SidecarError as error:
            _error(request_id, error.code, error.message)
        except MemoryError:
            _error(request_id, "OUT_OF_MEMORY", "Not enough memory")
        except Exception:
            _error(request_id, "INTERNAL", traceback.format_exc())
        finally:
            _cancelled.discard(request_id)


if __name__ == "__main__":
    main()
