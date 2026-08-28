import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Aviso previo a traerse contenido de una plataforma.
///
/// Importar de una fuente remota no es como escanear una carpeta: sale a
/// internet con las credenciales del usuario y se descarga ficheros a su
/// equipo, cosas las dos que conviene que no pasen por un clic de más. Por eso
/// dice de dónde va a traer y cuánto antes de hacer nada.
///
/// Cuando lo que se va a pedir es mucho (una fuente que devuelve cuentas
/// enteras, sin tope), se dice además: no es lo mismo traerse cincuenta
/// contenidos que dejar la aplicación descargando durante horas, y eso conviene
/// saberlo **antes**.
///
/// Se cierra con `true` al confirmar y con `null` al cancelar.
class ConfirmRemoteImportDialog extends StatelessWidget {
  /// Las plataformas de las que se va a importar. Son varias cuando está
  /// elegida la opción de todas las fuentes.
  final List<ImportSource> sources;

  /// El tope elegido en la pantalla, tal cual: un número, todo o lo nuevo desde
  /// la última vez.
  final int limit;

  const ConfirmRemoteImportDialog({
    super.key,
    required this.sources,
    required this.limit,
  });

  /// Cuánto se va a intentar traer, dicho con palabras: las dos opciones que no
  /// son un número no se pueden enseñar como una cuenta.
  String _amount(AppLocalizations texts) => switch (limit) {
        unlimitedImportLimit => texts.remoteImportAmountAll,
        untilLastImportLimit => texts.remoteImportAmountSinceLast,
        _ => texts.remoteImportAmountLimited(limit),
      };

  /// Se ha pedido la fuente entera, sin tope.
  ///
  /// Avisa **sea cual sea la plataforma**. Antes sólo avisaba de Pawchive, y el
  /// resto se traían la cuenta completa —horas de descarga y gigas de disco—
  /// sin decir nada. Con un tope puesto no hace falta avisar de nada: el usuario
  /// ya ha dicho hasta dónde.
  bool get _isHeavy => limit == unlimitedImportLimit;

  /// Y de esta además hay que decir que trae todavía más.
  ///
  /// Pawchive devuelve publicaciones con todo lo que llevan dentro, así que sin
  /// tope puede ser la obra completa de varios autores. Es otra magnitud, y
  /// merece su propia frase.
  bool get _isVeryHeavy => _isHeavy && sources.contains(ImportSource.pawchive);

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: con el aviso de «todo» puesto —que ahora sale con
      // cualquier plataforma, no sólo con una— el contenido ya no cabe en una
      // ventana baja, y lo que no cabe se desbordaba por abajo.
      leftContent: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.remoteImportWarning(
                // Las plataformas se llaman igual en todos los idiomas, así que
                // sus nombres van tal cual.
                [for (final source in sources) source.label ?? source.id]
                    .join(', '),
              ),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              _amount(texts),
              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
            ),
            if (_isHeavy) ...[
              const SizedBox(height: AppSpacing.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Symbols.schedule,
                    size: AppSizes.iconCompact,
                    color: context.colors.terciary,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      _isVeryHeavy
                          ? texts.remoteImportHeavyWarning
                          : texts.remoteImportAllWarning,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.terciary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actionButton: FernPillButton(
        label: texts.actionImport,
        icon: Symbols.download,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.black,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
