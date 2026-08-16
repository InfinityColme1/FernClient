import 'package:Fern/core/navigation/app_router.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/widgets/link_choice_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/repository_link_dialog.dart';
import 'package:flutter/widgets.dart';

/// Le pregunta al usuario con diálogos lo que una importación no puede decidir
/// sola.
///
/// No cuelga de ninguna pantalla: se engancha al navegador de la aplicación
/// entera, así que la pregunta aparece esté el usuario donde esté. Una
/// importación puede durar mucho y mientras tanto se puede estar mirando otra
/// cosa, o incluso otro programa; cuando vuelva, la pregunta le estará
/// esperando.
///
/// Si en ese momento no hay ninguna pantalla montada (la aplicación está
/// arrancando o cerrándose), no se puede preguntar: se responde por lo más
/// prudente, que es no traerse nada.
class DialogImportDecisions implements ImportDecisionHandler {
  const DialogImportDecisions();

  BuildContext? get _context =>
      appRouter.routerDelegate.navigatorKey.currentContext;

  @override
  Future<LinkChoice> chooseLinks(String postTitle, List<PostLink> links) async {
    final context = _context;
    if (context == null) return const LinkChoice.ignore();

    // Sin poder cerrarlo por fuera: la importación está parada esperando esta
    // respuesta, así que se contesta a propósito y no de un clic al aire.
    final answer = await showFernDialog<LinkChoice, MediaBloc>(
      context: context,
      barrierDismissible: false,
      bloc: getIt<MediaBloc>(),
      builder: (_) => LinkChoiceDialog(postTitle: postTitle, links: links),
    );

    return answer ?? const LinkChoice.ignore();
  }

  @override
  Future<void> noticeRepository(String postTitle, List<PostLink> links) async {
    final context = _context;
    if (context == null) return;

    await showFernDialog<void, MediaBloc>(
      context: context,
      bloc: getIt<MediaBloc>(),
      builder: (_) => RepositoryLinkDialog(postTitle: postTitle, links: links),
    );
  }
}
