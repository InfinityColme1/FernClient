import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// La columna de la izquierda de los ajustes: el título y una fila por sección.
///
/// Va aparte del diálogo, y sin bloc, por dos motivos: se puede montar sola para
/// comprobar que cabe —que es lo que puede fallar aquí, porque las secciones se
/// van añadiendo y la ventana tiene un alto mínimo— y porque lo único que sabe
/// es cuál está elegida y a quién avisar cuando se elige otra.
class SettingsSectionList extends StatelessWidget {
  final SettingsSection selected;
  final ValueChanged<SettingsSection> onSelected;

  const SettingsSectionList({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.settingsNavWidth,
      color: context.colors.secondary,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.l,
      ),
      // Desplazable: las secciones se van añadiendo y el diálogo tiene el alto
      // que le deje la ventana. Con una columna a secas, la última sección se
      // desbordaba por abajo en cuanto la ventana era baja, y encima sin poder
      // llegar a ella.
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.m,
                bottom: AppSpacing.xl,
              ),
              child: Text(
                AppLocalizations.of(context).settingsTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            for (final section in SettingsSection.values)
              _SectionTile(
                section: section,
                isSelected: section == selected,
                onTap: () => onSelected(section),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final SettingsSection section;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionTile({
    required this.section,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: isSelected ? context.colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          // La fila de una sección es un botón, y como tal tiene que decirlo al
          // pasar el ratón: sin fondo ni borde propios, el cursor es lo único
          // que la distingue de un rótulo.
          mouseCursor: WidgetStateMouseCursor.clickable,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.m,
            ),
            child: Row(
              children: [
                Icon(section.icon, size: AppSizes.iconMedium),
                const SizedBox(width: AppSpacing.m),
                // El nombre de una sección se recorta antes que desbordar la
                // columna: la columna tiene un ancho fijo y los nombres cambian
                // con el idioma.
                Expanded(
                  child: Text(
                    section.title(AppLocalizations.of(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
