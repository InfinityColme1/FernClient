import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/settings/presentation/theme_palette.dart';
import 'package:Fern/features/settings/presentation/widgets/theme_preview.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cómo se ve la aplicación: con qué tema se pinta, qué colores lleva ese tema
/// cuando es el del usuario, y si la lista de etiquetas del menú lateral enseña
/// los avatares.
class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key});

  /// Cómo se llama cada tema y qué se dice de él. Van aquí y no en la entidad
  /// porque cambian con el idioma.
  String _themeLabel(AppThemeMode mode, AppLocalizations texts) =>
      switch (mode) {
        AppThemeMode.system => texts.themeSystem,
        AppThemeMode.light => texts.themeLight,
        AppThemeMode.dark => texts.themeDark,
        AppThemeMode.custom => texts.themeCustom,
      };

  String _themeDescription(AppThemeMode mode, AppLocalizations texts) =>
      switch (mode) {
        AppThemeMode.system => texts.themeSystemDescription,
        AppThemeMode.light => texts.themeLightDescription,
        AppThemeMode.dark => texts.themeDarkDescription,
        AppThemeMode.custom => texts.themeCustomDescription,
      };

  String _colorLabel(CustomThemeColor slot, AppLocalizations texts) =>
      switch (slot) {
        CustomThemeColor.primary => texts.customColorPrimary,
        CustomThemeColor.secondary => texts.customColorSecondary,
        CustomThemeColor.terciary => texts.customColorTerciary,
        CustomThemeColor.error => texts.customColorError,
        CustomThemeColor.background => texts.customColorBackground,
        CustomThemeColor.surface => texts.customColorSurface,
        CustomThemeColor.foreground => texts.customColorForeground,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final isCustomTheme = settings.themeMode == AppThemeMode.custom;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.themeSectionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.themeSectionNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),

            // Cada tema con su previsualización encima de su opción: lo que se
            // elige es cómo va a quedar la aplicación, y eso no lo dice un
            // nombre.
            Wrap(
              spacing: AppSpacing.l,
              runSpacing: AppSpacing.l,
              children: [
                for (final mode in AppThemeMode.values)
                  _ThemeOption(
                    mode: mode,
                    isSelected: settings.themeMode == mode,
                    label: _themeLabel(mode, texts),
                    description: _themeDescription(mode, texts),
                    customTheme: settings.customTheme,
                    onSelected: () => context
                        .read<SettingsBloc>()
                        .add(ThemeModeChangedEvent(mode)),
                  ),
              ],
            ),

            const Divider(height: AppSpacing.xxl),

            Text(texts.customColorsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.customColorsNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.m),

            // Los colores se ven siempre, aunque el tema puesto no sea el del
            // usuario: así se sabe que están ahí y qué se podría cambiar. Hasta
            // que no se elige ese tema no se pueden tocar.
            for (final slot in CustomThemeColor.values)
              FernColorField(
                label: _colorLabel(slot, texts),
                color: settings.customTheme.colorOfOrInherited(slot),
                isCustom: settings.customTheme.colorOf(slot) != null,
                onChanged: isCustomTheme
                    ? (color) => context.read<SettingsBloc>().add(
                          CustomThemeColorChangedEvent(slot, color.toARGB32()),
                        )
                    : null,
                onReset: () => context
                    .read<SettingsBloc>()
                    .add(CustomThemeColorChangedEvent(slot, null)),
              ),

            const Divider(height: AppSpacing.xxl),

            Text(texts.sidebarSectionTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.sidebarSectionNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.showListAvatars,
              description: texts.showListAvatarsDescription,
              value: settings.showListAvatars,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(ShowListAvatarsToggledEvent(value)),
            ),
            // Va aquí porque aquí es donde se suelta: las etiquetas del menú
            // lateral son el único sitio de la aplicación al que se puede
            // arrastrar contenido.
            FernCheckboxTile(
              label: texts.keepsSelectionOnDrop,
              description: texts.keepsSelectionOnDropDescription,
              value: settings.keepsSelectionOnDrop,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(KeepsSelectionOnDropToggledEvent(value)),
            ),
            // Y aquí porque es otra cosa de las listas: cómo se comportan al
            // buscar en ellas.
            FernCheckboxTile(
              label: texts.showsTagBranchOnFilter,
              description: texts.showsTagBranchOnFilterDescription,
              value: settings.showsTagBranchOnFilter,
              onChanged: (value) => context
                  .read<SettingsBloc>()
                  .add(ShowsTagBranchOnFilterToggledEvent(value)),
            ),
          ],
        );
      },
    );
  }
}

/// Un tema para elegir: su previsualización y, debajo, su opción.
///
/// La previsualización también se pulsa: es lo que se está mirando cuando se
/// decide, así que obligar a bajar hasta el círculo sería trabajo de más.
class _ThemeOption extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final String label;
  final String description;
  final CustomThemeEntity customTheme;
  final VoidCallback onSelected;

  const _ThemeOption({
    required this.mode,
    required this.isSelected,
    required this.label,
    required this.description,
    required this.customTheme,
    required this.onSelected,
  });

  Widget _preview() => switch (mode) {
        AppThemeMode.system => const SystemThemePreview(
            light: AppColors.light,
            dark: AppColors.dark,
          ),
        AppThemeMode.light => const ThemePreview(palette: AppColors.light),
        AppThemeMode.dark => const ThemePreview(palette: AppColors.dark),
        AppThemeMode.custom => ThemePreview(palette: customTheme.palette),
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: AppSizes.themePreviewWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El tema elegido se marca con un borde suyo; los demás llevan sólo
          // el filete que separa la previsualización del fondo.
          InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            onTap: onSelected,
            child: Container(
              height: AppSizes.themePreviewHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isSelected ? colors.black : colors.lightgray,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                // Por dentro del borde, para no taparlo.
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                child: _preview(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FernRadioTile<AppThemeMode>(
            value: mode,
            groupValue: isSelected ? mode : null,
            label: label,
            description: description,
            onChanged: (_) => onSelected(),
          ),
        ],
      ),
    );
  }
}
