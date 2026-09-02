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

## Novedades de la 2.2.3

Los creadores etiquetan solos, se les puede poner uno a toda una selección, y
cambiar de pantalla deja de trabarse por muchos contenidos que haya.

- **Un creador puede traer etiquetas consigo.** Se le relacionan desde su ficha
  —o al crearlo— y, a partir de ahí, ponérselo a un contenido se las pone
  también, con lo que ellas arrastran. Es la otra mitad de las direcciones
  vinculadas: aquéllas dicen de dónde sale lo suyo, éstas qué lleva puesto lo
  suyo. Entran por donde sea que se ponga el creador: a mano, en tanda, por un
  fernie o al importar.
- **Y se le puede poner un creador a toda una selección**, desde la biblioteca y
  desde la pantalla de importación. Cien imágenes del mismo artista se abrían de
  una en una para escribir cien veces el mismo nombre.
- **Una etiqueta marcada puede esconderse sin esconder su contenido.** Ajuste
  nuevo en el filtro NSFW, encendido de fábrica: apagado, la marca se queda en la
  etiqueta y el contenido sigue a la vista con sus demás etiquetas. Sirve para
  una etiqueta que dice algo delicado sobre contenido que no lo es.
- **Cambiar de pantalla es fluido.** La lectura ya no cae encima de la
  transición, la biblioteca no se relee si nada ha cambiado, y lo que sí hay que
  leer se lee por tandas. Además, cada pantalla enseña lo suyo: antes la
  biblioteca podía abrirse con el contenido de la importación dentro.
- **La rejilla enseñaba uno de cada cuatro** cuando había un contenido mucho más
  alto que los demás. Arreglado.
- **Marcar una región ya no vacía el panel.** Se rellenaba el creador y las
  etiquetas, se marcaba un fernie, y todo eso desaparecía.
- **El panel de información no se desplaza entero**: las etiquetas y los fernies
  se recorren por dentro de su sección, cada uno con su botón de añadir siempre a
  la vista.
- Enter valida en los diálogos del bloqueo, ordenar los resultados de una
  búsqueda, descartar desde el visor pasa al siguiente y las etiquetas hermanas
  al ponerlas a mano — todo eso ya venía de la 2.2.2.

---

## Novedades de la 2.2.2

Un arreglo de etiquetado, dos mejoras pedidas y tres correcciones de trato.

- **Poner una etiqueta a mano ya trae a sus hermanas.** Estaban bien guardadas y
  la dirección se respetaba, pero el diálogo de asignar proponía **sólo las
  madres**, y guardar desde el panel escribe la lista tal cual se deja: lo que el
  diálogo no propusiera no se ponía nunca. Al importar, al aceptar una sugerencia
  o al marcar un fernie sí venían, así que la misma etiqueta daba dos resultados
  distintos según por dónde se pusiera. Ahora los dos caminos piden lo mismo.
- **Los resultados de una búsqueda se pueden ordenar.** El desplegable de orden
  ya no desaparece al buscar: ordena dentro de cada grupo, que es donde hay tanto
  contenido como en la biblioteca.
- **Enter valida en los diálogos del bloqueo.** En los cinco —abrir, configurar,
  cambiar la contraseña, desactivar y recuperar—, escribir y pulsar Enter hace lo
  mismo que el botón.
- **Descartar desde el visor revisando una importación pasa al siguiente** en vez
  de cerrarlo. Es la misma regla que ya tenía guardar: repasar una tanda es
  abrir, decidir y pasar. Fuera de una revisión se cierra, como antes.
- **Un creador se vincula y se marca desde su propio diálogo de creación.** Sus
  direcciones son lo que hace que se le asigne solo al importar, y antes había
  que crearlo, buscarlo en su lista y volver a abrirlo para ponérselas.
- **Pulsar una etiqueta del menú desde otra pantalla filtra siempre por ella.**
  Había una carrera —el menú mandaba la búsqueda y la pantalla, al abrirse, pedía
  además lo que hubiera en marcha— y unas veces ganaba una y otras la otra. Ahora
  la etiqueta viaja con la navegación: una sola petición.

---

## Novedades de la 2.2.1

Tres arreglos: dos del reconocimiento, que se rompió en la 2.2.0, y uno del
etiquetado automático que venía de antes.

- **El enlace de un artista de Pixiv no asignaba nada.** FeRN pone en cada obra
  la dirección del perfil (`pixiv.net/users/123`), y lo que copia el navegador
  trae el idioma con el que se estaba viendo la página (`/en/users/123`), la
  pestaña del perfil que estaba abierta (`/users/123/artworks`), o las dos cosas.
  Para una persona son el mismo artista; comparados como texto, direcciones
  distintas, así que el contenido entraba con el creador desconocido. Ahora esos
  dos tramos se descartan al comparar —sólo en Pixiv—, y **el enlace que ya
  tuvieras puesto empieza a funcionar sin volver a escribirlo**. Las etiquetas
  vinculadas por dirección tenían el mismo problema y se arreglan igual.

