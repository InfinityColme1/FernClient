import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:equatable/equatable.dart';

/// Cómo salió el último entrenamiento.
///
/// Las métricas se guardan **en crudo** tal y como las devolvió el sidecar
/// —cambian con la versión de ultralytics—, así que alguien tiene que traducir
/// ese JSON a algo que se pueda pintar. Ese alguien es esto, y es puro a
/// propósito: se prueba sin motor, sin disco y sin pantalla.
///
/// Todo es opcional porque todo puede faltar: un modelo entrenado con una
/// versión anterior, un JSON a medias de un fallo, o unos pesos traídos de fuera
/// que nunca pasaron por aquí. Lo que no se sabe no se enseña, que es distinto
/// de enseñar un cero.
class TrainingMetrics extends Equatable {
  /// Lo que se acierta con el listón de solapamiento en el 50 %. Es la cifra que
  /// se mira primero.
  final double? map50;

  /// La media de listones del 50 al 95 %. Más severa y más honesta.
  final double? map50to95;

  final double? precision;
  final double? recall;

  /// El acierto de cada clase, por nombre.
  ///
  /// Es lo que dice **cuál** de los fernies ha salido mal: la media general
  /// puede ser buena teniendo una clase que no reconoce nada.
  final Map<String, double> perClass;

  /// La carpeta de la run, donde ultralytics deja las imágenes de la matriz de
  /// confusión y las curvas.
  final String? curvesDirectory;

  final Duration? elapsed;

  const TrainingMetrics({
    this.map50,
    this.map50to95,
    this.precision,
    this.recall,
    this.perClass = const {},
    this.curvesDirectory,
    this.elapsed,
  });

  /// Si hay algo que enseñar.
  ///
  /// Un modelo entrenado con una versión que no daba métricas deja el bloque
  /// vacío en vez de una fila de ceros, que sería mentir.
  bool get isEmpty =>
      map50 == null &&
      map50to95 == null &&
      precision == null &&
      recall == null &&
      perClass.isEmpty;

  /// Las clases que se han quedado por debajo del listón, de peor a mejor.
  ///
  /// Sirven para el aviso: un modelo con buena media y un fernie a 0,3 va a
  /// fallar justo con ese, y eso no se ve en la media.
  List<MapEntry<String, double>> get weakClasses {
    final weak = perClass.entries
        .where((entry) => entry.value < weakClassThreshold)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return weak;
  }

  /// Lee lo que devolvió el sidecar.
  ///
  /// Nunca lanza: esto se llama al pintar una pantalla, y un JSON raro de un
  /// entrenamiento viejo no puede dejar la pantalla en blanco. Lo que no se
  /// entienda se queda en `null`.
  static TrainingMetrics? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    Object? decoded;

    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }

    if (decoded is! Map) return null;

    final seconds = _number(decoded['elapsed_seconds']);

    return TrainingMetrics(
      map50: _number(decoded['map50']),
      map50to95: _number(decoded['map50_95']),
      precision: _number(decoded['precision']),
      recall: _number(decoded['recall']),
      perClass: _perClass(decoded['per_class']),
      curvesDirectory: _text(decoded['curves_dir']),
      elapsed: seconds == null ? null : Duration(seconds: seconds.round()),
    );
  }

  /// Un número, venga como venga.
  ///
  /// Python manda enteros cuando la cifra es redonda y JSON no distingue, así
  /// que `1` y `1.0` son lo mismo. Los que no son número se descartan en vez de
  /// convertirse en cero.
  static double? _number(Object? value) {
    final number = value is num ? value : double.tryParse('$value');

    // Un `NaN` o un infinito pintarían una barra de ancho imposible. Llegan
    // tanto como número como en texto: `double.tryParse` entiende «Infinity».
    if (number == null || number.isNaN || number.isInfinite) return null;

    return number.toDouble();
  }

  static String? _text(Object? value) {
    if (value is! String) return null;

    return value.trim().isEmpty ? null : value;
  }

  static Map<String, double> _perClass(Object? value) {
    if (value is! Map) return const {};

    final parsed = <String, double>{};

    for (final entry in value.entries) {
      final number = _number(entry.value);
      if (number != null) parsed['${entry.key}'] = number;
    }

    return parsed;
  }

  @override
  List<Object?> get props => [
        map50,
        map50to95,
        precision,
        recall,
        perClass,
        curvesDirectory,
        elapsed,
      ];
}
