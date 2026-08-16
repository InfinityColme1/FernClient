# FeRN

**FeRN** (*FernClient*) es un gestor de contenido multimedia de escritorio, hecho con Flutter.
Reúne en una sola biblioteca local lo que el usuario tiene repartido: los ficheros de su propio
equipo y lo que tiene guardado o marcado como favorito en las plataformas que usa. Todo lo que
entra se descarga a este equipo, se da de alta en una base de datos local (Isar) y se organiza con
etiquetas y creadores.

No hay servidor ni cuenta de FeRN: la biblioteca, los ficheros y las credenciales de las fuentes
viven en la máquina del usuario.

---

## Funciones actuales (1.0)

### Biblioteca

- **Rejilla de contenido** con imágenes y vídeo, miniaturas, carga progresiva e indicadores de
  espera en consultas y operaciones de ficheros.
- **Visor** a pantalla completa con reproducción de vídeo (media_kit), transición de carrusel al
  pasar al contenido siguiente o anterior (flechas de la interfaz o del teclado), marcado de
  **favoritos** y panel de información del contenido.
- **Favoritos**: la misma rejilla filtrada por lo marcado con el corazón del visor.
- **Papelera**: el contenido se marca para borrar, se puede restablecer, y lo que lleva más de una
  semana marcado se elimina solo al arrancar la aplicación.
- **Interfaz adaptable**: el menú lateral se pliega y el diseño cambia según el ancho de la ventana.

### Organización

- **Etiquetas** con jerarquía: gestor con lista, ficha editable y vista del contenido de cada
  etiqueta.
- **Creadores**: gestor propio con avatar y el contenido asociado a cada uno.
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
  | Pawchive | los favoritos de la cuenta |

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
- **Navegador**: sesión y comportamiento del navegador integrado.

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

## Estructura

Arquitectura por capas y por características (`data` / `domain` / `presentation`), con `flutter_bloc`
para el estado, `get_it` para las dependencias y `go_router` para la navegación.

```
lib/
├── config/     temas, colores, espaciados
├── core/       componentes de interfaz compartidos, servicios, utilidades, navegación
├── features/   media, settings, browser, splash
└── l10n/       los cuatro idiomas
```

La documentación de cada bloque (decisiones, ficheros y pendientes) está en
[`.claude/output`](.claude/output/README.md).