- **El reconocimiento se quedaba pensando y no hacía nada.** El proceso de Python
  leía las peticiones en un hilo aparte —lo que se añadió en la 2.2 para poder
  cancelar un entrenamiento en marcha— y en Windows un hilo bloqueado leyendo la
  entrada **cuelga la carga de numpy y de torch**: sin error, sin gastar
  procesador y para siempre. Ya no hay hilo, y la señal de parada va ahora por un
  fichero que el proceso mira entre imagen e imagen y entre época y época, que es
  justo cuando puede parar. Cancelar sigue funcionando igual.
- **«No se puede encontrar la ruta especificada: runs\detect\predict».**
  Ultralytics crea siempre su carpeta de salida al preparar una predicción,
  aunque no vaya a guardar nada, y sin decirle dónde la ponía en una ruta
  relativa al directorio de trabajo. Ahora se le dice, en absoluto y dentro de la
  carpeta de reconocimiento, y es siempre la misma en vez de una nueva por cada
  imagen mirada.

---

## Novedades de la 2.2

Una versión grande: doce funciones nuevas repartidas en ocho fases, más el
tutorial rehecho de arriba abajo.

### Encontrar las cosas

- **La búsqueda acumula pastillas y las cruza.** Se pueden poner varias a la vez
  —esta etiqueta, de este creador, con esta palabra— y la rejilla enseña lo que
  cumple **todas**. Lo escrito que no case con nada se queda como pastilla de
  texto libre y busca en descripciones y nombres de fichero.
- **Buscador en el menú lateral y en las listas de gestión**, con la misma regla
  en los dos sitios: lo que encaja viene con su rama entera.
- **Las ramas de etiquetas se pliegan**, en el menú y en la pantalla de gestión.
  Lo plegado se recuerda, y arrastrar contenido sobre una rama cerrada la abre
  sola para poder seguir bajando.

### Organizar

- **Etiquetas hermanas.** Dos etiquetas que van juntas: poner una pone la otra,
  sin que ninguna cuelgue de la otra. Se pueden silenciar por etiqueta.
- **Personas.** Una etiqueta se puede marcar como persona y se gestiona en su
  propia lista, sin dejar de comportarse como una etiqueta en el resto de la
  aplicación.
- **Las direcciones vinculadas de una etiqueta se ven en su ficha** y ya no se
  pierden al guardar el nombre. *(Arreglaba una pérdida de datos: guardar una
  etiqueta le borraba sus direcciones y sus hermanas.)*
- **Quitar una etiqueta desde el panel del contenido**, sin abrir ningún diálogo.
- **Recientes** al asignar etiquetas y creadores: al abrir el campo se ofrecen
  los tres últimos que se pusieron.
- **De dónde sale cada etiqueta.** Un registro por contenido que dice, etiqueta a
  etiqueta, por qué está puesta: la pusiste tú, casó una dirección vinculada,
  vino de la plataforma, se heredó de la rama o de una hermana, la propuso un
  modelo o la trajo un fernie. Lo anterior a esta versión se deduce y se dice que
  se deduce.

### Traer contenido

- **No volver a importar esto.** Al descartar algo de una fuente remota se puede
  decir que no se vuelva a ofrecer: se salta **antes de descargarlo**, y la lista
  de lo bloqueado está en Ajustes › Base de datos para deshacerlo.
- **Importar marcando todo como NSFW**, desde la propia cabecera de importación.
- **Importar más rápido** cuando hay mucho bloqueado: lo saltado ya no se
  descarga para descartarse después.

### Fernies y reconocimiento

- **Marcar el fotograma entero** con un botón, sin arrastrar.
- **Una etiqueta entera como regiones de un fernie**: se marca todo su contenido
  de una vez, por la cola de tareas y con muestreo de fotogramas en los vídeos.
- **Marcar una región etiqueta el contenido** con lo que el fernie enlaza. El
  creador, sólo si no tenía uno propio.
- **Aceptar lo que propone un modelo como regiones**: se dibuja lo que vio y se
  aceptan las que estén bien, una a una o todas de golpe. Un modelo puede
  proponer varias detecciones del mismo fernie en un contenido.
- **Creadores NSFW**: marcar un creador esconde también todo lo suyo.
- **Olvidar el entrenamiento de un modelo** sin perder sus fernies, sus
  hiperparámetros ni su sitio en el árbol.
- **Cancelar un entrenamiento funciona de verdad.** La señal llega hasta el
  proceso de Python, que ahora la atiende mientras entrena; si no para en un
  minuto, se cierra a la fuerza.

### Ficheros y mantenimiento

- **Recortar el avatar.** Al elegir la imagen de una etiqueta, un creador, un
  fernie o un modelo se puede escoger **de la propia biblioteca de FeRN** —con su
  rejilla, su buscador y su árbol de etiquetas— o del equipo, y en los dos casos
  recortar un cuadrado o quedarse con la imagen entera.
- **Sin avatares huérfanos**: al reemplazar uno, el anterior se borra si no lo usa
  nadie.
