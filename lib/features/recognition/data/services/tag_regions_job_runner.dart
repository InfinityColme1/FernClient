import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:Fern/features/recognition/domain/services/frame_sampling.dart';

/// Cuánto dura un contenido que se mueve, o `null` si no se sabe.
typedef DurationOf = Future<Duration?> Function(String path);

/// Marca **todo el contenido de una etiqueta** como regiones de un fernie.
///
/// Para qué: un fernie se entrena con regiones, y montar uno desde cero era
/// abrir contenido a contenido y marcar el fotograma entero en cada uno. Cuando
/// la etiqueta ya dice de qué va todo lo que lleva —«ladybug» en doscientas
/// imágenes de ladybug—, ese trabajo es mecánico y se puede pedir de una vez.
///
/// Va por la cola de trabajos y no en la pantalla: doscientos vídeos son
/// doscientas aperturas de fichero para saber cuánto duran, y eso no puede
/// dejar la interfaz esperando ni perderse al cambiar de pantalla.
///
/// **No pone la etiqueta ni el creador.** A diferencia de marcar una región a
/// mano, aquí el contenido ya viene de una etiqueta: volver a ponérsela no
/// añadiría nada, y poner encima lo que el fernie enlace sería etiquetar
/// doscientos contenidos por un gesto que pedía otra cosa.
class TagRegionsJobRunner {
  final LocalMediaRepository _media;
  final FernieRepository _fernies;
  final DurationOf _durationOf;

  /// A quién avisar de que ya está, para que la pantalla se entere.
  ///
  /// El trabajo corre en la cola, así que quien lo pidió puede estar mirando la
  /// ficha del fernie mientras tanto: sin este aviso las regiones aparecían en
  /// la base pero no en la rejilla, y había que salir de la pantalla y volver.
  final Future<void> Function(int fernieId)? _onFinished;

  TagRegionsJobRunner({
    required LocalMediaRepository media,
    required FernieRepository fernies,
    required DurationOf durationOf,
    Future<void> Function(int fernieId)? onFinished,
  })  : _media = media,
        _fernies = fernies,
        _durationOf = durationOf,
        _onFinished = onFinished;

  /// De qué fernie son las regiones.
  static const fernieKey = 'fernie';

  /// De qué etiqueta sale el contenido.
  static const tagKey = 'tag';

  /// Cuántos fotogramas se marcan de lo que se mueve.
  static const samplesKey = 'samples';

  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final fernieId = context.payload<int>(fernieKey);
    final tagId = context.payload<int>(tagKey);
    if (fernieId == null || tagId == null) return;

    final samples = context.payload<int>(samplesKey) ?? defaultFrameSamples;

    final found = await _media.getMediaByTag(tagId);
    final all = found.data ?? const <MediaSummaryEntity>[];
    if (all.isEmpty) return;

    // Lo que este fernie ya tiene marcado, por contenido y fotograma. Se lee una
    // vez: preguntarlo por contenido serían doscientas consultas para saltarse
    // lo que ya estaba.
    final already = await _markedAlready(fernieId);

    context.report(0, total: all.length);

    var done = 0;
    final pending = <FernieRegionEntity>[];

    for (final summary in all) {
      if (context.token.isCancelled) break;

      for (final frameMs in await _framesOf(summary.path, samples)) {
        if (already.contains((summary.id, frameMs))) continue;

        pending.add(FernieRegionEntity(
          id: unsavedId,
          mediaId: summary.id,
          fernieId: fernieId,
          // El fotograma entero: lo que dice la etiqueta es que ahí sale esto,
          // no dónde sale. Recortarlo a ojo sería inventarse un dato.
          x: 0,
          y: 0,
          w: 1,
          h: 1,
          frameMs: frameMs,
        ));
      }

      context.report(++done);

      // Por tandas y no todo al final: con un tag de miles de contenidos, una
      // sola escritura al terminar significa tenerlo todo en memoria y que
      // cancelar a mitad no deje nada. Así lo hecho está hecho.
      if (pending.length >= tagRegionsBatchSize) {
        await _write(pending);
        pending.clear();
      }
    }

    if (pending.isNotEmpty) await _write(pending);

    // Se avisa también si se ha parado a mitad: lo escrito hasta ahí está
    // escrito, y la pantalla tiene que enseñarlo igual.
    await _onFinished?.call(fernieId);
  }

  /// Los pares contenido-fotograma que este fernie ya tiene marcados.
  Future<Set<(int, int?)>> _markedAlready(int fernieId) async {
    final result = await _fernies.getRegionsOfFernie(fernieId);

    return {
      for (final region in result.data ?? const <FernieRegionEntity>[])
        (region.mediaId, region.frameMs),
    };
  }

  /// Qué fotogramas se marcan de un contenido.
  ///
  /// Una imagen es ella misma, y va con `frameMs` nulo porque en una imagen el
  /// fotograma no significa nada. Lo que se mueve se muestrea: **el conjunto de
  /// entrenamiento saca una imagen por región**, así que «todos los fotogramas»
  /// de un vídeo de tres minutos serían miles de recortes casi idénticos y un
  /// entrenamiento inviable.
  Future<List<int?>> _framesOf(String path, int samples) async {
    if (!path.isVideoPath && !path.isGifPath) return const [null];

    final duration = await _durationOf(path);

    // Sin saber cuánto dura no se puede repartir nada: se marca el principio,
    // que es mejor que dejarlo fuera.
    if (duration == null || duration <= Duration.zero) return const [0];

    return [
      for (final at in sampleFrames(duration: duration, count: samples))
        at.inMilliseconds,
    ];
  }

  Future<void> _write(List<FernieRegionEntity> regions) async {
    if (regions.isEmpty) return;

    await _fernies.addRegions(List.of(regions));
  }
}
