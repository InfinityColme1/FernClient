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
  static const double largeScreenMinWidth = 960.0;

  /// Ancho por debajo del cual el menú lateral se pliega solo.
  ///
  /// El menú se pliega a la mitad del ancho de la pantalla del dispositivo,
  /// pero nunca más tarde de esto: es el ancho al que la cabecera de
  /// importación deja de caber con el menú desplegado, así que en pantallas
  /// cuya mitad es mayor que este número el menú se pliega aquí para que no
  /// desborde antes de llegar a [largeScreenMinWidth].
  static const double sidebarAutoCollapseMinWidth = 1100.0;

  static const double logoWidth = 150.0;

  // Ajustes: diálogo a dos columnas, secciones a la izquierda
  static const double settingsDialogWidth = 900.0;
  static const double settingsDialogHeight = 620.0;
  static const double settingsNavWidth = 240.0;

  // Buscador de la barra superior
  static const double searchBarWidth = 420.0;
  static const double searchBarHeight = 48.0;
}
