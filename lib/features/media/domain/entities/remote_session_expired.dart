import 'package:Fern/features/media/domain/entities/import_source.dart';

/// La plataforma ya no reconoce la sesión guardada.
///
/// Es distinto de que la fuente no esté configurada (eso se ve antes de
/// intentar nada) y distinto de que algo haya ido mal por el camino: aquí la
/// aplicación tiene una sesión, la ha usado y la plataforma la ha rechazado. La
/// única salida es que el usuario vuelva a entrar en su cuenta, así que quien lo
/// enseñe tiene que poder llevarle hasta ahí.
///
/// Va con la fuente a la que le pasa porque la importación puede recorrer
/// varias de una vez: sin ella no se sabría en cuál hay que volver a entrar.
class RemoteSessionExpiredException implements Exception {
  final ImportSource source;

  const RemoteSessionExpiredException(this.source);

  @override
  String toString() => 'The ${source.id} session is no longer valid';
}
