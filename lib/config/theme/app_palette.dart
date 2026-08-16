import 'package:flutter/material.dart';

/// Los colores de la aplicación, viajando dentro del tema.
///
/// Va como extensión de [ThemeData] y no como constantes sueltas porque los
/// colores ya no son uno solo: hay tema claro, tema oscuro y el que se monte el
/// usuario. Al ir por el tema, cualquier pantalla que los lea se repinta sola en
/// cuanto se cambia de tema, sin tener que enterarse de nada.
///
/// Los nombres son papeles, no colores literales: [black] es "lo que se escribe
/// encima del fondo" y [white] es "la superficie que se levanta sobre el fondo",
/// así que en el tema oscuro [black] es casi blanco y [white] es casi negro. Lo
/// que sí es literal es [scrim], que siempre oscurece porque siempre se pone
/// sobre contenido (una miniatura, una foto a pantalla completa) y ahí no hay
/// tema que valga.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Si el tema es claro u oscuro. Lo necesita Flutter para lo que pinta él
  /// (los cursores, los menús del sistema, la barra de estado).
  final Brightness brightness;

  /// El color con el que la aplicación se reconoce: el fondo de los botones
  /// principales y de lo que está seleccionado.
  final Color primary;

  /// El apoyo del primario: fondos suaves (el buscador, la columna de ajustes,
  /// los avatares sin imagen).
  final Color secondary;

  /// El acento con el que la aplicación llama la atención: los favoritos, los
  /// enlaces, las esperas.
  final Color terciary;

  /// Lo que va mal y lo que destruye: los botones de borrar y los avisos.
  final Color error;

  /// El fondo de la aplicación.
  final Color background;

  /// La superficie que se levanta sobre el fondo: diálogos, fichas, menús
  /// desplegables.
  final Color white;

  /// Lo que se escribe y se dibuja sobre el fondo y sobre las superficies.
  final Color black;

  /// Texto de segunda: notas, descripciones, lo que acompaña sin mandar.
  final Color gray;

  /// Lo que está ahí pero no pide nada: contadores, datos de relleno.
  final Color unremarked;

  /// Bordes, separadores y lo que está desactivado.
  final Color lightgray;

  /// El oscurecido que se pone sobre el contenido (las miniaturas, la barra del
  /// visor, los avisos breves). Siempre oscuro: debajo hay una imagen, no una
  /// superficie de la aplicación.
  final Color scrim;

  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.terciary,
    required this.error,
    required this.background,
    required this.white,
    required this.black,
    required this.gray,
    required this.unremarked,
    required this.lightgray,
    required this.scrim,
  });

  bool get isDark => brightness == Brightness.dark;

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? primary,
    Color? secondary,
    Color? terciary,
    Color? error,
    Color? background,
    Color? white,
    Color? black,
    Color? gray,
    Color? unremarked,
    Color? lightgray,
    Color? scrim,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      terciary: terciary ?? this.terciary,
      error: error ?? this.error,
      background: background ?? this.background,
      white: white ?? this.white,
      black: black ?? this.black,
      gray: gray ?? this.gray,
      unremarked: unremarked ?? this.unremarked,
      lightgray: lightgray ?? this.lightgray,
      scrim: scrim ?? this.scrim,
    );
  }

  /// El paso de una paleta a otra. Flutter lo usa al cambiar de tema para que la
  /// aplicación no dé un salto de color de golpe.
  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;

    return AppPalette(
      // La claridad no se mezcla: a mitad de camino el tema ya es el nuevo, y de
      // ella dependen cosas que no son colores.
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      terciary: Color.lerp(terciary, other.terciary, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      unremarked: Color.lerp(unremarked, other.unremarked, t)!,
      lightgray: Color.lerp(lightgray, other.lightgray, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
