import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/data/services/recognition_launcher.dart';
import 'package:Fern/features/recognition/domain/usecases/can_recognize_usecase.dart';
import 'package:Fern/features/recognition/presentation/widgets/confirm_recognition_dialog.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Manda a reconocer y cuenta en qué ha quedado.
///
/// Los cuatro puntos de entrada del D16 pasan por aquí para que digan **lo
/// mismo**. No es una manía de no repetirse: encolar no se ve por ningún lado
/// —la lista de tareas sólo cambia cuando el trabajo arranca, que puede ser
/// dentro de un rato— y no poder encolar tampoco, así que sin contarlo las dos
/// cosas se parecen a que el botón esté roto. Ya pasó una vez.
///
/// [name] es cómo se llama el trabajo en la lista de tareas: «Etiqueta Ladybug»
/// dice mucho más que «Reconocimiento» cuando hay tres en marcha.
Future<RecognitionRequest> requestRecognition(
  BuildContext context,
  List<int> mediaIds, {
  String? name,
}) async {
  // Antes de nada, avisar de que van a salir de la biblioteca. El efecto
  // sorprende: quien manda veinte contenidos vuelve a la rejilla y se los
  // encuentra vacíos sin nada que lo explique.
  if (!await _confirmReturnToReview(context, mediaIds.length)) {
    return const RecognitionRequest(
      outcome: RecognitionOutcome.cancelled,
      readiness: RecognitionReadiness.ready,
    );
  }

  if (!context.mounted) {
    return const RecognitionRequest(
      outcome: RecognitionOutcome.cancelled,
      readiness: RecognitionReadiness.ready,
    );
  }

  final request = await getIt<RecognitionLauncher>().request(
    mediaIds,
    name: name,
  );

  if (!context.mounted || request.outcome == RecognitionOutcome.cancelled) {
    return request;
  }

  showFernToast(
    context,
    recognitionMessage(AppLocalizations.of(context), request),
    icon: request.isQueued ? Icons.info_outline : Icons.error_outline_rounded,
  );

  return request;
}

/// Pregunta antes de sacar contenido de la biblioteca, si es que va a salir.
///
/// Con el ajuste apagado no hay nada que avisar, y con dos o tres contenidos el
/// efecto se ve y se deshace en un momento. El aviso es para el lote grande, no
/// para pedir permiso en cada pulsación.
Future<bool> _confirmReturnToReview(BuildContext context, int count) async {
  if (count < recognitionReturnWarningCount) return true;

  final settings = getIt<SettingsRepository>().getSettings();
  if (!settings.returnRecognizedToImport) return true;

  final confirmed = await showFernDialog<bool, SettingsBloc>(
    context: context,
    builder: (_) => ConfirmRecognitionDialog(count: count),
  );

  return confirmed ?? false;
}

/// Qué contarle al usuario, dicho de forma que se pueda arreglar.
///
/// Los motivos por los que no se puede reconocer se parecen desde fuera —no pasa
/// nada— y piden cosas distintas: meter un modelo en el árbol, entrenarlo, o
/// elegir algo primero. Juntarlos en un «no se ha podido» deja al usuario sin
/// saber qué hacer.
String recognitionMessage(AppLocalizations l10n, RecognitionRequest request) {
  return switch (request.outcome) {
    RecognitionOutcome.queued => l10n.recognizeQueuedCount(request.count),
    // Cancelar no es un fallo ni hace falta contarlo: acaba de decir que no.
    RecognitionOutcome.cancelled => '',
    RecognitionOutcome.nothingToRecognize => l10n.recognizeNothingToDo,
    RecognitionOutcome.notReady => switch (request.readiness) {
        RecognitionReadiness.noModelsInTree => l10n.recognizeNoModelsInTree,
        RecognitionReadiness.noTrainedModels => l10n.recognizeNoTrainedModels,
        _ => l10n.recognizeUnavailable,
      },
  };
}
