class AppSizes {
  // Border Radius
  static const double radiusSmall = 8.0;

  /// El ancho fijo de la etiqueta y del número de una métrica.
  ///
  /// Fijos para que las cuatro barras empiecen en la misma vertical: si cada una
  /// arranca donde termina su texto, la comparación de un vistazo se pierde.
  static const double metricLabelWidth = 88.0;
  static const double metricValueWidth = 36.0;
  static const double metricBarHeight = 8.0;

  /// Lo que ocupa el botón de entrenar al lado de los presets.
  ///
  /// Fijo para que no encoja cuando el texto cambia de «Entrenar modelo» a
  /// «Volver a entrenar», ni se estire a media pantalla en una ventana ancha.
  static const double trainingActionWidth = 220.0;

  /// Lo que ocupa una tarjeta del árbol de modelos y el hueco entre ellas.
  ///
  /// Fijas para que la rejilla se pueda calcular sin medir: dónde cae cada nodo
  /// sale de su fila y su columna, y las aristas se dibujan con esas mismas
  /// cuentas. Con tarjetas de alto variable habría que medirlas todas antes de
  /// poder pintar una sola línea.
  static const double treeNodeWidth = 200.0;
  static const double treeNodeHeight = 92.0;
  static const double treeColumnGap = 40.0;
  static const double treeRowGap = 72.0;

  /// El relleno de la etiqueta que lleva una arista encima.
  static const double treeLabelPadding = 6.0;

  /// Lo ancho que es el panel de modelos de la derecha.
  static const double treeSidePanelWidth = 300.0;

  /// Lo alta que puede ser la lista de clases del diálogo de una arista.
  ///
  /// Un modelo puede tener veinte fernies: sin tope, el diálogo se sale de la
  /// ventana antes de llegar a los botones.
  static const double edgeConditionListHeight = 320.0;

  /// El diálogo con las imágenes de la run.
  ///
  /// Ancho porque lo que enseña son gráficas de ultralytics con ejes y
  /// etiquetas: en una columna estrecha no se lee ninguna.
  static const double runImagesDialogWidth = 900.0;
  static const double runImagesDialogHeight = 560.0;

  /// Lo que ocupa el marco de un diálogo alrededor de su contenido.
  ///
  /// El margen que `Dialog` deja contra la ventana, el relleno de dentro y la
  /// fila del aspa. Hace falta para poder decir cuánto alto le queda de verdad
  /// al contenido: un diálogo con alto fijo desborda en cuanto la ventana es
  /// más baja de lo que alguien supuso al escribirlo.
  static const double dialogChromeHeight = 180.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  /// El radio de una píldora: un desplegable, un chip, un botón de la cabecera.
  static const double radiusExtraLarge = 18.0;

  static const double radiusDialog = 24.0;

  /// El radio de las superficies grandes (la rejilla, los paneles).
  ///
  /// Era 43, que a este tamaño de superficie no se lee como una esquina
  /// redondeada sino como un óvalo: le comía las celdas de las esquinas —de ahí
  /// [AppSpacing.gridInset]— y hacía que todo pareciera más blando y más grande
  /// de lo que es.
  static const double radiusSurface = 28.0;

  static const double radiusFull = 100.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconCompact = 18.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconExtraLarge = 32.0;
  static const double iconHuge = 48.0;

  /// Los botones que se ponen en la esquina de una ficha.
  ///
  /// Al tamaño grande (32) pesaban más que el nombre que tienen al lado: un
  /// icono de contorno engorda su trazo con el tamaño, así que grande es también
  /// grueso, y en una esquina eso se lee antes que el contenido de la ficha. Van
  /// al mismo tamaño que los de una cabecera, que es lo que son.
  static const double iconCardAction = iconMedium;

  /// Radio del círculo del botón de añadir cuando va suelto en un formulario y
  /// no acompaña a ninguna rejilla de avatares.
  ///
  /// En una rejilla de avatares el botón usa [avatarLarge], que es lo que hace
  /// que el "+" y las caras que tiene al lado midan lo mismo.
  static const double addButtonRadius = 20.0;

  // Avatar Sizes
  static const double avatarSmall = 18.0;
  static const double avatarMedium = 24.0;
  static const double avatarLarge = 32.0;
  static const double avatarXLarge = 64.0;
  static const double avatarHuge = 80.0;

