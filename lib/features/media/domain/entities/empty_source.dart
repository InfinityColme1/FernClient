import 'package:Fern/features/media/domain/entities/import_source.dart';

/// La fuente no tenía nada que traer, y eso tiene una explicación que conviene
/// dar.
///
/// No es un fallo: es que ahí no había nada. Pero una importación que acaba en
/// cero se ve exactamente igual que una que no ha llegado a funcionar, y el
/// usuario no tiene forma de distinguirlas si nadie se lo dice.
///
/// [hint] es lo que se sabe de *por qué* estaba vacía, cuando se sabe algo
/// accionable. La pantalla lo traduce.
enum EmptySourceHint {
  /// En Pawchive se han pedido las publicaciones marcadas y no hay ninguna,
  /// pero la cuenta sí tiene creadores marcados: casi seguro que lo que el
  /// usuario quería es la otra opción.
  pawchiveHasCreatorsInstead,
}

class EmptySourceException implements Exception {
  final ImportSource source;
  final EmptySourceHint? hint;

  const EmptySourceException(this.source, {this.hint});

  @override
  String toString() => 'There was nothing to import from ${source.id}';
}
