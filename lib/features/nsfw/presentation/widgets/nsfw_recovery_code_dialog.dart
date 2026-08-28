import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Cómo se llama el fichero que se guarda con el código.
const recoveryCodeFileName = 'fern-codigo-de-recuperacion.txt';

/// Enseña el código de recuperación. **Una sola vez.**
///
/// De él sólo se guarda un hash, igual que de la contraseña, así que esta
/// pantalla es literalmente la única oportunidad de tenerlo. Por eso lleva las
/// dos formas de llevárselo —al portapapeles y a un fichero— y por eso lo dice
/// tan claro: quien la cierre pensando que podrá volver, no podrá.
class NsfwRecoveryCodeDialog extends StatefulWidget {
  final String code;

  const NsfwRecoveryCodeDialog({super.key, required this.code});

  @override
  State<NsfwRecoveryCodeDialog> createState() => _NsfwRecoveryCodeDialogState();
}

class _NsfwRecoveryCodeDialogState extends State<NsfwRecoveryCodeDialog> {
  /// Lo último que ha pasado al intentar llevárselo, para poder decirlo.
  String? _result;

  Future<void> _copy(AppLocalizations texts) async {
    await Clipboard.setData(ClipboardData(text: widget.code));

    if (!mounted) return;
    setState(() => _result = texts.nsfwCodeCopied);
  }

  /// Lo guarda donde el usuario diga.
  ///
  /// Se pide la carpeta en vez de escribirlo en una elegida por la aplicación:
  /// esto es un papel que hay que poder encontrar dentro de un año, y el sitio
  /// donde uno guarda esas cosas sólo lo sabe uno.
  Future<void> _save(AppLocalizations texts) async {
    final directory = await FilePicker.getDirectoryPath();
    if (directory == null || !mounted) return;

    final path = p.join(directory, recoveryCodeFileName);

    try {
      await File(path).writeAsString(
        '${texts.nsfwCodeFileHeader}\n\n${widget.code}\n',
        flush: true,
      );

      if (!mounted) return;
      setState(() => _result = texts.nsfwCodeSaved(path));
    } on Object {
      if (!mounted) return;
      setState(() => _result = texts.nsfwCodeSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      // No se cierra tocando fuera: quien lo haga sin querer se queda sin
      // código, y no hay forma de volver a enseñarlo.
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
            Text(texts.nsfwCodeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              texts.nsfwCodeIntro,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),
            const SizedBox(height: AppSpacing.l),
            FernSurface(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: SelectableText(
                  widget.code,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: FernActionButton(
                    label: texts.nsfwCodeCopy,
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.black,
                    onPressed: () => _copy(texts),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FernActionButton(
                    label: texts.nsfwCodeSave,
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.black,
                    onPressed: () => _save(texts),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            // El hueco del mensaje está reservado desde el principio, con o sin
            // mensaje que poner. Si apareciera y desapareciera, el diálogo
            // cambiaría de alto y —al estar centrado— se recolocaría entero:
            // los dos botones se moverían justo después de pulsarlos, que es
            // cuando el ratón todavía está encima.
            //
            // Y acotado a dos líneas: lo que se guarda lleva la ruta dentro, y
            // una ruta larga se comería el diálogo.
            SizedBox(
              height: AppSizes.nsfwCodeResultHeight,
              width: double.infinity,
              child: _result == null
                  ? null
                  : Text(
                      _result!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: context.colors.unremarked),
                    ),
            ),
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.nsfwCodeDone,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Enseña el código y no deja cerrarlo por descuido tocando fuera.
Future<void> showNsfwRecoveryCode(BuildContext context, String code) {
  return showFernDialog<void, Never>(
    context: context,
    barrierDismissible: false,
    builder: (_) => NsfwRecoveryCodeDialog(code: code),
  );
}
