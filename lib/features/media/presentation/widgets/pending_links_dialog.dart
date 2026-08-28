import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

/// Lo que una importación ha dejado sin traerse porque hacía falta el usuario.
///
/// Son sitios de descargas (Mega, Pixeldrain y compañía) a los que no se puede
/// entrar solo: tienen su propia espera, su captcha o su listado de ficheros.
///
/// **Uno para toda la importación, y al final.** Antes cada publicación abría el
/// suyo según iba llegando, sin esperar a que se cerrara el anterior: doscientas
/// publicaciones eran doscientos diálogos apilados, y cerrarlos era el trabajo.
/// Aquí están todas, se mira la que interese y se cierra una vez.
class PendingLinksDialog extends StatelessWidget {
  final List<PendingLinkPost> posts;

  const PendingLinksDialog({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.pendingLinksTitle(posts.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            texts.pendingLinksDescription,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.m),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, index) => _post(context, posts[index]),
            ),
          ),
        ],
      ),
    );
  }

  /// Una publicación con los enlaces que dejó pendientes.
  Widget _post(BuildContext context, PendingLinkPost post) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title.isEmpty ? texts.linkChoiceUntitledPost : post.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          for (final link in post.links) _link(context, link),
        ],
      ),
    );
  }

  Widget _link(BuildContext context, PostLink link) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Se dice cuál es cuál: una carpeta hay que mirarla y elegir, y un fichero
    // suelto es entrar y bajarlo. No es lo mismo de hacer.
    final isFolder = link.kind == PostLinkKind.repositoryFolder;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isFolder ? Symbols.folder_open : Symbols.insert_drive_file,
            size: AppSizes.iconCompact,
            color: context.colors.gray,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              link.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            isFolder ? texts.pendingLinksFolder : texts.pendingLinksFile,
            style:
                theme.textTheme.labelSmall?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            tooltip: texts.linkChoiceOpen,
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.go(browserRouteWithUrl(link.url));
            },
            icon: const Icon(Symbols.open_in_new, size: AppSizes.iconCompact),
          ),
        ],
      ),
    );
  }
}
