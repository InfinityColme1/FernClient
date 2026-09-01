import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recovery_code_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Fija una contraseña nueva con el código de recuperación.
///
/// Devuelve `true` si se recuperó: el modo queda abierto y con contraseña
/// nueva, y antes de cerrarse enseña el código siguiente, porque el que se
/// acaba de usar ya no vale.
class NsfwRecoverDialog extends StatefulWidget {
  const NsfwRecoverDialog({super.key});

  @override
  State<NsfwRecoverDialog> createState() => _NsfwRecoverDialogState();
}

class _NsfwRecoverDialogState extends State<NsfwRecoverDialog> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _repeated = TextEditingController();

  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _repeated.dispose();
    super.dispose();
  }

  Future<void> _recover(AppLocalizations texts) async {
    if (_password.text.isEmpty) {
      setState(() => _error = texts.nsfwPasswordEmpty);
      return;
    }

    if (_password.text != _repeated.text) {
      setState(() => _error = texts.nsfwPasswordMismatch);
      return;
    }

    setState(() {
      _error = null;
      _isWorking = true;
    });

    final next = await getIt<NsfwModeService>().recover(
      code: _code.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (next == null) {
      setState(() {
        _isWorking = false;
        _error = texts.nsfwRecoverWrong;
      });

      return;
    }

    // El código siguiente, antes de irse: el que se acaba de usar ya no abre
    // nada, y quedarse sin ninguno es quedarse sin salida para la próxima.
    await showNsfwRecoveryCode(context, next);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: el diálogo le da a su contenido la altura que sobra, así
      // que lo que no quepa —en una ventana baja, o con el mensaje de error
      // puesto— se desbordaría por abajo en vez de poder desplazarse.
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts.nsfwRecoverTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.nsfwRecoverIntro,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernLabeledTextField(
              label: texts.nsfwRecoverCodeLabel,
              hintText: 'FERN-0000-0000-0000',
              controller: _code,
              // Enter valida: escribir y pulsar Enter es el gesto de todo
              // el mundo en un campo de contrasena, y sin esto habia que
              // soltar el teclado e ir a por el boton.
              onSubmitted: _isWorking ? null : (_) => _recover(texts),
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwPasswordLabel,
              controller: _password,
              onSubmitted: _isWorking ? null : (_) => _recover(texts),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwPasswordRepeatLabel,
              controller: _repeated,
              onSubmitted: _isWorking ? null : (_) => _recover(texts),
              obscureText: true,
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
        label: texts.nsfwRecoverAction,
        onPressed: _isWorking ? null : () => _recover(texts),
      ),
    );
  }
}
