/// Las fechas que da Pawchive, que no vienen siempre de la misma forma.
///
/// **Por qué esto no es un `DateTime.parse` y ya.** Comprobado contra la API el
/// 2026-08-27, con el mismo creador y el mismo campo:
///
/// ```text
/// /api/v1/creators                      → "updated": 1787774400
/// /api/v1/patreon/user/30500811/profile → "updated": "2026-08-26T20:00:00"
/// ```
///
/// Son el mismo instante. En un sitio es un entero de segundos y en otro una
/// cadena, así que hay que aceptar las dos: cuál llega depende de por dónde se
/// haya preguntado, y eso puede cambiar sin avisar.
///
/// Y la cadena **no lleva zona horaria, pero es UTC** — se ve en que coincide
/// con el entero. `DateTime.parse` lee una cadena sin sufijo como hora **local**,
/// así que dejarla pasar tal cual la desplaza el huso de quien esté delante. En
/// una fecha que se compara con la de la última importación, eso son novedades
/// que aparecen o desaparecen alrededor del cambio de día.
library;

/// La fecha que hay en [value], o `null` si no hay ninguna que valga.
///
/// Acepta un número de segundos desde el epoch (venga como número o como cadena)
/// y una fecha ISO. La ISO sin zona se toma como UTC, que es lo que es.
DateTime? pawchiveTimestamp(Object? value) {
  if (value is num) return _fromEpochSeconds(value);

  if (value is! String) return null;

  final text = value.trim();
  if (text.isEmpty) return null;

  if (num.tryParse(text) case final seconds?) return _fromEpochSeconds(seconds);

  return DateTime.tryParse(_zoned(text));
}

DateTime _fromEpochSeconds(num seconds) {
  return DateTime.fromMillisecondsSinceEpoch(
    (seconds * 1000).round(),
    isUtc: true,
  );
}

/// La misma cadena, diciendo la zona que tiene aunque no la escriba.
///
/// Sólo se le añade a lo que lleva hora: una fecha suelta no la necesita, y
/// `2026-08-26Z` no es nada.
String _zoned(String text) {
  if (!text.contains('T')) return text;
  if (text.endsWith('Z') || text.endsWith('z')) return text;
  if (RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(text)) return text;

  return '${text}Z';
}
