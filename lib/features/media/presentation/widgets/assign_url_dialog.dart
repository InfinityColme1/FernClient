import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A qué se están vinculando las direcciones. Lo único que cambia es cómo se
/// explica: el formulario y lo que se devuelve son los mismos.
enum AssignUrlTarget {
  tag,
  creator;

  String description(AppLocalizations texts) => switch (this) {
        AssignUrlTarget.tag => texts.assignUrlsDescription,
        AssignUrlTarget.creator => texts.assignUrlsCreatorDescription,
      };
}

/// Direcciones de las que sale el contenido de una etiqueta o de un creador.
///
/// Vincular una dirección con una etiqueta es lo que hace que el contenido que
/// se importe de debajo de ella nazca ya con esa etiqueta puesta: la dirección
/// de un subreddit, la galería de un autor, la sección de una web. Con un
/// creador funciona igual, y es lo que evita tener que asignarlo a mano a todo
/// lo que llega de su galería. Se trabaja por dirección y no por un campo de
/// cada API para que valga igual en las plataformas que no tienen API pública.
///
/// Es el mismo formulario que los enlaces de redes sociales del diálogo de
/// creadores: un campo por dirección, dos para empezar, y un botón discreto para
/// añadir más.
///
/// Al confirmar se cierra devolviendo lo escrito, y al cerrarlo (con el aspa o
/// con escape) devuelve `null`: quien lo abrió decide qué hacer con ello, que no
/// es lo mismo desde el diálogo de creación de una etiqueta (que todavía no
/// existe) que desde su ficha:
///
/// ```dart
/// final urls = await showFernDialog<List<String>, TagsBloc>(
///   context: context,
///   builder: (_) => AssignUrlDialog(urls: _sourceUrls, name: name),
/// );
/// ```
class AssignUrlDialog extends StatefulWidget {
  /// Direcciones que ya tiene la etiqueta (o el creador). Con las que llegue se
  /// rellenan los campos, y de ahí para abajo se completa hasta
  /// [_initialFieldCount].
  final List<String> urls;

  /// Nombre de la etiqueta o del creador, para decir de cuál se está hablando.
  /// Vacío mientras no se le haya puesto uno (se está creando y aún no se ha
  /// escrito).
  final String name;

  final AssignUrlTarget target;

  const AssignUrlDialog({
    super.key,
    this.urls = const [],
    this.name = '',
    this.target = AssignUrlTarget.tag,
  });

  @override
  State<AssignUrlDialog> createState() => _AssignUrlDialogState();
}

/// Con cuántos campos arranca el diálogo. Dos: uno solo se lee como "aquí va una
/// dirección" y no cuenta que puede haber varias.
const _initialFieldCount = 2;

class _AssignUrlDialogState extends State<AssignUrlDialog> {
  late final List<TextEditingController> _controllers = [
    for (final url in widget.urls) TextEditingController(text: url),
    for (var i = widget.urls.length; i < _initialFieldCount; i++)
      TextEditingController(),
  ];

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  /// Lo escrito, sin los campos que se han quedado vacíos. Se devuelve tal cual
  /// se ha escrito: normalizarlo es cosa de quien lo guarda.
  List<String> get _urls => _controllers
      .map((controller) => controller.text.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final name = widget.name.trim();

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      // Una sola columna: aquí no hay avatar ni nada que enseñar al lado, sólo
      // la lista de direcciones.
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? texts.assignUrlsTitle : texts.assignUrlsTo(name),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.target.description(texts),
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            texts.sourceUrlsLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: createDialogSocialFieldsMaxHeight,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _controllers.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (_, index) => TextField(
                controller: _controllers[index],
                keyboardType: TextInputType.url,
                decoration: InputDecoration(hintText: texts.sourceUrlHint),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          FernAddButton.compact(
            label: texts.addSourceUrl,
            onTap: _addField,
          ),
        ],
      ),
      actionButton: FernConfirmButton(
        icon: null,
        onPressed: () => Navigator.of(context).pop(_urls),
      ),
    );
  }
}
