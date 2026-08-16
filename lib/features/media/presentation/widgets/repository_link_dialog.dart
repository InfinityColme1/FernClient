import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Una publicación lleva a un sitio de descargas (Mega, Pixeldrain y
/// compañía).
///
/// Eso no se puede recorrer solo: son páginas con su propia espera, su captcha
/// o su listado de ficheros, así que lo único honesto es decirlo y ofrecer ir.
///
/// **La importación no espera a este aviso**: sigue por su cuenta mientras el
/// usuario lo lee, lo cierra o se va al navegador.
class RepositoryLinkDialog extends StatelessWidget {
  final String postTitle;
  final List<PostLink> links;

  const RepositoryLinkDialog({
    super.key,
    required this.postTitle,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.repositoryLinkTitle(links.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            postTitle.isEmpty ? texts.linkChoiceUntitledPost : postTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            texts.repositoryLinkDescription,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.m),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_outlined,
                    size: AppSizes.iconCompact,
                    color: AppColors.gray,
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
                ],
              ),
            ),
        ],
      ),
      actionButton: FernPillButton(
        label: texts.repositoryLinkOpen,
        icon: Icons.travel_explore_outlined,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () {
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.go(browserRouteWithUrl(links.first.url));
        },
      ),
    );
  }
}
