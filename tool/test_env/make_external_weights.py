# -*- coding: utf-8 -*-
"""Deja un `.pt` de fuera con el que probar la importacion de pesos.

No entrena nada: baja el `yolo11n.pt` de ultralytics y lo deja con otro nombre en
una carpeta aparte. Para lo que se prueba —que FeRN lea que clases trae, lo copie
dentro y marque el modelo como «pesos importados»— unos pesos de verdad
cualesquiera valen, y estos ademas no cuestan minutos de maquina.

Trae las ochenta clases de COCO («person», «dog», «car»...). Eso es **lo
esperado** y es parte de lo que hay que ver: FeRN las enseña tal cual al importar,
porque emparejarlas con los fernies de uno es cosa del usuario.

Para probarlo con unos pesos que si conozcan a los fernies, entrena una vez desde
la aplicacion y usa el `best.pt` que queda en la carpeta de la run: se importa
igual y la pantalla lo trata como venido de fuera, que es lo que es.

    <Fern>/recognition/runtime/venv/Scripts/python.exe tool/test_env/make_external_weights.py --out <carpeta>
"""

import argparse
import os
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, help='Carpeta de salida.')
    parser.add_argument(
        '--name',
        default='modelo-entrenado-fuera.pt',
        help='Con que nombre se deja.',
    )
    args = parser.parse_args()

    from ultralytics import YOLO

    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)

    # Ultralytics descarga en el directorio actual, y ese es la raiz del
    # proyecto: sin cambiarse antes, el .pt acaba dentro del repositorio.
    os.chdir(out)

    # Construir el modelo es lo que dispara la descarga, si no estaba ya.
    model = YOLO('yolo11n.pt')
    source = str(model.ckpt_path)

    destination = os.path.join(out, args.name)
    shutil.copyfile(source, destination)

    classes = list(model.names.values())

    print('Pesos de prueba en', destination)
    print('  clases:', len(classes))
    print('  las primeras:', ', '.join(classes[:6]))


if __name__ == '__main__':
    main()
