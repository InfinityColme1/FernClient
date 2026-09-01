import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Quita el bloqueo entero.
///
/// Pide la contraseña **o** el código de recuperación: quien ha perdido la
/// primera y conserva el papel tiene que poder salir sin fijar antes una
/// contraseña nueva que va a borrar tres segundos después.
///
/// Y desmarca todas las etiquetas, que es lo que hace que esto sea una salida y
/// no una trampa: quitar la contraseña dejando el marcado puesto dejaría
/// contenido escondido sin ninguna forma de volver a verlo.
class NsfwDisableDialog extends StatefulWidget {
  const NsfwDisableDialog({super.key});

  @override
  State<NsfwDisableDialog> createState() => _NsfwDisableDialogState();
}

class _NsfwDisableDialogState extends State<NsfwDisableDialog> {
  final _secret = TextEditingController();

  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  Future<void> _disable(AppLocalizations texts) async {
    setState(() {
      _error = null;
      _isWorking = true;
    });

    final mode = getIt<NsfwModeService>();

    if (!mode.isOwner(_secret.text)) {
      setState(() {
        _isWorking = false;
        _error = texts.nsfwDisableWrong;
      });

      return;
    }

    // Primero las marcas y después la contraseña: al revés, un fallo de la base
    // de datos dejaría la biblioteca con contenido escondido y sin contraseña
    // con la que volver a verlo.
    final cleared = await getIt<LocalMediaRepository>().clearNsfwMarks();

    // Y si eso falla, **no se sigue**. Quitar la contraseña dejando las marcas
    // puestas no se nota hoy —sin contraseña no se esconde nada— pero deja una
    // biblioteca que se esconderá sola en cuanto alguien vuelva a poner una.
    // Antes se seguía adelante y encima se decía que no había nada marcado.
    if (cleared is! DataSuccess<int>) {
      if (!mounted) return;

      setState(() {
        _isWorking = false;
        _error = texts.nsfwDisableFailed;
      });

      return;
    }

    await mode.disable();

    if (!mounted) return;

    Navigator.of(context).pop(cleared.data ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: el diálogo le da a su contenido la altura que sobra, así
      // que lo que no quepa —en una ventana baja, o con el mensaje de error
      // puesto— se desbordaría por abajo en vez de poder desplazarse.
      leftContent: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts.nsfwDisableTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.nsfwDisableWarning,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernLabeledTextField(
              label: texts.nsfwDisableSecretLabel,
              controller: _secret,
              // Enter valida: escribir y pulsar Enter es el gesto de todo
              // el mundo en un campo de contrasena, y sin esto habia que
              // soltar el teclado e ir a por el boton.
              onSubmitted: _isWorking ? null : (_) => _disable(texts),
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
        label: texts.nsfwDisableAction,
        backgroundColor: context.colors.error,
        foregroundColor: context.colors.white,
        onPressed: _isWorking ? null : () => _disable(texts),
      ),
    );
  }
}
