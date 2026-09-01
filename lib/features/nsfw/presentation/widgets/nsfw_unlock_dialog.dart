import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recover_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cuántos fallos hacen falta para que aparezca la frase clave.
///
/// Tres. Antes sería enseñarle la pista a quien no la necesita —y a quien no
/// debería verla—; mucho después es dejar dando vueltas a quien sí.
const unlockAttemptsBeforeHint = 3;

/// Pide la contraseña para abrir el modo.
///
/// Devuelve `true` si se abrió.
class NsfwUnlockDialog extends StatefulWidget {
  const NsfwUnlockDialog({super.key});

  @override
  State<NsfwUnlockDialog> createState() => _NsfwUnlockDialogState();
}

class _NsfwUnlockDialogState extends State<NsfwUnlockDialog> {
  final _password = TextEditingController();

  int _failures = 0;
  bool _isWorking = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    setState(() => _isWorking = true);

    final outcome = await getIt<NsfwModeService>().unlock(_password.text);

    if (!mounted) return;

    if (outcome == UnlockOutcome.unlocked) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isWorking = false;
      _failures++;
    });
  }

  /// Abre el diálogo de recuperación encima de este.
  ///
  /// Si sale bien, este también se cierra diciendo que sí: recuperar deja el
  /// modo abierto, y volver aquí a pedir la contraseña que se acaba de fijar
  /// sería preguntar por algo que ya se ha demostrado.
  Future<void> _recover() async {
    final recovered = await showFernDialog<bool, Never>(
      context: context,
      builder: (_) => const NsfwRecoverDialog(),
    );

    if (!mounted || recovered != true) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final hint = getIt<NsfwModeService>().hint;
    final showsHint = _failures >= unlockAttemptsBeforeHint;

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
            Text(texts.nsfwUnlockTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.l),
            FernLabeledTextField(
              label: texts.nsfwPasswordLabel,
              controller: _password,
              // Enter valida: escribir y pulsar Enter es el gesto de todo
              // el mundo en un campo de contrasena, y sin esto habia que
              // soltar el teclado e ir a por el boton.
              onSubmitted: _isWorking ? null : (_) => _unlock(),
              obscureText: true,
            ),
            if (_failures > 0) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                texts.nsfwUnlockWrong,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.error),
              ),
            ],
            if (showsHint) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                hint == null || hint.isEmpty
                    ? texts.nsfwUnlockNoHint
                    : texts.nsfwUnlockHint(hint),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.gray),
              ),
              const SizedBox(height: AppSpacing.m),
              FernActionButton(
                label: texts.nsfwUnlockRecover,
                backgroundColor: context.colors.secondary,
                foregroundColor: context.colors.black,
                onPressed: _recover,
              ),
            ],
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.nsfwUnlockAction,
        onPressed: _isWorking ? null : _unlock,
      ),
    );
  }
}
