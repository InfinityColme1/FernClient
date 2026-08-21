# -*- coding: utf-8 -*-
"""Genera material de prueba ya etiquetado para FeRN.

Tres «fernies» sinteticos —tres figuras muy distintas entre si— repartidos por
imagenes y videos cortos, con las cajas exactas anotadas en un `labels.json`.

Por que sinteticos y no fotos: porque las cajas se saben **al pixel** sin que
nadie las marque a mano, y porque el modelo tiene que poder aprenderlos en dos
minutos de CPU. Cada figura lleva su forma, su color y su marca interior, de modo
que ni el color solo ni la forma sola bastan: eso evita que el modelo acierte por
casualidad y que las metricas mientan.

Los fondos son distintos en cada imagen a proposito. Con fondos repetidos el
modelo aprende **el fondo** en vez del objeto, que es justo el fallo del que
avisa la pantalla de modelos y que no se ve en las metricas.

Se ejecuta con el Python del propio entorno de reconocimiento, que ya trae
numpy, PIL y OpenCV:

    <Fern>/recognition/runtime/venv/Scripts/python.exe tool/test_env/generate_media.py --out <carpeta>
"""

import argparse
import json
import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw

# El material se genera siempre igual: repetirlo tiene que dar lo mismo para
# poder comparar dos entrenamientos.
SEED = 20260821

IMAGE_SIZE = (640, 480)
VIDEO_SIZE = (320, 240)
VIDEO_FPS = 12
VIDEO_SECONDS = 4

# Cada cuantos fotogramas se anota uno. Anotarlos todos multiplica el dataset por
# doce sin ensenar nada nuevo: los fotogramas seguidos son casi identicos.
VIDEO_LABEL_EVERY = 6

FERNIES = [
    {
        'name': 'Rombo',
        'shape': 'diamond',
        'color': (214, 69, 89),
        'mark': (255, 244, 214),
    },
    {
        'name': 'Cubo',
        'shape': 'square',
        'color': (58, 110, 196),
        'mark': (233, 240, 255),
    },
    {
        'name': 'Trebol',
        'shape': 'triangle',
        'color': (66, 156, 92),
        'mark': (238, 255, 236),
    },
]


def background(size, rng):
    """Un fondo distinto cada vez: degradado al azar mas grano."""
    width, height = size

    top = np.array([rng.randint(40, 230) for _ in range(3)], dtype=np.float32)
    bottom = np.array([rng.randint(40, 230) for _ in range(3)], dtype=np.float32)

    ramp = np.linspace(0.0, 1.0, height, dtype=np.float32)[:, None, None]
    canvas = top[None, None, :] * (1 - ramp) + bottom[None, None, :] * ramp
    canvas = np.repeat(canvas, width, axis=1)

    grain = np.random.default_rng(rng.randint(0, 2 ** 31)).normal(
        0.0, 9.0, canvas.shape,
    )

    return Image.fromarray(np.clip(canvas + grain, 0, 255).astype(np.uint8))


