import 'package:equatable/equatable.dart';

/// Con qué colores se pinta la aplicación.
///
/// [system] no es un tema: es dejar que lo diga el sistema operativo, que es lo
/// que hace que la aplicación se ponga de noche a la vez que el resto del
/// escritorio. [custom] tampoco trae colores propios: los pone el usuario en
/// [CustomThemeEntity], y lo que no haya puesto se hereda del tema de fábrica
/// que mejor le encaje.
///
/// Sólo lleva el identificador con el que se guarda: cómo se nombra cada tema es
/// cosa de la pantalla, que lo traduce.
enum AppThemeMode {
  system(id: 'system'),
  light(id: 'light'),
  dark(id: 'dark'),
  custom(id: 'custom');

  const AppThemeMode({required this.id});

  final String id;

  static AppThemeMode fromId(String? id) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.id == id,
      orElse: () => AppThemeMode.system,
    );
  }
}

/// Cada uno de los colores que se pueden cambiar en el tema a medida.
///
/// Es lo que recorre la pantalla de ajustes para pintar un selector por color, y
/// lo que dice el evento de cambio para saber cuál se ha tocado. Sólo lleva el
/// identificador con el que se guarda; el nombre lo pone la pantalla.
enum CustomThemeColor {
  primary(id: 'primary'),
  secondary(id: 'secondary'),
  terciary(id: 'terciary'),
  error(id: 'error'),
  background(id: 'background'),
  surface(id: 'surface'),
  foreground(id: 'foreground');

  const CustomThemeColor({required this.id});

  final String id;
}

/// Los colores que el usuario ha elegido para su tema.
///
/// Van como número (el color entero, con su transparencia) y no como `Color`
/// para que los ajustes se puedan guardar y leer sin saber nada de Flutter; el
/// paso a color lo da la pantalla.
///
/// Nulo es "éste no lo he tocado": ese color se hereda del tema de fábrica del
/// que se parte, así que cambiar sólo el primario no obliga a elegir los otros
/// seis ni deja la aplicación a medio pintar.
class CustomThemeEntity extends Equatable {
  final int? primary;
  final int? secondary;
  final int? terciary;
  final int? error;
  final int? background;

  /// La superficie que se levanta sobre el fondo: diálogos, fichas, menús.
  final int? surface;

  /// Lo que se escribe encima: textos e iconos.
  final int? foreground;

  const CustomThemeEntity({
    this.primary,
    this.secondary,
    this.terciary,
    this.error,
    this.background,
    this.surface,
    this.foreground,
  });

  /// Si el usuario todavía no ha tocado ningún color, que es como nace el tema
  /// a medida: igual que el de fábrica hasta que se cambie algo.
  bool get isEmpty => props.every((color) => color == null);

  /// El color que hay puesto en [slot], o `null` si ése no se ha tocado.
  int? colorOf(CustomThemeColor slot) => switch (slot) {
        CustomThemeColor.primary => primary,
        CustomThemeColor.secondary => secondary,
        CustomThemeColor.terciary => terciary,
        CustomThemeColor.error => error,
        CustomThemeColor.background => background,
        CustomThemeColor.surface => surface,
        CustomThemeColor.foreground => foreground,
      };

  /// Los mismos colores con [color] en [slot]. Con `null` se devuelve ese color
  /// al tema de fábrica, que es lo que hace el botón de restablecer.
  CustomThemeEntity withColor(CustomThemeColor slot, int? color) {
    return CustomThemeEntity(
      primary: slot == CustomThemeColor.primary ? color : primary,
      secondary: slot == CustomThemeColor.secondary ? color : secondary,
      terciary: slot == CustomThemeColor.terciary ? color : terciary,
      error: slot == CustomThemeColor.error ? color : error,
      background: slot == CustomThemeColor.background ? color : background,
      surface: slot == CustomThemeColor.surface ? color : surface,
      foreground: slot == CustomThemeColor.foreground ? color : foreground,
    );
  }

  CustomThemeEntity copyWith({
    int? primary,
    int? secondary,
    int? terciary,
    int? error,
    int? background,
    int? surface,
    int? foreground,
  }) {
    return CustomThemeEntity(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      terciary: terciary ?? this.terciary,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      foreground: foreground ?? this.foreground,
    );
  }

  @override
  List<Object?> get props => [
        primary,
        secondary,
        terciary,
        error,
        background,
        surface,
        foreground,
      ];
}
