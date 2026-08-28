import 'package:Fern/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Las paletas de la aplicación y cómo se llega a la que está puesta.
///
/// Los colores no se leen de aquí: se leen del tema, con `context.colors`. Aquí
/// sólo están las paletas de fábrica (la clara y la oscura) y la receta con la
/// que se arma la del usuario.
class AppColors {
  const AppColors._();

  /// Cuánto se acerca al color del texto una superficie levantada sobre otra.
  ///
  /// Poco a propósito: lo justo para que se vea que hay dos capas y no tanto como
  /// para que parezca otro color.
  static const raisedSurfaceBlend = 0.06;

  /// La paleta de siempre de la aplicación.
  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFFE8DEF8),
    secondary: Color(0xFFF5EEFF),
    terciary: Color(0xFFFF87B3),
    // El mismo rosa del acento: es con el que la aplicación ha marcado siempre
    // lo que borra, así que el color de error nace siendo el que ya se usaba.
    error: Color(0xFFFF87B3),
    background: Color(0xFFF7F4F9),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF1D1B20),
    gray: Color(0xFF49454F),
    // Un escalón por debajo de [gray] y no el mismo color: eran idénticos, así
    // que «texto que acompaña» y «dato de relleno» se leían con el mismo peso y
    // la jerarquía de la pantalla se perdía justo donde más letra pequeña hay.
    unremarked: Color(0xFF79747E),
    lightgray: Color(0xFFCAC4D0),
    // Los tres se pintan con transparencia sobre lo que haya debajo, así que son
    // el mismo tono del texto rebajado: se apoyan en el fondo que tengan en vez
    // de traer un color propio que habría que mantener a juego.
    outline: Color(0x171D1B20),
    surfaceRaised: Color(0xFFFFFFFF),
    stateLayer: Color(0x0F1D1B20),
    scrim: Color(0xFF1D1B20),
  );

  /// La misma aplicación de noche.
  ///
  /// No es la paleta clara invertida: el lavanda claro sobre un fondo oscuro no
  /// se lee ni se distingue de un texto, así que el primario baja a un lavanda
  /// profundo y lo que se escribe encima de él sube. El acento se queda como
  /// está: el rosa funciona igual sobre claro que sobre oscuro, y es lo que hace
  /// que la aplicación se siga reconociendo.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF4F378B),
    secondary: Color(0xFF2B2930),
    terciary: Color(0xFFFF87B3),
    error: Color(0xFFFF87B3),
    background: Color(0xFF141218),
    white: Color(0xFF211F26),
    black: Color(0xFFE6E0E9),
    gray: Color(0xFFCAC4D0),
    unremarked: Color(0xFF938F99),
    lightgray: Color(0xFF49454F),
    // De noche hace falta algo más de trazo y algo más de velo: sobre oscuro, la
    // misma transparencia se ve bastante menos.
    outline: Color(0x24E6E0E9),
    // Y aquí el escalón sí existe: sobre fondo oscuro, lo que se levanta se
    // aclara. En el tema claro no hay nada más claro que el blanco, así que allí
    // el escalón lo da el trazo.
    surfaceRaised: Color(0xFF2C2A31),
    stateLayer: Color(0x1AE6E0E9),
    scrim: Color(0xFF000000),
  );

  /// La paleta del usuario: la de fábrica que mejor le encaje con sus colores
  /// puestos encima.
  ///
  /// De partida se parte de la clara o de la oscura según lo oscuro que sea el
  /// fondo que haya elegido. Eso es lo que mantiene la aplicación legible
  /// aunque sólo se cambie un color: los grises de los textos secundarios, los
  /// bordes y los separadores no se eligen, se heredan del lado (claro u oscuro)
  /// en el que el usuario se haya puesto.
  static AppPalette custom({
    Color? primary,
    Color? secondary,
    Color? terciary,
    Color? error,
    Color? background,
    Color? surface,
    Color? foreground,
  }) {
    final base = (background ?? light.background).computeLuminance() < 0.5
        ? dark
        : light;

    final chosen = base.copyWith(
      primary: primary,
      secondary: secondary,
      terciary: terciary,
      error: error,
      background: background,
      white: surface,
      black: foreground,
    );

    // El trazo, el velo y la superficie levantada **no se eligen**: se sacan de
    // lo que el usuario ya ha elegido. Son tres papeles que tienen que estar a
    // juego con su fondo y con su texto, y pedirlos aparte sería pedirle que
    // acierte tres veces con algo que sólo se nota cuando está mal.
    return chosen.copyWith(
      outline: chosen.black.withValues(alpha: base.isDark ? 0.14 : 0.09),
      stateLayer: chosen.black.withValues(alpha: base.isDark ? 0.10 : 0.06),
      // Lo que se levanta se separa del fondo yendo hacia el color del texto: de
      // noche eso aclara y de día no hay hacia dónde ir, que es justo por lo que
      // en claro el escalón lo da el trazo.
      surfaceRaised: base.isDark
          ? Color.lerp(chosen.white, chosen.black, raisedSurfaceBlend)!
          : chosen.white,
    );
  }

  /// La paleta que está puesta. Si el tema no llevara ninguna (no debería
  /// pasar), la aplicación se pinta con la de siempre en lugar de romperse.
  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;
}

/// Atajo para llegar a la paleta desde cualquier pantalla: `context.colors`.
extension AppColorsContext on BuildContext {
  AppPalette get colors => AppColors.of(this);
}
