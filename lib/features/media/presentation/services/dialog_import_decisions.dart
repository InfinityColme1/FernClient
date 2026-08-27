import 'dart:async';

import 'package:Fern/core/navigation/app_router.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/notifications/data/services/notification_service.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/media/data/services/pending_link_reviews.dart';
import 'package:Fern/features/media/data/services/link_import_job_runner.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/widgets/link_choice_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/pending_links_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Le pregunta al usuario con diálogos lo que una importación no puede decidir
/// sola.
///
/// No cuelga de ninguna pantalla: se engancha al navegador de la aplicación
/// entera, así que la pregunta aparece esté el usuario donde esté. Una
/// importación puede durar mucho y mientras tanto se puede estar mirando otra
/// cosa, o incluso otro programa; cuando vuelva, la pregunta le estará
/// esperando.
///
/// **Nunca hay dos a la vez.** Lo que llega mientras hay uno abierto espera su
/// turno: una importación grande podía apilar decenas de diálogos, cada uno
/// tapando al anterior, y cerrarlos acababa siendo el trabajo.
///
/// Si en ese momento no hay ninguna pantalla montada (la aplicación está
/// arrancando o cerrándose), no se puede preguntar: se responde por lo más
/// prudente, que es no traerse nada.
class DialogImportDecisions implements ImportDecisionHandler {
  const DialogImportDecisions();

  BuildContext? get _context =>
      appRouter.routerDelegate.navigatorKey.currentContext;

  /// El turno del que esté enseñando algo ahora mismo.
  ///
  /// Uno solo para toda la aplicación: quien quiera enseñar algo espera a que el
  /// anterior se cierre.
  static Future<void> _turn = Future<void>.value();

  static Future<T?> _inTurn<T>(Future<T?> Function() show) {
    final mine = _turn.then((_) => show());

    // La cola no se puede romper porque uno falle: si se rompiera, el siguiente
    // no llegaría a enseñarse nunca.
    _turn = mine.then((_) {}, onError: (_) {});

    return mine;
  }

  /// Aparca una publicación con enlaces como una tarea.
  ///
  /// **Ni enseña nada ni espera a nadie.** El diálogo se abría al momento y
  /// paraba la importación hasta que alguien lo contestara; y se perdía al
  /// pulsar «ver en el navegador», porque cambiar de pantalla se lo llevaba por
  /// delante. La importación se quedaba entonces esperando una respuesta que ya
  /// no se podía dar.
  ///
  /// Ahora sale como una tarea más de la lista. Se abre cuando al usuario le
  /// venga bien —después de mirar los enlaces, o al día siguiente—, y quitarla
  /// de la lista es decir que no interesa.
  @override
  void parkLinks(LinkReviewRequest request) {
    final id = getIt<JobQueue>().enqueue(
      type: JobType.linkReview,
      priority: JobPriority.normal,
      payload: {Job.nameKey: request.postTitle},
    );

    getIt<PendingLinkReviews>().add(LinkReview(
      jobId: id,
      postTitle: request.postTitle,
      links: request.links,
      source: request.source,
      namePrefix: request.namePrefix,
      sourceUrls: request.sourceUrls,
    ));

    // Y se avisa: la importación ya no espera, así que sin aviso la pregunta se
    // quedaría en la lista sin que nadie supiera que está ahí. El contador
    // cuenta **preguntas sin contestar**, no veces que se ha preguntado.
    unawaited(getIt<NotificationService>().notify(
      NotificationKind.linkReview,
      count: getIt<PendingLinkReviews>().length,
    ));
  }

  /// Abre la pregunta que quedó aparcada en [jobId] y hace lo que se conteste.
  ///
  /// Lo que Fern sabe bajar solo se lo trae en su propia tarea; lo que necesita
  /// al usuario —una carpeta de Mega, un sitio con captcha— se abre en el
  /// navegador, que es lo único que se puede hacer con ello.
  static Future<void> openReview(BuildContext context, String jobId) async {
    final review = getIt<PendingLinkReviews>().of(jobId);
    if (review == null) return;

    final answer = await showFernDialog<LinkChoice, MediaBloc>(
      context: context,
      bloc: getIt<MediaBloc>(),
      builder: (_) => LinkChoiceDialog(
        postTitle: review.postTitle,
        links: review.links,
      ),
    );

    if (answer == null) return;

    // Lo que valga para todo se recuerda: a partir de ahí las publicaciones que
    // queden por mirar se resuelven solas y dejan de aparcarse.
    if (answer.applyToAll) getIt<ImportDecisions>().applyToEverything(answer);

    final chosen = [
      for (final link in review.links)
        if (answer.accepts(link) && link.isDownloadable) link,
    ];

    // Contestada es contestada: la tarea se va de la lista tanto si había algo
    // que traerse como si no. Primero se cierra —una que espera sigue contando
    // como viva— y después se quita.
    getIt<PendingLinkReviews>().remove(jobId);
    getIt<JobQueue>()
      ..cancel(jobId)
      ..dismiss(jobId);

    if (chosen.isEmpty) return;

    getIt<JobQueue>().enqueue(
      type: JobType.linkImport,
      priority: JobPriority.high,
      payload: {
        Job.nameKey: review.postTitle,
        LinkImportJobRunner.urlsKey: [
          for (final link in chosen) link.downloadUrl,
        ],
        LinkImportJobRunner.archivesKey: [
          for (final (index, link) in chosen.indexed)
            if (link.kind == PostLinkKind.archive) index,
        ],
        LinkImportJobRunner.sourceKey: review.source.id,
        LinkImportJobRunner.prefixKey: review.namePrefix,
        LinkImportJobRunner.descriptionKey: review.postTitle,
        LinkImportJobRunner.sourceUrlsKey: review.sourceUrls,
      },
    );
  }

  /// El resumen de lo que quedó sin traerse, al terminar la importación.
  ///
  /// No es un diálogo sino un aviso breve que lleva a él: es un resumen, no una
  /// pregunta, y el usuario puede estar mirando otra cosa. Quien quiera verlo lo
  /// pulsa; quien no, lo deja irse solo.
  @override
  Future<void> showPendingLinks(List<PendingLinkPost> posts) async {
    if (posts.isEmpty) return;

    final context = _context;
    if (context == null) return;

    final texts = AppLocalizations.of(context);

    showFernToast(
      context,
      texts.pendingLinksToast(posts.length),
      icon: Icons.cloud_outlined,
      onTap: () => unawaited(_openPendingLinks(posts)),
    );
  }

  Future<void> _openPendingLinks(List<PendingLinkPost> posts) {
    return _inTurn<void>(() async {
      final context = _context;
      if (context == null) return null;

      return showFernDialog<void, MediaBloc>(
        context: context,
        bloc: getIt<MediaBloc>(),
        builder: (_) => PendingLinksDialog(posts: posts),
      );
    });
  }
}