  // Button Heights
  //
  // Un escalón por debajo de lo que había (40/50/54). A 50 un botón normal
  // ocupaba más que una fila de texto y medio, que es lo que hacía que la
  // aplicación se sintiera grande incluso donde no sobraba nada.
  static const double buttonHeightSmall = 34.0;
  static const double buttonHeight = 42.0;
  static const double buttonHeightLarge = 46.0;

  /// Lo alta que es la barra de arriba.
  ///
  /// Es la primera franja de la ventana y no lleva nada más que el buscador y
  /// tres botones: a 80 era una banda de aire con cosas sueltas dentro.
  static const double toolbarHeight = 64.0;
  
  // Panel Widths
  static const double infoPanelWidth = 350.0;
  static const double dialogMaxWidth = 800.0;

  /// Ancho y alto del diálogo que elige una imagen de la biblioteca.
  ///
  /// Más ancho que un diálogo normal a propósito: dentro va la lista de
  /// etiquetas **y** una rejilla de contenido, y con los 800 de siempre la
  /// rejilla se quedaba en un canal de dos celdas por el que no se puede buscar
  /// nada.
  static const double libraryPickerMaxWidth = 1100.0;
  static const double libraryPickerHeight = 520.0;

  /// Alto del lienzo en el que se recorta un avatar.
  ///
  /// Fijo y no proporcional a la ventana: la imagen se pinta con `contain`, así
  /// que un lienzo que creciera con la ventana no enseñaría más imagen, sólo
  /// más bandas a los lados. Lo que hace falta es que quepa dentro del diálogo
  /// dejando sitio a los botones en una pantalla baja.
  static const double avatarCropCanvasHeight = 420.0;
  static const double menuWidth = 280.0;

  /// Lo que le queda al texto de una fila de menu despues del icono y los
  /// rellenos.
  ///
  /// Hace falta cuando el texto lleva dentro algo que escribe el usuario —el
  /// nombre de una etiqueta, por ejemplo—: sin un tope, un nombre largo desborda
  /// el panel en vez de recortarse.
  static const double menuLabelWidth = 196.0;

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
  static const double largeScreenMinWidth = 1180.0;

  /// Ancho por debajo del cual el menú lateral se pliega solo.
  ///
  /// El menú se pliega a la mitad del ancho de la pantalla del dispositivo,
  /// pero nunca más tarde de esto: es el ancho al que la cabecera de
  /// importación deja de caber con el menú desplegado, así que en pantallas
  /// cuya mitad es mayor que este número el menú se pliega aquí para que no
  /// desborde antes de llegar a [largeScreenMinWidth].
  static const double sidebarAutoCollapseMinWidth = 1320.0;

  /// Lo ancho que es el menu lateral, desplegado y plegado.
  ///
  /// Vive aqui y no como valor por defecto del cajon porque la barra de arriba
  /// tambien lo necesita: el buscador empieza donde acaba el menu, y con cada
  /// uno usando su propio numero eso se descuadra en cuanto alguien toque uno.
  static const double sidebarWidth = 210.0;
  static const double sidebarCollapsedWidth = 70.0;

  // Grosores de borde
  /// El trazo de los contornos dibujados a mano (el círculo del botón de
  /// añadir): fino para la variante menuda, normal para las demás.
  static const double borderThin = 1.5;
  static const double borderRegular = 2.0;

  /// El trazo que separa una superficie de lo que tiene al lado.
  ///
  /// Un píxel y no más: no es un borde que se mire, es el escalón que hace que
  /// dos superficies pegadas no parezcan la misma mancha de color. Se pinta con
  /// `AppPalette.outline`.
  static const double borderHairline = 1.0;

  /// Lo que mide de ancho, como mínimo, la bolita con el contador de avisos.
  /// Con una cifra queda redonda y con tres se estira.
  static const double badgeMinWidth = 18.0;

  /// Lo alto que va el logotipo en la barra de arriba.
  ///
  /// El ancho lo decide él: la marca y el nombre crecen juntos desde el alto,
  /// así que las proporciones son las mismas en la barra y en la bienvenida.
  static const double logoHeight = 30.0;

  /// Lo ancha que puede ser la explicación de un estado vacío.
  ///
  /// Acotada: una línea que cruza la pantalla entera no se lee, se sobrevuela.
  static const double emptyStateTextWidth = 380.0;

  /// Lo que ocupa la ilustración de un estado vacío.
  ///
  /// Aquí y no dentro del widget: era el único número a pelo que quedaba en la
  /// capa de UI compartida.
  static const double emptyStateImage = 132.0;

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

