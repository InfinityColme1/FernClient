# Entorno de pruebas de FeRN 2.0

Material ya etiquetado y una base de datos sembrada, para poder probar a mano todo
lo que hay hasta ahora —fernies, regiones, modelos, entrenamiento, métricas e
importación de pesos— sin marcar una sola región con el ratón.

## Antes de empezar

Hace falta el **motor de reconocimiento instalado** (Ajustes → Reconocimiento).
Los scripts usan su Python, que ya trae numpy, PIL, OpenCV y ultralytics: así no
hay que instalar nada aparte.

## El comando

```powershell
.\tool\test_env\prepare.ps1
```

Deja el material en `Documentos\Fern\pruebas`, unos pesos de fuera en
`Documentos\Fern\pruebas\pesos-externos`, y siembra la base de datos con todo
ello y un modelo listo para entrenar.

> **FeRN tiene que estar cerrado** mientras se siembra. Isar no deja que dos
> procesos escriban a la vez.

Se puede repetir cuantas veces haga falta: cada siembra limpia antes la anterior,
y sólo lo que cuelgue de esa carpeta. La biblioteca de verdad no se toca.

## Qué hay dentro

Tres «fernies» sintéticos —**Rombo**, **Cubo** y **Trebol**— repartidos por 96
imágenes y 6 vídeos de cuatro segundos. Unas 175 regiones, unas 58 por fernie:
por encima del listón de «pocas regiones» y con contenidos de sobra, así que el
modelo se entrena sin avisos.

Son figuras y no fotos por dos razones. Las cajas se saben **al píxel** sin que
nadie las marque a mano, y el modelo puede aprenderlas en unos minutos de
procesador, que es lo que hace que probar el entrenamiento entero sea cuestión de
un café y no de una tarde.

Cada figura tiene forma, color y marca interior distintas, y los fondos cambian en
cada imagen. Eso último no es adorno: con fondos repetidos el modelo aprende **el
fondo** en vez del objeto, y eso no se ve en las métricas —salen bien— hasta que
se usa de verdad.

En los vídeos se anota un fotograma de cada seis. Anotarlos todos multiplicaría el
dataset por doce sin enseñar nada nuevo, porque los fotogramas seguidos son casi
idénticos.

## Los tres caminos que probar

### 1. El corto: de cero a entrenando en un minuto

Tras `prepare.ps1`, abre FeRN → **Modelos** → **Figuras de prueba**.

Ahí se ve la pantalla de detalle con los tres fernies asignados, sus barras de
reparto y el panel de entrenamiento. Pulsa **Entrenar modelo**.

Vale la pena mirar, en este orden:

- Que el botón **no** deja entrenar si le quitas dos fernies (con uno solo el
  modelo pasa a booleano y avisa).
- Cómo cambia el panel al arrancar: primero «Preparando el material...» mientras
  monta el dataset —con los vídeos tarda, porque hay que sacar cada fotograma con
  el reproductor—, y luego la época y la barra.
- **Cancelar** a media faena: el modelo tiene que quedarse como estaba, sin error
  apuntado, y la carpeta temporal del dataset tiene que desaparecer.
- Al terminar, el bloque de abajo: las cuatro métricas con sus barras, el acierto
  por fernie, y los botones de **matriz de confusión**, **curvas** y **abrir
  carpeta de la run**.
- El aviso del menú lateral: entrenar termina con notificación, y entrar en
  Modelos la da por vista.

Con el preset **Rápido** son unos pocos minutos en procesador. Con **Esmerado**,
un buen rato: bueno para dejarlo corriendo y comprobar que se puede seguir usando
la aplicación mientras tanto.

### 2. El largo: importar y etiquetar a mano

```powershell
.\tool\test_env\prepare.ps1 -SkipSeed
```

Genera los ficheros y no toca la base de datos. Desde FeRN:

1. **Importar** → la carpeta `pruebas\imagenes` y `pruebas\videos`.
2. Crear los tres fernies desde el «+».
3. Abrir un contenido, entrar en **modo fernie** y marcar unas cuantas regiones.
   En un vídeo, ver cómo las muescas de la línea de tiempo se comportan como
   fotogramas clave: la región sólo se ve donde está marcada.
4. Crear un modelo desde el «+», asignarle los fernies y mover el reparto.
5. Entrenar.

Es el camino que prueba de verdad la fase 2. Si sólo interesa llegar a entrenar,
el camino 1 hace lo mismo en un minuto.

### 3. Pesos traídos de fuera

En la pantalla de detalle de un modelo, el botón de descarga junto al de guardar.
Elige `pruebas\pesos-externos\modelo-entrenado-fuera.pt`.

Lo que tiene que pasar:

- Dice las clases que trae. Son las **ochenta de COCO** («person», «bicycle»,
  «car»...), porque esos pesos son el `yolo11n` de ultralytics. Es lo esperado:
  FeRN las enseña tal cual, porque emparejarlas con los fernies de uno es cosa
  del usuario.
- El modelo queda marcado como **pesos importados**.
- El bloque de métricas deja de enseñar las del entrenamiento anterior y dice que
  los pesos vienen de fuera. Esto es lo importante de comprobar: esas métricas
  eran de **otros** pesos, y dejarlas puestas diría que este `.pt` acierta lo que
  acertaba el otro.
- Un fichero que no sean unos pesos válidos tiene que dar un aviso y **no** dejar
  nada copiado.

Para probarlo con unos pesos que sí conozcan a los fernies, entrena una vez y usa
el `best.pt` de la carpeta de la run: se importa igual.

## Los scripts, por separado

| Script | Qué hace |
|---|---|
| `generate_media.py` | Genera las imágenes, los vídeos y el `labels.json` con las cajas exactas. |
| `make_external_weights.py` | Deja un `.pt` de fuera con el que probar la importación. |
| `seed.dart` | Escribe en la base de datos de FeRN: contenidos, fernies, regiones y el modelo. |
| `prepare.ps1` | Los tres, en orden. |

Los de Python se lanzan con el intérprete del entorno de reconocimiento:

```powershell
& "$env:USERPROFILE\Documents\Fern\recognition\runtime\venv\Scripts\python.exe" .\tool\test_env\generate_media.py --out D:\pruebas
```

El de Dart necesita la biblioteca nativa de Isar, que saca de lo que haya
compilado el proyecto (`build\windows\x64\runner\Debug\isar.dll`). Si no hay nada
compilado, se le pasa con `--isar`.

```powershell
dart run tool/test_env/seed.dart --media D:\pruebas          # sembrar
dart run tool/test_env/seed.dart --media D:\pruebas --clean  # quitar lo sembrado
```

## Si algo se queda a medias

Si la aplicación se cierra a lo bruto con un entrenamiento en marcha, quedan dos
restos y ninguno rompe nada:

- La marca de «entrenando» en el modelo. **Se desatasca sola** al arrancar; si no
  se limpiara, ese modelo no se dejaría entrenar nunca más.
- La carpeta del dataset en `recognition\datasets\`. Son miles de imágenes y no
  sirven para nada: se puede borrar a mano.

Y puede quedar un `python.exe` huérfano, que es el sidecar con el entrenamiento
dentro. Se cierra desde el administrador de tareas.

## Para dejarlo todo como estaba

```powershell
dart run tool/test_env/seed.dart --media "$env:USERPROFILE\Documents\Fern\pruebas" --clean
```

Quita los contenidos y las regiones de prueba. Los tres fernies y el modelo se
borran desde la aplicación, que es donde se ve lo que se está borrando.
