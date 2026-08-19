class AppSizes {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 25.0; 
  static const double radiusDialog = 28.0;
  static const double radiusSurface = 43.0;
  static const double radiusFull = 100.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconCompact = 18.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconExtraLarge = 32.0;
  static const double iconHuge = 48.0;

  // Avatar Sizes
  static const double avatarSmall = 18.0;
  static const double avatarMedium = 24.0;
  static const double avatarLarge = 32.0;
  static const double avatarXLarge = 64.0;
  static const double avatarHuge = 80.0;

  // Button Heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeight = 50.0;
  static const double buttonHeightLarge = 54.0;
  
  // Panel Widths
  static const double infoPanelWidth = 350.0;
  static const double dialogMaxWidth = 800.0;
  static const double menuWidth = 280.0;

  /// El panel de trabajos en segundo plano. Más ancho que un menú corriente
  /// porque lleva barras de progreso y no sólo texto.
  static const double jobsPanelWidth = 320.0;

  /// Ancho de la lista de etiquetas de la pantalla de gestión de etiquetas: lo
  /// justo para que quepan el avatar, el nombre y la sangría de la jerarquía.
  static const double tagListWidth = 260.0;

  // Layout
  /// Ancho por debajo del cual se pasa al layout de móvil.
  ///
  /// Es el ancho al que la cabecera más cargada (la de importación, con
  /// selección hecha y todos sus botones) deja de caber con el menú lateral
  /// plegado: medido en `test/layout_breakpoints_test.dart`, que falla si
  /// alguna cabecera crece y este número se queda corto.
  static const double largeScreenMinWidth = 1200.0;

  /// Ancho por debajo del cual el menú lateral se pliega solo.
  ///
  /// El menú se pliega a la mitad del ancho de la pantalla del dispositivo,
  /// pero nunca más tarde de esto: es el ancho al que la cabecera de
  /// importación deja de caber con el menú desplegado, así que en pantallas
  /// cuya mitad es mayor que este número el menú se pliega aquí para que no
  /// desborde antes de llegar a [largeScreenMinWidth].
  static const double sidebarAutoCollapseMinWidth = 1340.0;

  // Grosores de borde
  /// El trazo de los contornos dibujados a mano (el círculo del botón de
  /// añadir): fino para la variante menuda, normal para las demás.
  static const double borderThin = 1.5;
  static const double borderRegular = 2.0;

  /// Lo que mide de ancho, como mínimo, la bolita con el contador de avisos.
  /// Con una cifra queda redonda y con tres se estira.
  static const double badgeMinWidth = 18.0;

  static const double logoWidth = 150.0;

  /// Ancho máximo del aviso de arranque fallido. Es una columna de texto y no
  /// una pantalla: pasado ese ancho las líneas se hacen incómodas de leer.
  static const double startupErrorMaxWidth = 560.0;

  // Ajustes: diálogo a dos columnas, secciones a la izquierda
  static const double settingsDialogWidth = 900.0;
  static const double settingsDialogHeight = 620.0;
  static const double settingsNavWidth = 240.0;

  /// Filas de ajuste con deslizador: lo que ocupa el rótulo a la izquierda y el
  /// valor a la derecha, para que varias filas seguidas queden alineadas.
  static const double settingsLabelWidth = 180.0;
  static const double settingsValueWidth = 64.0;

  /// Alto máximo del registro de instalación del entorno de reconocimiento:
  /// lo justo para ver qué está pasando sin que se coma la pantalla.
  static const double sidecarLogHeight = 180.0;

  /// Alto reservado al texto que va rotando mientras se instala. Es fijo para
  /// que la barra de progreso y los botones no se muevan al cambiar de frase,
  /// y da para dos líneas.
  static const double sidecarActivityHeight = 40.0;

  // Ajustes: tema
  /// Lado de la muestra de color de una fila de color y de la que enseña el
  /// selector.
  static const double colorSwatch = 36.0;

  /// El selector de color: lo que mide de ancho, el alto de la zona donde se
  /// elige el tono claro u oscuro y el de la barra de matices.
  static const double colorPickerWidth = 340.0;
  static const double colorPickerAreaHeight = 180.0;
  static const double colorPickerHueHeight = 24.0;

  /// La previsualización que acompaña a cada tema: es una ventana de la
  /// aplicación en pequeño, así que guarda su proporción.
  static const double themePreviewWidth = 168.0;
  static const double themePreviewHeight = 104.0;

  // Buscador de la barra superior
  static const double searchBarWidth = 420.0;
  static const double searchBarHeight = 48.0;

  // Indicador de progreso
  /// Tamaño del indicador de progreso cuando ocupa el sitio de lo que se está
  /// esperando (una rejilla, un panel).
  static const double progressIndicator = 36.0;

  /// Tamaño del indicador de progreso cuando va dentro de otra cosa: un botón,
  /// un campo de búsqueda o una cabecera.
  static const double progressIndicatorSmall = 20.0;
}
