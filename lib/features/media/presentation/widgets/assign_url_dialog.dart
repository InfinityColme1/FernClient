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
/// Es la misma lista que los enlaces de redes sociales de la ficha del creador
/// —el mismo widget, de hecho—: cada dirección se abre de una pulsación, se
/// edita en el sitio y se quita con su aspa, y debajo un botón discreto para
/// añadir más. Antes eran campos de texto sueltos: no se podía abrir ninguno, y
/// para quitar uno había que borrar su texto a mano.
///
/// Al confirmar se cierra devolviendo lo escrito, y al cerrarlo (con el aspa o
/// con escape) devuelve `null`: quien lo abrió decide qué hacer con ello, que no
/// es lo mismo desde el diálogo de creación de una etiqueta (que todavía no
/// existe) que desde su ficha:
///
/// ```dart
/// final urls = await showFernDialog<List<FernLink>, TagsBloc>(
///   context: context,
///   builder: (_) => AssignUrlDialog(urls: _sourceUrls, name: name),
/// );
/// ```
class AssignUrlDialog extends StatefulWidget {
  /// Direcciones que ya tiene la etiqueta (o el creador). Con las que llegue se
  /// rellenan los campos, y de ahí para abajo se completa hasta
  /// [_initialFieldCount].
  final List<FernLink> urls;

  /// Nombre de la etiqueta o del creador, para decir de cuál se está hablando.
  /// Vacío mientras no se le haya puesto uno (se está creando y aún no se ha
  /// escrito).
  final String name;

  final AssignUrlTarget target;

  /// Si se puede marcar una dirección como no apta, y si las marcadas se
  /// esconden ahora mismo. Llegan de fuera porque el diálogo se abre también
  /// desde la creación, donde la etiqueta todavía no existe.
  final bool canMarkNsfw;
  final bool hidesMarked;

  const AssignUrlDialog({
    super.key,
    this.urls = const [],
    this.name = '',
    this.target = AssignUrlTarget.tag,
    this.canMarkNsfw = false,
    this.hidesMarked = false,
  });

  @override
  State<AssignUrlDialog> createState() => _AssignUrlDialogState();
}

/// Con cuántos campos arranca el diálogo. Dos: uno solo se lee como "aquí va una
/// dirección" y no cuenta que puede haber varias.
const _initialFieldCount = 2;

class _AssignUrlDialogState extends State<AssignUrlDialog> {
  /// Lo escrito, tal cual: normalizarlo es cosa de quien lo guarda.
  ///
  /// Lo mantiene al día la lista de enlaces, que avisa en cada cambio. No hace
  /// falta `setState`: aquí no se pinta nada con esto, sólo se devuelve al
  /// confirmar.
  late List<FernLink> _urls = List.of(widget.urls);

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
          // El rótulo y la nota los pone la propia lista: qué forma tiene una
          // regla que funciona hace falta decirlo, porque en las plataformas que
          // identifican la galería con lo que va detrás del «?», copiar sólo la
          // parte bonita de la dirección no recoge nada.
          FernLinkListField(
            links: widget.urls,
            onChanged: (urls) => _urls = urls,
            label: texts.sourceUrlsLabel,
            note: texts.sourceUrlsNote,
            emptyMessage: texts.noSourceUrls,
            hintText: texts.sourceUrlHint,
            addLabel: texts.addSourceUrl,
            openTooltip: texts.openSourceUrlTooltip,
            editTooltip: texts.editSourceUrlTooltip,
            removeTooltip: texts.removeSourceUrlTooltip,
            doneTooltip: texts.doneEditingSourceUrlTooltip,
            canMarkNsfw: widget.canMarkNsfw,
            hidesMarked: widget.hidesMarked,
            markNsfwTooltip: texts.markLinkNsfwTooltip,
            unmarkNsfwTooltip: texts.unmarkLinkNsfwTooltip,
            initialEmptyFields: _initialFieldCount,
            maxHeight: createDialogSocialFieldsMaxHeight,
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
