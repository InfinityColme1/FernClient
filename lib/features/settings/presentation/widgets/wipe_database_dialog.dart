import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_phrase.dart';
import 'package:Fern/features/settings/domain/usecases/wipe_database_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// El primer aviso: qué se va y qué se queda.
///
/// Va antes del que pide escribir la frase porque son dos preguntas distintas.
/// Ésta es «¿sabes lo que esto hace?» y la otra es «¿seguro?»; juntas en un solo
/// diálogo, la explicación se lee por encima con la mano ya en el botón.
///
/// Se cierra devolviendo `true` cuando el usuario quiere seguir.
class WipeDatabaseWarningDialog extends StatelessWidget {
  const WipeDatabaseWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: el diálogo le da a su contenido la altura que sobra, y en
      // una ventana baja esta lista se desbordaría por abajo en vez de poder
      // desplazarse.
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts.databaseWipeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.databaseWipeWarning,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            // Lo que se va, dicho por su nombre. «Se borrará todo» no deja
            // calcular lo que cuesta: lo que duele de esto son las regiones
            // marcadas una a una y los modelos entrenados, no las filas.
            Text(texts.databaseWipeLoses, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.l),
            // Y lo que no, que es lo que hace esto reversible: los ficheros
            // siguen en su carpeta y un escaneo los vuelve a dar de alta.
            Text(
              texts.databaseWipeKeeps,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.databaseWipeContinue,
        backgroundColor: context.colors.error,
        foregroundColor: context.colors.white,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

/// El segundo aviso: escribir la frase.
///
/// El botón no se enciende hasta que lo escrito es **exactamente** la frase. No
/// hay atajo, ni se acepta con la tecla de entrada mientras no lo sea: lo que
/// esto compra es que el borrado no pueda salir de un gesto automático.
///
/// Se cierra devolviendo `true` si la base de datos se ha vaciado.
class WipeDatabaseConfirmDialog extends StatefulWidget {
  const WipeDatabaseConfirmDialog({super.key});

  @override
  State<WipeDatabaseConfirmDialog> createState() =>
      _WipeDatabaseConfirmDialogState();
}

class _WipeDatabaseConfirmDialogState extends State<WipeDatabaseConfirmDialog> {
  final _typed = TextEditingController();

  String? _error;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    // Sin esto el botón se quedaría apagado hasta que algo repintara la
    // pantalla por otro motivo.
    _typed.addListener(_onTyped);
  }

  @override
  void dispose() {
    _typed.removeListener(_onTyped);
    _typed.dispose();
    super.dispose();
  }

  void _onTyped() => setState(() {});

  Future<void> _wipe(AppLocalizations texts) async {
    setState(() {
      _error = null;
      _isWorking = true;
    });

    final result = await getIt<WipeDatabaseUseCase>()();

    if (!mounted) return;

    if (result is! DataSuccess<void>) {
      setState(() {
        _isWorking = false;
        _error = texts.databaseWipeFailed;
      });

      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final phrase = texts.databaseWipePhrase;

    final isConfirmed = isDatabaseWipeConfirmed(
      typed: _typed.text,
      phrase: phrase,
    );

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texts.databaseWipeConfirmTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.databaseWipeConfirmNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            // La frase, escrita tal cual hay que copiarla. Puesta aparte y en
            // negrita porque hay que leerla carácter a carácter: se compara
            // exactamente, tildes y mayúsculas incluidas.
            Text(
              phrase,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.databaseWipeFieldLabel,
              controller: _typed,
            ),
            if (_error case final error?) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                error,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.error),
              ),
            ],
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.databaseWipeAction,
        backgroundColor: context.colors.error,
        foregroundColor: context.colors.white,
        onPressed: isConfirmed && !_isWorking ? () => _wipe(texts) : null,
      ),
    );
  }
}