def draw_fernie(image, fernie, box, angle):
    """Pinta una figura dentro de [box] y devuelve la caja que ocupa de verdad."""
    left, top, right, bottom = box
    width = right - left
    height = bottom - top

    # Se pinta en su propia capa y se gira: girar la capa entera evita tener que
    # calcular a mano donde cae cada vertice.
    layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    pen = ImageDraw.Draw(layer)

    color = fernie['color'] + (255,)
    mark = fernie['mark'] + (255,)
    shape = fernie['shape']

    if shape == 'square':
        pen.rounded_rectangle(
            [4, 4, width - 5, height - 5], radius=width // 8, fill=color,
        )
        # Dos ojos y una boca: le dan detalle interior, que es lo que hace que la
        # figura no se confunda con un rectangulo cualquiera del fondo.
        pen.ellipse([width * 0.26, height * 0.30,
                     width * 0.40, height * 0.46], fill=mark)
        pen.ellipse([width * 0.60, height * 0.30,
                     width * 0.74, height * 0.46], fill=mark)
        pen.rectangle([width * 0.30, height * 0.64,
                       width * 0.70, height * 0.72], fill=mark)
    elif shape == 'diamond':
        pen.polygon(
            [(width / 2, 2), (width - 3, height / 2),
             (width / 2, height - 3), (2, height / 2)],
            fill=color,
        )
        pen.ellipse([width * 0.36, height * 0.36,
                     width * 0.64, height * 0.64], fill=mark)
        pen.line([(width * 0.5, height * 0.14), (width * 0.5, height * 0.30)],
                 fill=mark, width=max(2, width // 16))
    else:
        pen.polygon(
            [(width / 2, 2), (width - 3, height - 3), (2, height - 3)],
            fill=color,
        )
        pen.rectangle([width * 0.42, height * 0.42,
                       width * 0.58, height * 0.92], fill=mark)
        pen.ellipse([width * 0.34, height * 0.24,
                     width * 0.66, height * 0.44], fill=mark)

    rotated = layer.rotate(angle, expand=True, resample=Image.BICUBIC)

    # Girar agranda la capa: la figura se recentra sobre la caja pedida y la caja
    # real es la de la capa girada, que es la que hay que anotar.
    offset_x = left - (rotated.width - width) // 2
    offset_y = top - (rotated.height - height) // 2

    image.paste(rotated, (offset_x, offset_y), rotated)

    return (
        max(0, offset_x),
        max(0, offset_y),
        min(image.width, offset_x + rotated.width),
        min(image.height, offset_y + rotated.height),
    )


def normalise(box, size):
    """De pixeles a la esquina y el tamano en tanto por uno, como los guarda FeRN."""
    left, top, right, bottom = box
    width, height = size

    return {
        'x': round(left / width, 6),
        'y': round(top / height, 6),
        'w': round((right - left) / width, 6),
        'h': round((bottom - top) / height, 6),
    }


def place(rng, size, count):
    """Cajas que no se pisan, para que dos figuras no se tapen la una a la otra."""
    width, height = size
    boxes = []

    for _ in range(count):
        for _attempt in range(60):
            side = rng.randint(int(height * 0.22), int(height * 0.45))
            left = rng.randint(0, width - side - 1)
            top = rng.randint(0, height - side - 1)
            candidate = (left, top, left + side, top + side)

            overlaps = any(
                candidate[0] < other[2] and other[0] < candidate[2] and
                candidate[1] < other[3] and other[1] < candidate[3]
                for other in boxes
            )

            if not overlaps:
                boxes.append(candidate)
                break

    return boxes


def make_images(out, rng, count):
    folder = os.path.join(out, 'imagenes')
    os.makedirs(folder, exist_ok=True)

    entries = []

    for index in range(count):
        image = background(IMAGE_SIZE, rng)

        # Una de cada tres lleva dos figuras: hace falta para que el modelo
        # aprenda a distinguirlas y no solo a decir «hay algo».
        how_many = 2 if index % 3 == 0 else 1
        chosen = rng.sample(range(len(FERNIES)), how_many)
        boxes = place(rng, IMAGE_SIZE, how_many)

        regions = []

        for fernie_index, box in zip(chosen, boxes):
            drawn = draw_fernie(
                image, FERNIES[fernie_index], box, rng.uniform(-25, 25),
            )
            regions.append({
                'fernie': FERNIES[fernie_index]['name'],
                **normalise(drawn, IMAGE_SIZE),
            })

        if not regions:
            continue

        # En JPEG y no en PNG: el grano del fondo hace que un PNG de 640x480
        # pese medio mega, y cien imagenes de prueba no tienen por que ocupar
        # cincuenta.
        name = 'img-%03d.jpg' % index
        image.convert('RGB').save(
            os.path.join(folder, name), quality=88, optimize=True,
        )

        entries.append({
            'path': os.path.join(folder, name),
            'kind': 'image',
            'regions': regions,
        })

    return entries


def make_videos(out, rng, per_fernie):
    import cv2

    folder = os.path.join(out, 'videos')
    os.makedirs(folder, exist_ok=True)

    entries = []
    total_frames = VIDEO_FPS * VIDEO_SECONDS

    for fernie in FERNIES:
        for take in range(per_fernie):
            name = '%s-%d.mp4' % (fernie['name'].lower(), take)
            path = os.path.join(folder, name)

            writer = cv2.VideoWriter(
                path,
                cv2.VideoWriter_fourcc(*'mp4v'),
                VIDEO_FPS,
                VIDEO_SIZE,
            )

            base = background(VIDEO_SIZE, rng)
            side = rng.randint(60, 90)
            start_x = rng.randint(0, VIDEO_SIZE[0] - side - 1)
            start_y = rng.randint(0, VIDEO_SIZE[1] - side - 1)
            drift_x = rng.uniform(-2.4, 2.4)
            drift_y = rng.uniform(-1.6, 1.6)

            regions = []

            for frame in range(total_frames):
                canvas = base.copy()

                left = int(min(max(0, start_x + drift_x * frame),
                               VIDEO_SIZE[0] - side - 1))
                top = int(min(max(0, start_y + drift_y * frame),
                              VIDEO_SIZE[1] - side - 1))

                drawn = draw_fernie(
                    canvas,
                    fernie,
                    (left, top, left + side, top + side),
                    math.sin(frame / 4.0) * 18,
                )

                if frame % VIDEO_LABEL_EVERY == 0:
                    regions.append({
                        'fernie': fernie['name'],
                        # El milisegundo del **principio** del fotograma, que es
                        # con lo que FeRN los identifica.
                        'frameMs': int(round(frame * 1000.0 / VIDEO_FPS)),
                        **normalise(drawn, VIDEO_SIZE),
                    })

                writer.write(
                    cv2.cvtColor(np.array(canvas.convert('RGB')),
                                 cv2.COLOR_RGB2BGR)
                )

            writer.release()

            entries.append({
                'path': path,
                'kind': 'video',
                'regions': regions,
            })

    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, help='Carpeta de salida.')
    parser.add_argument('--images', type=int, default=96)
    parser.add_argument('--videos-per-fernie', type=int, default=2)
    args = parser.parse_args()

    rng = random.Random(SEED)
    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)

    entries = make_images(out, rng, args.images)
    entries += make_videos(out, rng, args.videos_per_fernie)

    counts = {}
    for entry in entries:
        for region in entry['regions']:
            counts[region['fernie']] = counts.get(region['fernie'], 0) + 1

    manifest = {
        'fernies': [fernie['name'] for fernie in FERNIES],
        'media': entries,
    }

    with open(os.path.join(out, 'labels.json'), 'w', encoding='utf-8') as file:
        json.dump(manifest, file, ensure_ascii=False, indent=1)

    print('Generado en', out)
    print('  contenidos:', len(entries))

    for name, count in sorted(counts.items()):
        print('  %-8s %d regiones' % (name, count))


if __name__ == '__main__':
    main()
