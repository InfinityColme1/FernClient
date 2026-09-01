import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pone la contraseña por primera vez.
///
/// Devuelve el código de recuperación recién generado, para que quien lo abra lo
/// enseñe acto seguido. No lo enseña este diálogo porque son dos cosas
/// distintas: aquí se elige un secreto, allí se guarda un papel.
class NsfwSetupDialog extends StatefulWidget {
  const NsfwSetupDialog({super.key});

  @override
  State<NsfwSetupDialog> createState() => _NsfwSetupDialogState();
}

class _NsfwSetupDialogState extends State<NsfwSetupDialog> {
  final _password = TextEditingController();
  final _repeated = TextEditingController();
  final _hint = TextEditingController();

  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _password.dispose();
    _repeated.dispose();
    _hint.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations texts) async {
    final password = _password.text;

    if (password.isEmpty) {
      setState(() => _error = texts.nsfwPasswordEmpty);
      return;
    }

    if (password != _repeated.text) {
      setState(() => _error = texts.nsfwPasswordMismatch);
      return;
    }

    // Derivar cuesta su fracción de segundo a propósito: mientras tanto, el
    // botón no acepta otra pulsación.
    setState(() {
      _error = null;
      _isWorking = true;
    });

    final code = await getIt<NsfwModeService>().configure(
      password: password,
      hint: _hint.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: son tres campos, dos avisos y un mensaje de error, y el
      // diálogo le da a su contenido la altura que sobra. Sin esto, lo que no
      // quepa —en una ventana baja, o al aparecer el error— se desborda por
      // abajo en vez de poder desplazarse.
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts.nsfwSetupTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            // Lo que esto es y lo que no. Va aquí, donde se decide, y no en una
            // ayuda que nadie abre: quien crea que esto cifra algo tomará
            // decisiones que no tomaría sabiendo la verdad.
            Text(
              texts.nsfwSectionNote,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.nsfwSectionWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FernLabeledTextField(
              label: texts.nsfwPasswordLabel,
              controller: _password,
              // Enter valida: escribir y pulsar Enter es el gesto de todo
              // el mundo en un campo de contrasena, y sin esto habia que
              // soltar el teclado e ir a por el boton.
              onSubmitted: _isWorking ? null : (_) => _save(texts),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwPasswordRepeatLabel,
              controller: _repeated,
              onSubmitted: _isWorking ? null : (_) => _save(texts),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.m),
            FernLabeledTextField(
              label: texts.nsfwHintLabel,
              controller: _hint,
              onSubmitted: _isWorking ? null : (_) => _save(texts),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              texts.nsfwHintNote,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: context.colors.unremarked),
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
        label: texts.nsfwSetupAction,
        onPressed: _isWorking ? null : () => _save(texts),
      ),
    );
  }
}
