import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Contenido repetido. Llega en la fase 6; por ahora la pantalla existe para que
/// su sitio en el menú lateral no sea un botón que no lleva a ninguna parte.
class RepeatedMediaPage extends StatelessWidget {
  const RepeatedMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: FernEmptyState(
        imageAsset: fernEmptyImage,
        message: AppLocalizations.of(context).navRepeatedMedia,
      ),
    );
  }
}