- **Limpieza** en Ajustes › Base de datos: encuentra los ficheros sueltos del
  directorio de trabajo —avatares sin dueño, descargas cuya ficha ya no está,
  pesos de modelos que no existen—, dice cuánto ocupan y pregunta antes.
- **Vaciar la base de datos con opciones**: todo o **sólo lo marcado como NSFW**,
  y con la posibilidad de llevarse también los ficheros del disco, que se borran
  por la cola de tareas con su progreso.

### Tutoriales

- **De seis recorridos a diez, y de 36 pasos a 88.** Entre todos explican la
  aplicación entera: siguiéndolos no queda ningún concepto sin contar.
- Cuatro recorridos nuevos: **la biblioteca y el visor**, **buscar y filtrar**,
  **el bloqueo de contenido** y **ficheros y mantenimiento**. Los seis anteriores
  se han reescrito y ampliado.

### Y además

- **Los ajustes están ordenados por familias**: cómo se ve la aplicación, dónde
  vive el contenido, lo que hace sola con él, y al final la ayuda y lo que
  destruye. El instalador del entorno de reconocimiento ya no está al fondo de su
  sección.
- **Los contenidos bloqueados de la lista de Ajustes se abren en el navegador**
  al pulsarlos.
- Arreglos: guardar y pasar al siguiente ya no acumula pantallas; ese salto sólo
  ocurre revisando una importación; el panel del contenido se actualiza al
  instante cuando algo lo etiqueta solo; y el texto de la interfaz ya no se corta
  en el menú lateral.

---

## Novedades de la 2.1.2

- **El filtro NSFW ya no se salta por los fernies.** Marcar contenido y luego
  recortarlo en un fernie lo devolvía a la vista por la pantalla de fernies, con
  el filtro puesto. Ahora los fernies y los modelos se marcan como las etiquetas,
  y lo marcado **sigue entrenando y reconociendo igual**: lo que cambia es que no
  se ve.
- **Marcar NSFW desde la importación**, sin tener que confirmar el contenido y
  pasarlo por la biblioteca primero.
- **La selección puede sobrevivir a soltarla en una etiqueta.** Se enciende en
  Ajustes → Apariencia; de fábrica se desmarca, como hasta ahora.
- **Asignar etiquetas de corrido.** Al elegir una del buscador, el campo se vacía
  y se queda listo para la siguiente.
- **Crear una etiqueta o un creador desde el visor** ofrece usar de avatar la
  imagen que se está mirando.
- **Las flechas pasan de contenido siempre**, se haya pulsado antes lo que se
  haya pulsado. Antes dejaban de funcionar hasta volver a pulsar sobre la imagen.
- **El cursor de los campos de texto se ve**, y todos los campos se ven iguales.

---

## Novedades de la 2.1.1

- **Filtro en los gestores.** Las listas de etiquetas y de creadores traen un
  campo para acotarlas por nombre, sin distinguir mayúsculas y buscando por
  cualquier parte del nombre.
- **La jerarquía de etiquetas se toca arrastrando.** Se suelta una etiqueta sobre
  otra y se elige entre colgarla de ella o relacionar las dos. Antes había que
  abrir la ficha de cada una.
- **Los nombres de etiqueta son únicos.** Ya no se pueden crear dos que se llamen
  igual, ni renombrar una con el nombre de otra.
- **Importar en paralelo de verdad.** Salir de la pantalla de importación y
  volver ya no deja fuera lo que estaba llegando, el indicador sigue puesto
  mientras dure, y parar avisa de que está parando.
- **Los avisos se amontonan** en vez de taparse unos a otros, hasta tres a la vez.

---

## Novedades de la 2.1

- **Volumen del visor.** La línea de tiempo de los vídeos trae un botón que abre
  un deslizador vertical. El volumen elegido se queda puesto para los vídeos que
  se abran después y entre arranques, así que se toca una vez y se olvida. El
  botón sólo aparece donde hay algo que oír: en vídeos, no en imágenes ni GIF, y
  en el modo de mirar, no marcando fernies.

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

- **Se marcan etiquetas, creadores y contenido suelto**: lo de una etiqueta se propaga a toda su
  rama de hijas, y lo de un creador, a todo lo suyo.
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
  nueve por materia —importar, la biblioteca y el visor, etiquetas y creadores, buscar, fernies,
  modelos, repetidos, el bloqueo de contenido y los ficheros— disponibles siempre desde
  Ajustes › Ayuda. Entre todos explican la aplicación entera.

---

## Funciones

### Biblioteca

- **Rejilla de contenido** con imágenes y vídeo, miniaturas, carga progresiva e indicadores de
  espera en consultas y operaciones de ficheros.
- **Visor** a pantalla completa con reproducción de vídeo (media_kit), transición de carrusel al
  pasar al contenido siguiente o anterior (flechas de la interfaz o del teclado), control de
  volumen, marcado de **favoritos** y panel de información editable.
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
- **Buscador acumulativo**: cada etiqueta, creador o texto que se elige se queda como una pastilla,
  y con varias puestas se enseña lo que las cumple **todas**. Con **filtros** por tipo de contenido,
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
