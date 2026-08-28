# FeRN

**FeRN** (*FernClient*) es un gestor de contenido multimedia de escritorio, hecho con Flutter.
Reúne en una sola biblioteca local lo que el usuario tiene repartido: los ficheros de su propio
equipo y lo que tiene guardado o marcado como favorito en las plataformas que usa. Todo lo que
entra se descarga a este equipo, se da de alta en una base de datos local (Isar) y se organiza con
etiquetas y creadores.

No hay servidor ni cuenta de FeRN: la biblioteca, los ficheros, los modelos entrenados y las
credenciales de las fuentes viven en la máquina del usuario. Tampoco hay servicios de terceros
detrás del reconocimiento de imagen: se entrena y se infiere en local.

---

## Novedades de la 2.0

La 2.0 añade tres bloques grandes —reconocimiento de imagen, contenido repetido y filtro NSFW— y
reforma el aspecto de la aplicación entera.

### Reconocimiento de imagen

Es la función principal de esta versión. FeRN aprende a reconocer lo que al usuario le importa a
partir de ejemplos que marca él mismo, y con ello propone etiquetas y creadores para el contenido
que llega.

- **Fernies.** Un fernie es una cara, un personaje o un objeto: un nombre, un avatar y un conjunto
  de regiones marcadas sobre el contenido. Cada fernie puede proponer una etiqueta o un creador
  cuando se le encuentre; sin nada enlazado sólo sirve para entrenar.
- **Modo fernie en el visor.** Se marcan regiones arrastrando sobre el contenido, con zoom y
  desplazamiento. Tiene dos herramientas separadas —marcar y editar— porque son dos oficios sobre
  el mismo lienzo.
- **Vídeo y GIF fotograma a fotograma.** El modo fernie trae su propia línea de tiempo con
  reproducción, salto de fotograma y papel cebolla. Las regiones de un fernie en un vídeo son un
  recorrido de claves, no cajas sueltas: hay previsualización interpolada y arrastre de una región a
  todos los fotogramas de en medio.
- **Modelos.** Un modelo se arma con los fernies que se le pongan y contesta una de dos cosas: si
  cada uno está o no está, o cuál de ellos ha encontrado y dónde. Lo segundo necesita al menos dos
  fernies. Se entrena con presets (rápido, equilibrado, preciso) y una sección avanzada con épocas,
  tamaño de imagen, lote y backbone.
- **Árbol de modelos.** Un modelo que no está en el árbol no se ejecuta nunca. El árbol encadena:
  un modelo general filtra y, sólo si detecta el fernie al que cuelga una rama, se ejecutan los
  especializados de esa rama. Podar es el sentido del árbol.
- **Reconocer.** Se lanza sobre la selección de una rejilla, sobre el contenido del visor, sobre una
  etiqueta o un creador, o sobre la biblioteca entera. Lo que se ve llega como **sugerencia** con su
  porcentaje de confianza: nada se aplica solo, y se pueden aceptar de golpe todas las que pasen de
  un umbral.
- **Entorno propio, instalado por la aplicación.** Para entrenar e inferir, FeRN se descarga e
  instala su propio Python aislado dentro de su carpeta de reconocimiento y habla con él como
  proceso hijo. No hay que instalar nada a mano. Por defecto usa el procesador; si detecta una
  tarjeta gráfica compatible, ofrece aparte la instalación acelerada diciendo lo que ocupa.

### Contenido repetido

- **Búsqueda por huella** de todo lo que hay en la biblioteca, en paralelo al uso normal, con
  progreso y cancelación. También se repasa sola cada cierto tiempo, configurable o apagable.
- **Comparación lado a lado** de las copias con sus metadatos, para elegir cuál se conserva.
- **Fusión de metadatos** en la copia que se queda: etiquetas, creador, favorito y descripción de
  las descartadas.
- **Listón de similitud configurable**: cuánto pueden diferenciarse dos contenidos y seguir contando
  como el mismo.

### Filtro NSFW

- **El origen del marcado son las etiquetas**, y se propaga a toda su rama de hijas.
- Con el filtro puesto, ese contenido es **invisible en todas partes**: rejillas, búsqueda,
  favoritos y contadores.
- Contraseña con **sal y hash**, frase clave de pista y **código de recuperación de un solo uso**,
  exportable a fichero y regenerado tras cada uso. Que el filtro siga puesto entre arranques es
  configurable.
- Las credenciales de las fuentes remotas pasan a guardarse **cifradas**.

### Avisos

- Notifican cuatro cosas: escaneo automático de repetidos con hallazgos, entrenamiento terminado o
  fallido, reconocimiento en lote terminado e importación remota terminada.
- **Contador en el menú lateral** y sonido, con fichero de audio propio y recorte a los primeros
  segundos sin tocar el fichero.

### Aspecto

- **Iconos, tipografía y tamaños unificados**, con un solo juego de curvas y duraciones para todo lo
  que se mueve.
- **Transiciones entre pantallas** en las que cada pieza —cabecera, rejilla, ficha, lista— entra y
  sale por su lado.
- **Arrastrar contenido sobre una etiqueta** del menú para etiquetar de golpe, con la miniatura
  siguiendo al ratón.
- **Tutoriales guiados**: uno general que se ofrece la primera vez que se abre la aplicación, y
  cinco por materia —importar, gestores, fernies, modelos y repetidos— disponibles siempre desde
  Ajustes › Ayuda.

