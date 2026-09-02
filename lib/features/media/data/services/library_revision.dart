import 'dart:async';

import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:isar/isar.dart';

/// Por qué versión va la biblioteca.
///
/// Un número que sube cada vez que se escribe algo del contenido. No dice
/// **qué** ha cambiado ni le hace falta: sirve para una sola pregunta, la que se
/// hace al abrir la pantalla de la biblioteca — «¿ha cambiado algo desde la
/// última vez que la leí?».
///
/// Con una biblioteca grande, releerla entera es de lo poco que se nota al
/// cambiar de pantalla, y la mayoría de las veces no hace ninguna falta: se sale
/// a importar, se vuelve, y es exactamente la misma.
///
/// **Se entera por Isar y no por quien escribe**, y esa es toda la gracia. Un
/// contador que hubiera que subir a mano en cada método que guarda algo se
/// olvidaría un día en uno, y ese día la pantalla enseñaría una biblioteca vieja
/// sin un solo error por medio — la peor forma posible de fallar. Escuchando a
/// la base, no hay forma de escribir sin que se entere.
///
/// Y **no todo lo que cambia la biblioteca pasa por la base**: abrir o cerrar el
/// bloqueo NSFW no escribe nada y sin embargo cambia qué se puede enseñar. Eso
/// entra por [visibilityChanges] y por [bump]; sin ello, volver a la biblioteca
/// después de cerrar el bloqueo devolvía la guardada — con el contenido
/// escondido todavía dentro.
class LibraryRevision {
  int _value = 0;

  final List<StreamSubscription<void>> _watchers = [];

  LibraryRevision({Isar? database, Stream<void>? visibilityChanges}) {
    // Abrir y cerrar el bloqueo no escribe nada, así que Isar no se entera; y
    // cambia la biblioteca entera.
    if (visibilityChanges != null) {
      _watchers.add(visibilityChanges.listen((_) => _value++));
    }

    if (database == null) return;

    // Los dos sitios donde vive un contenido: el sumario —lo que la rejilla
    // enseña— y sus detalles, de donde salen el orden y las etiquetas.
    _watchers.addAll([
      database.mediaSummaryModels.watchLazy().listen((_) => _value++),
      database.mediaModels.watchLazy().listen((_) => _value++),
    ]);
  }

  int get value => _value;

  /// Da la biblioteca por cambiada sin que nadie haya escrito.
  ///
  /// Para lo que cambia fuera de la base y aun así cambia lo que hay que
  /// enseñar: lo rehace el índice del bloqueo cada vez que se marca algo, que
  /// puede esconder o devolver contenido sin tocar ninguna fila de contenido.
  void bump() => _value++;

  Future<void> dispose() async {
    for (final watcher in _watchers) {
      await watcher.cancel();
    }
    _watchers.clear();
  }
}
