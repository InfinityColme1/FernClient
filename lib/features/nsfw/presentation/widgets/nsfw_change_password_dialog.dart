import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cambia la contraseña sabiendo la de ahora.
///
/// El código de recuperación no se toca: el que estuviera apuntado en un papel
/// sigue valiendo, y regenerarlo aquí obligaría a apuntar otro cada vez que se
/// cambia la contraseña.
class NsfwChangePasswordDialog extends StatefulWidget {
  const NsfwChangePasswordDialog({super.key});

  @override
  State<NsfwChangePasswordDialog> createState() =>
      _NsfwChangePasswordDialogState();
}

class _NsfwChangePasswordDialogState extends State<NsfwChangePasswordDialog> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _repeated = TextEditingController();

  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _repeated.dispose();
    super.dispose();
  }

  Future<void> _change(AppLocalizations texts) async {
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

    final changed = await getIt<NsfwModeService>().changePassword(
      current: _current.text,
      next: _password.text,
    );

    if (!mounted) return;

    if (!changed) {
      setState(() {
        _isWorking = false;
        _error = texts.nsfwChangeWrong;
      });

      return;
    }

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
            Text(texts.nsfwChangeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.l),
            FernLabeledTextField(
              label: texts.nsfwChangeCurrentLabel,
              controller: _current,
              // Enter valida: escribir y pulsar Enter es el gesto de todo
              // el mundo en un campo de contrasena, y sin esto habia que
              // soltar el teclado e ir a por el boton.
              onSubmitted: _isWorking ? null : (_) => _change(texts),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwChangeNewLabel,
              controller: _password,
              onSubmitted: _isWorking ? null : (_) => _change(texts),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwPasswordRepeatLabel,
              controller: _repeated,
              onSubmitted: _isWorking ? null : (_) => _change(texts),
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
        label: texts.nsfwChangeAction,
        onPressed: _isWorking ? null : () => _change(texts),
      ),
    );
  }
}