---

## Funciones

### Biblioteca

- **Rejilla de contenido** con imágenes y vídeo, miniaturas, carga progresiva e indicadores de
  espera en consultas y operaciones de ficheros.
- **Visor** a pantalla completa con reproducción de vídeo (media_kit), transición de carrusel al
  pasar al contenido siguiente o anterior (flechas de la interfaz o del teclado), marcado de
  **favoritos** y panel de información editable.
- **Favoritos**: la misma rejilla filtrada por lo marcado con el corazón del visor.
- **Papelera**: el contenido se marca para borrar, se puede restablecer, y lo que lleva más de una
  semana marcado se elimina solo al arrancar la aplicación.
- **Interfaz adaptable**: el menú lateral se pliega y el diseño cambia según el ancho de la ventana.

### Organización

- **Etiquetas** con jerarquía: gestor con lista, ficha editable y vista del contenido de cada
  etiqueta.
- **Creadores**: gestor propio con avatar, enlaces a sus sitios y el contenido asociado a cada uno.
- **Etiquetado automático por dirección**: una etiqueta guarda las direcciones de las que sale su
  contenido (`reddit.com/r/gifs`, por ejemplo) y todo lo que se importe desde ahí la recibe sola.
  La comparación es por tramos de la ruta, no por texto.
- **Buscador** con sugerencias y resultados agrupados, y **filtros** por tipo de contenido,
  etiquetas, creadores y fuente de origen.

### Importación

- **Ficheros locales**: escaneo de una carpeta del equipo.
- **Fuentes remotas**, cada una con sus credenciales en los ajustes:

  | Fuente | Qué se trae |
  |---|---|
  | Reddit | las publicaciones guardadas de la cuenta |
  | Pixiv | las obras marcadas, públicas y privadas |
  | Danbooru | los favoritos de la cuenta |
  | Gelbooru | los favoritos de la cuenta |
  | Pinterest | lo guardado en la cuenta |
  | Pawchive | los favoritos de la cuenta, y por creador |

- **Navegador integrado**: se abre una página cualquiera dentro de la aplicación y se importa lo que
  enseña, sin que haya que darle soporte a esa plataforma.
- **Enlaces a otros sitios**: de una publicación que apunta fuera se resuelve el fichero que hay
  detrás, con lista blanca de sitios (redgifs, imgur, streamable, giphy, tenor…), sólo `https`,
  comprobando el tipo y el tamaño de lo que llega y descartando sin llegar a pedirlo cualquier
  dirección desconocida.
- Pantalla de importación con revisión previa: cada contenido se guarda como definitivo o se
  descarta, y la deduplicación evita volver a descargar lo que ya está.

### Ajustes

- **Apariencia**: tema claro, tema oscuro, seguir el del sistema, o **tema a medida** eligiendo los
  colores de la aplicación.
- **Idioma**: español, inglés, francés y catalán.
- **Visor**: qué hacer al guardar un contenido importado (cerrar la visualización o pasar al
  siguiente).
- **Ficheros**: carpeta de la biblioteca, avatares, organización y migración de lo ya guardado.
- **Fuentes remotas**: credenciales de cada plataforma.
- **Reconocimiento**: carpeta propia, instalación del entorno, aceleración por tarjeta gráfica y
  umbral de confianza.
- **Contenido repetido**: cada cuánto se busca solo y listón de similitud.
- **Contenido NSFW**: contraseña, frase clave y código de recuperación.
- **Avisos**: qué se notifica, sonido y duración.
- **Navegador**: sesión y comportamiento del navegador integrado.
- **Base de datos**: mantenimiento y borrado.
- **Ayuda**: los seis recorridos guiados.

---

## Plataformas

Está pensado y probado para **Windows** (la pantalla completa de la ventana y la copia al
portapapeles se piden al sistema por FFI, sin complementos). El proyecto Flutter incluye además los
destinos de Linux, macOS, Android, iOS y web, que no están probados.

## Cómo compilarlo

Requiere el SDK de Flutter con Dart `^3.12.0`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # modelos de Isar y JSON
flutter run -d windows
```

Para una compilación de entrega: `flutter build windows --release`.

> Si al compilar en Windows aparece un error `MSB3021`/`MSB3027` copiando `WebView2Loader.dll`, es
> que hay una instancia de la aplicación abierta bloqueando el fichero: ciérrala y repite.

El entorno de Python del reconocimiento **no forma parte de la compilación**: lo instala la propia
aplicación en la carpeta de reconocimiento del usuario la primera vez que hace falta.

## Estructura

Arquitectura por capas y por características (`data` / `domain` / `presentation`), con `flutter_bloc`
para el estado, `get_it` para las dependencias y `go_router` para la navegación.

```
lib/
├── config/     temas, colores, espaciados
├── core/       componentes de interfaz compartidos, servicios, utilidades, navegación
├── features/   media, recognition, duplicates, nsfw, jobs, notifications,
│               tutorial, settings, browser, splash
└── l10n/       los cuatro idiomas
```

Las pruebas van en `test/`, sin espejo de la estructura de `lib/`: cada fichero cubre un
comportamiento y dice en su cabecera qué es lo que puede romperse ahí.

```bash
flutter analyze lib test
flutter test
```
