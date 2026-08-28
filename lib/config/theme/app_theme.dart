import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// El borde de un campo de texto: la misma caja redondeada que el resto de la
  /// aplicación, cambiando sólo el color y el grosor.
  static OutlineInputBorder _field(
    Color color, {
    double width = AppSizes.borderHairline,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Cursor de todo lo pulsable: mano cuando está activo y flecha normal
  /// cuando está deshabilitado.
  static const _clickable = WidgetStateMouseCursor.clickable;

  static final lightTheme = of(AppColors.light);
  static final darkTheme = of(AppColors.dark);

  /// El tema de la aplicación pintado con [palette].
  ///
  /// Es uno solo para las tres paletas (la clara, la oscura y la del usuario):
  /// lo que cambia entre temas son los colores, no cómo está hecha la
  /// aplicación. La paleta viaja además dentro del tema, que es de donde la
  /// leen las pantallas con `context.colors`.
  static ThemeData of(AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      extensions: [palette],

      // **Sin la tinta que se expande al pulsar.**
      //
      // Es la firma más reconocible de Material, y en un escritorio está fuera
      // de sitio: ninguna aplicación de escritorio hace ondas al recibir un
      // clic. Lo que sí hace falta es que se note que algo se ha pulsado, y de
      // eso se encargan el velo de encima y el de pulsado, que son instantáneos
      // y no dibujan nada que se mueva.
      //
      // Va aquí arriba a propósito: lo hereda todo, incluidos los `InkWell` que
      // la aplicación monta por su cuenta.
      splashFactory: NoSplash.splashFactory,
      primaryColor: palette.primary,
      secondaryHeaderColor: palette.secondary,
      scaffoldBackgroundColor: palette.background,
      brightness: palette.brightness,
      fontFamily: 'Google Sans Flex',

      // Lo que pinta Flutter por su cuenta (los menús del sistema, la selección
      // de texto, los diálogos de fábrica) sale de aquí, así que también tiene
      // que saber de qué color va la aplicación.
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: palette.brightness,
      ).copyWith(
        primary: palette.primary,
        secondary: palette.secondary,
        tertiary: palette.terciary,
        error: palette.error,
        surface: palette.white,
        onSurface: palette.black,
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(palette.secondary),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge)),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(color: palette.black, fontSize: 14)
        ),
        hintStyle: WidgetStateProperty.all(
          TextStyle(color: palette.lightgray, fontSize: 14)
        ),
      ),

      searchViewTheme: SearchViewThemeData(
        elevation: 0,
        backgroundColor: palette.background,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.black,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          ),
          elevation: 0,
        ).copyWith(mouseCursor: _clickable),
      ),

      // Un botón de texto se pinta, de fábrica, con el primario del esquema de
      // color. Y el primario de FeRN es el lavanda con el que están pintadas las
      // propias superficies: sobre una de ellas, el texto del botón se leía
      // exactamente igual que uno deshabilitado. Con el acento se lee y además
      // dice que se puede pulsar.
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: _clickable,
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? palette.unremarked
                : palette.terciary;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: const ButtonStyle(mouseCursor: _clickable),
      ),

      // El fondo que se enciende bajo el ratón es un **rectángulo redondeado**,
      // no un círculo.
      //
      // El círculo es de Material y de las pantallas táctiles, donde marca la
      // zona que responde al dedo. Con un ratón esa zona ya se sabe —el cursor
      // está encima— y lo que se espera en un escritorio es la casilla del
      // botón, que además cuadra con la fila de botones que tiene al lado en vez
      // de dibujar una hilera de lunares.
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: _clickable,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return palette.stateLayer;
            }

            return Colors.transparent;
          }),
          // Un botón que no se puede pulsar se pinta en gris claro: es lo único
          // que lo distingue de uno que sí, porque no tiene ni fondo ni texto.
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? palette.lightgray
                : palette.black,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: const ButtonStyle(mouseCursor: _clickable),
      ),

      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(mouseCursor: _clickable),
      ),

      // El velo que aparece bajo el ratón sale ahora de la paleta y no del
      // esquema de color de Material: con el primario lavanda de la aplicación,
      // el de fábrica no se veía sobre las superficies (que van pintadas de ese
      // mismo lavanda) y pasar por encima de algo pulsable no decía nada.
      hoverColor: palette.stateLayer,
      splashColor: palette.stateLayer,
      highlightColor: palette.stateLayer,
      focusColor: palette.stateLayer,

      listTileTheme: ListTileThemeData(
        mouseCursor: _clickable,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          mouseCursor: _clickable,
          backgroundColor: WidgetStatePropertyAll(palette.white),
        ),
      ),

      menuButtonTheme: const MenuButtonThemeData(
        style: ButtonStyle(mouseCursor: _clickable),
      ),

      tabBarTheme: const TabBarThemeData(mouseCursor: _clickable),

      // El lavanda de la aplicación no se ve sobre el fondo claro, así que las
      // esperas se pintan con el rosa, que es el color con el que la aplicación
      // llama la atención. Sin surco: sólo gira el trazo.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.terciary,
        circularTrackColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        // Con el trazo de las superficies, que es lo que separa sin llamar la
        // atención. El gris claro se usaba también para lo desactivado, así que
        // un separador pesaba igual que un control apagado.
        color: palette.outline,
        thickness: AppSizes.borderHairline,
        space: AppSpacing.l,
      ),

      // La escala de texto.
      //
      // Los pesos que se piden aquí son ahora los que de verdad se pintan: en el
      // `pubspec.yaml` estaban cruzados Regular y Medium, así que todo lo que
      // pedía 400 salía en Medium. Con eso arreglado, un texto normal pesa lo que
      // tiene que pesar y los rótulos vuelven a destacar sobre él.
      //
      // Los títulos llevan el interletrado un pelo cerrado: a tamaño grande la
      // separación de fábrica se abre demasiado y el título se lee como una
      // sucesión de letras en vez de como una palabra.
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: palette.black,
          fontSize: 21,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: palette.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          color: palette.black,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: palette.black,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        // El rótulo de una fila del menú lateral. Estaba en uso sin estar
        // definido, así que caía en el estilo de fábrica de Material y se salía
        // de la tipografía de la aplicación.
        labelLarge: TextStyle(
          color: palette.black,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.3,
        ),
        labelSmall: TextStyle(
          color: palette.black,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.35,
        ),
      ),

      // El grosor de trazo de todos los iconos, en un solo sitio.
      //
      // Los iconos son de trazo variable, así que esto es un ajuste de verdad y
      // no una aproximación: lo hereda cualquier `Icon` que no diga otra cosa, y
      // es lo que hace que la pantalla entera pese lo mismo.
      iconTheme: IconThemeData(
        color: palette.black,
        size: AppSizes.iconLarge,
        weight: appIconWeight,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        toolbarHeight: AppSizes.toolbarHeight,
        iconTheme: IconThemeData(color: palette.black),
      ),

      // **Un campo es una caja, no un renglón.**
      //
      // La raya de debajo es de Material y viene de rellenar formularios en un
      // móvil: dice dónde se escribe sin gastar sitio. En un escritorio lo que
      // se espera es ver la caja entera —dónde empieza y dónde acaba lo que se
      // puede escribir—, y además así el campo se parece a todo lo demás de la
      // aplicación, que va en cajas redondeadas con su trazo fino.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.secondary,
        hintStyle: TextStyle(color: palette.unremarked, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        border: _field(palette.outline),
        enabledBorder: _field(palette.outline),
        // Al escribir, el trazo se marca con el color de la aplicación: es lo
        // que dice dónde va lo que se teclea cuando hay varios campos a la vista.
        focusedBorder: _field(palette.primary, width: AppSizes.borderRegular),
        errorBorder: _field(palette.error),
        focusedErrorBorder: _field(palette.error, width: AppSizes.borderRegular),
        disabledBorder: _field(palette.outline),
      ),

      // Los interruptores, sin el aro de fuera y con el tirador pequeño: el de
      // Material es grande y lleva un icono dentro, y eso lo hace lo más
      // llamativo de cualquier fila de ajustes en la que aparezca.
      switchTheme: SwitchThemeData(
        mouseCursor: _clickable,
        splashRadius: 0,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.primary
              : palette.lightgray,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.black
              : palette.white,
        ),
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
      ),

      checkboxTheme: CheckboxThemeData(
        mouseCursor: _clickable,
        splashRadius: 0,
        side: BorderSide(color: palette.unremarked, width: AppSizes.borderThin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.checkboxRadius),
        ),
      ),

      radioTheme: RadioThemeData(mouseCursor: _clickable, splashRadius: 0),

      // El deslizador de Material 3 lleva un tirador con forma de barra y un
      // hueco a cada lado, que es inconfundible. Aquí es un carril fino con un
      // punto, que es lo que hace cualquier aplicación de escritorio.
      sliderTheme: SliderThemeData(
        trackHeight: AppSizes.sliderTrack,
        activeTrackColor: palette.primary,
        inactiveTrackColor: palette.lightgray,
        thumbColor: palette.black,
        overlayColor: Colors.transparent,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: AppSizes.sliderThumb,
        ),
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: const RoundedRectSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.never,
      ),

      // **La barra de desplazamiento.**
      //
      // Hasta ahora no habia ninguna declarada, asi que todas las de la
      // aplicacion eran las de fabrica: gris de Material, ajena a la paleta, y
      // pegada al canto de lo que desplaza — que es lo que hacia que dentro de
      // una superficie redondeada saliera mordida por la curva en sus dos
      // extremos.
      //
      // Aqui es un pulgar con forma de pastilla que **crece al acercarse** y
      // saca el surco por el que corre, y que en reposo se queda en un trazo
      // discreto. Declarada en el tema y no en un widget para que la hereden
      // tambien las que Flutter pone solo en cualquier lista desplazable, que
      // son la mayoria.
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return AppSizes.scrollbarThicknessDragged;
          }
          if (states.contains(WidgetState.hovered)) {
            return AppSizes.scrollbarThicknessHover;
          }

          return AppSizes.scrollbarThickness;
        }),
        radius: const Radius.circular(AppSizes.scrollbarThicknessDragged),
        // El surco solo sale al acercarse: en reposo lo que se ve es el pulgar y
        // nada mas, que es lo que deja la pantalla para el contenido.
        trackVisibility: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.dragged)
                  ? palette.stateLayer
                  : Colors.transparent,
        ),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        crossAxisMargin: AppSizes.scrollbarMargin,
        mainAxisMargin: AppSizes.scrollbarEndInset,
        minThumbLength: AppSizes.scrollbarMinThumb,
        // Al arrastrarla se pinta con el color de la aplicacion: es lo unico que
        // dice, mientras pasa el contenido a toda velocidad, que lo que se esta
        // moviendo es esto y no la rueda del raton.
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) return palette.primary;
          if (states.contains(WidgetState.hovered)) return palette.gray;

          return palette.unremarked;
        }),
        // Se puede coger y arrastrar, no solo mirar.
        interactive: true,
      ),

      // El aviso que sale al dejar el ratón encima: con la superficie y el trazo
      // de la aplicación en vez del rectángulo negro de fábrica, y con una
      // espera antes de salir — en un escritorio el cursor pasa por encima de
      // muchas cosas de camino a otra, y un aviso que salta al instante es un
      // parpadeo detrás de otro.
      tooltipTheme: TooltipThemeData(
        waitDuration: tooltipWait,
        decoration: BoxDecoration(
          color: palette.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: palette.outline,
            width: AppSizes.borderHairline,
          ),
        ),
        textStyle: TextStyle(
          color: palette.black,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
