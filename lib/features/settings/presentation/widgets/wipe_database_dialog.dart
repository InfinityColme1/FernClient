import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/settings/domain/services/database_wipe_options.dart';
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
/// Aquí se elige además **cuánto** se borra y si se van los ficheros: son las
/// dos decisiones que cambian lo que esto significa, y tienen que estar donde se
/// explica qué hace, no al lado del botón de confirmar.
///
/// Se cierra devolviendo lo elegido, o `null` si se cierra sin seguir.
class WipeDatabaseWarningDialog extends StatefulWidget {
  /// Si se puede elegir «sólo lo no apto».
  ///
  /// Con el bloqueo cerrado **no se ofrece**: ese contenido no se ve, así que
  /// sería borrar a ciegas algo que no hay forma de comprobar. Llega por
  /// parámetro para poder medir las dos formas sin localizador de servicios.
  final bool canWipeNsfwOnly;

  const WipeDatabaseWarningDialog({super.key, this.canWipeNsfwOnly = false});

  @override
  State<WipeDatabaseWarningDialog> createState() =>
      _WipeDatabaseWarningDialogState();
}

class _WipeDatabaseWarningDialogState extends State<WipeDatabaseWarningDialog> {
  DatabaseWipeOptions _options = const DatabaseWipeOptions();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
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
            // siguen en su carpeta y un escaneo los vuelve a dar de alta —
            // mientras no se marque la casilla de abajo.
            Text(
              texts.databaseWipeKeeps,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.gray),
            ),

            // Cuánto. Sólo cuando hay dos respuestas posibles: con el bloqueo
            // cerrado, «sólo lo no apto» sería borrar a ciegas.
            if (widget.canWipeNsfwOnly) ...[
              const SizedBox(height: AppSpacing.l),
              FernRadioTile<DatabaseWipeScope>(
                value: DatabaseWipeScope.everything,
                groupValue: _options.scope,
                label: texts.databaseWipeScopeAll,
                description: texts.databaseWipeScopeAllNote,
                onChanged: (scope) =>
                    setState(() => _options = _options.copyWith(scope: scope)),
              ),
              FernRadioTile<DatabaseWipeScope>(
                value: DatabaseWipeScope.nsfwOnly,
                groupValue: _options.scope,
                label: texts.databaseWipeScopeNsfw,
                description: texts.databaseWipeScopeNsfwNote,
                onChanged: (scope) =>
                    setState(() => _options = _options.copyWith(scope: scope)),
              ),
            ],

            const SizedBox(height: AppSpacing.m),
            // Y si se van también del disco. Apagada de fábrica: es lo que esto
            // ha hecho siempre, y es la única parte que no tiene vuelta.
            FernCheckboxTile(
              label: texts.databaseWipeFiles,
              description: texts.databaseWipeFilesNote,
              value: _options.deletesFiles,
              onChanged: (value) => setState(
                () => _options = _options.copyWith(deletesFiles: value),
              ),
            ),
          ],
        ),
      ),
      actionButton: FernActionButton(
        label: texts.databaseWipeContinue,
        backgroundColor: context.colors.error,
        foregroundColor: context.colors.white,
        onPressed: () => Navigator.of(context).pop(_options),
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
/// **Dice lo que se eligió antes**, y no una advertencia genérica: no es lo
/// mismo confirmar que se vacía una base de datos que confirmar que se borran
/// mil ficheros del disco, y quien llega aquí viene de leer otra pantalla.
///
/// Se cierra devolviendo `true` si la base de datos se ha vaciado.
class WipeDatabaseConfirmDialog extends StatefulWidget {
  /// Lo elegido en el primer aviso.
  final DatabaseWipeOptions options;

  const WipeDatabaseConfirmDialog({
    super.key,
    this.options = const DatabaseWipeOptions(),
  });

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

    final result = await getIt<WipeDatabaseUseCase>()(params: widget.options);

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

            // Lo que se eligió, repetido aquí. Es la última pantalla antes de
            // que no haya vuelta, y llegar a ella con una casilla marcada dos
            // pantallas atrás y sin recordarlo es como se borran cosas sin
            // querer.
            if (!widget.options.isEverything) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                texts.databaseWipeConfirmNsfw,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (widget.options.deletesFiles) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                texts.databaseWipeConfirmFiles,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.colors.error),
              ),
            ],

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