  /// El hueco que se le reserva al mensaje de «copiado» o «guardado en…» del
  /// código de recuperación.
  ///
  /// Fijo y no según lo que ocupe el texto: el diálogo va centrado, así que un
  /// mensaje que aparece le cambia el alto y le mueve los botones al usuario
  /// justo después de pulsarlos. Dos líneas de texto pequeño, que es lo que
  /// ocupa el mensaje más largo —el que lleva la ruta— acotado a dos.
  static const double nsfwCodeResultHeight = 32.0;

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
  static const double searchBarHeight = 40.0;

  /// Lo ancha que es la marca de la fila elegida del menú lateral.
  static const double sidebarMarkWidth = 3.0;

  /// Lo alta que es, en proporción a la fila.
  ///
  /// Más corta que la fila a propósito: una barra de borde a borde se lee como
  /// un separador entre filas, y lo que tiene que decir es «ésta».
  static const double sidebarMarkHeightFactor = 0.5;

  /// El carril que se le reserva a la izquierda de la píldora.
  ///
  /// La marca vive **fuera** de la píldora: dentro se pisaba con el teñido del
  /// fondo, que es del mismo color, y quedaba pegada al icono.
  static const double sidebarMarkGutter = 10.0;

  /// El redondeo de una casilla de verificar. Poco: una casilla muy redonda se
  /// confunde con un interruptor.
  static const double checkboxRadius = 4.0;

  /// El carril y el tirador de un deslizador.
  static const double sliderTrack = 4.0;
  static const double sliderThumb = 7.0;

  /// El hueco del icono de la lupa en un campo de filtro.
  ///
  /// El de fabrica es cuadrado y ancho, pensado para un campo alto; en uno
  /// estrecho se come la mitad de lo que se escribe.
  static const double filterFieldIconSlot = 36.0;

  // Barra de desplazamiento
  /// Lo gorda que es. Fina a propósito: es una referencia, no un mando que se
  /// mire.
  static const double scrollbarThickness = 6.0;

  /// Lo gorda que se pone con el raton encima, y arrastrandola.
  ///
  /// Crece al acercarse porque en reposo es una referencia —dice por donde va el
  /// contenido— y bajo el cursor es un mando: hay que poder cogerla sin apuntar.
  static const double scrollbarThicknessHover = 9.0;
  static const double scrollbarThicknessDragged = 11.0;

  /// Lo que se separa del canto de lo que desplaza.
  ///
  /// **Poco a proposito.** Este hueco no aparta la pastilla del contenido: la
  /// aparta del borde, o sea que la mete hacia dentro, que es justo hacia el
  /// contenido. Subirlo para «darle aire» la empuja encima de lo que hay debajo,
  /// y en un panel estrecho —el menu lateral, la columna de los ajustes— eso se
  /// ve al momento. El aire se da por el otro lado, con [scrollbarLane].
  static const double scrollbarMargin = 4.0;

  /// Lo que tiene que apartarse el contenido por la derecha para dejarle sitio.
  ///
  /// La barra se pinta **encima** de lo que desplaza, asi que el hueco entre la
  /// pastilla y el contenido no lo pone la barra: lo pone el contenido, o no lo
  /// pone nadie. Da para el hueco del canto, para lo gorda que llega a ponerse
  /// con el raton encima y para un margen que se vea.
  static const double scrollbarLane = 24.0;

  /// Lo que se acorta por arriba y por abajo.
  ///
  /// Es lo que arregla que la barra saliera **mordida**: la rejilla de contenido
  /// va dentro de una superficie de esquinas redondeadas y recortada, y una barra
  /// pegada al canto entra en la curva justo en sus dos extremos. Con este hueco
  /// empieza y acaba ya dentro de la parte recta, asi que no hay curva que la
  /// alcance. Sale de [radiusSurface], que es el redondeo mas grande que se usa.
  static const double scrollbarEndInset = 16.0;

  /// Lo más corto que se deja al pulgar. Con muchas opciones se encoge tanto que
  /// deja de ser algo que se pueda agarrar.
  static const double scrollbarMinThumb = 32.0;

  // Indicador de progreso
  /// Tamaño del indicador de progreso cuando ocupa el sitio de lo que se está
  /// esperando (una rejilla, un panel).
  static const double progressIndicator = 36.0;

  /// Tamaño del indicador de progreso cuando va dentro de otra cosa: un botón,
  /// un campo de búsqueda o una cabecera.
  static const double progressIndicatorSmall = 20.0;
}
