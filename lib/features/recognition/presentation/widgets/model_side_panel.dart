import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/widgets/tree_drag_payload.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Los modelos que todavía no están en el árbol, para meterlos.
///
/// Enseña sólo los de fuera: un modelo aparece una sola vez en el árbol, así que
/// ofrecer los que ya están sería ofrecer algo que no va a pasar.
///
/// Pulsar uno lo mete. Si hay un nodo elegido, colgando de él; si no, suelto. Es
/// el «clic para colocar rápido» del documento, y es lo que hace la pantalla
/// usable sin arrastrar nada.
class ModelSidePanel extends StatefulWidget {
  final List<RecognitionModelEntity> models;

  /// El nombre del nodo elegido, si hay alguno. Se dice en la cabecera para que
  /// se sepa dónde va a caer lo que se pulse.
  final String? selectedName;

  final ValueChanged<RecognitionModelEntity>? onPlace;
  final VoidCallback? onClearSelection;

  /// Se ha soltado un nodo del árbol aquí dentro: se saca del árbol.
  ///
  /// Devolverlo al sitio de donde salen los modelos es la forma natural de
  /// decir «éste que se vuelva a la lista».
  final ValueChanged<int>? onRemoveNode;

  const ModelSidePanel({
    super.key,
    required this.models,
    this.selectedName,
    this.onPlace,
    this.onClearSelection,
    this.onRemoveNode,
  });

  @override
  State<ModelSidePanel> createState() => _ModelSidePanelState();
}

class _ModelSidePanelState extends State<ModelSidePanel> {
  String _query = '';

  /// Por qué función se filtra, o `null` por todas.
  ModelFunction? _function;

  List<RecognitionModelEntity> get _visible {
    final query = _query.trim().toLowerCase();

    return widget.models.where((model) {
      if (_function != null && model.effectiveFunction != _function) {
        return false;
      }

      return query.isEmpty || model.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final visible = _visible;

    return FernDropSlot<TreeDragPayload>(
      // Sólo recoge nodos: un modelo del panel soltado en el panel no es nada.
      canAccept: (payload) =>
          widget.onRemoveNode != null && payload is TreeNodePayload,
      onAccept: (payload) {
        if (payload is TreeNodePayload) widget.onRemoveNode?.call(payload.nodeId);
      },
      builder: (context, state) => _panel(context, texts, visible),
    );
  }

  Widget _panel(
    BuildContext context,
    AppLocalizations texts,
    List<RecognitionModelEntity> visible,
  ) {
    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.treeAvailableModels,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (widget.selectedName case final name?) ...[
            const SizedBox(height: AppSpacing.s),
            _selection(context, texts, name),
          ],
          const SizedBox(height: AppSpacing.m),
          FernLabeledTextField(
            label: texts.treeSearchModel,
            hintText: texts.searchEllipsisHint,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.m),
          _filters(context, texts),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: visible.isEmpty
                ? _nothing(context, texts)
                : ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, index) => _row(context, visible[index]),
                  ),
          ),
        ],
      ),
    );
  }

  /// Qué nodo está elegido, y cómo soltarlo.
  ///
  /// Sin esto, pulsar un modelo del panel colgaría de algo que se eligió hace un
  /// rato y ya no se recuerda.
  Widget _selection(
    BuildContext context,
    AppLocalizations texts,
    String name,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts.treeSelectedHint(name),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.colors.unremarked),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: widget.onClearSelection,
            child: Text(texts.treeClearSelection),
          ),
        ),
      ],
    );
  }

  Widget _filters(BuildContext context, AppLocalizations texts) {
    Widget pill(ModelFunction? function, String label) {
      final isOn = _function == function;

      return FernPillButton(
        label: label,
        icon: isOn ? Symbols.check_circle : Symbols.circle,
        backgroundColor:
            isOn ? context.colors.primary : context.colors.secondary,
        foregroundColor: context.colors.black,
        onPressed: () => setState(() => _function = function),
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        pill(null, texts.importLimitAll),
        pill(ModelFunction.boolean, texts.modelFunctionBoolean),
        pill(ModelFunction.classification, texts.modelFunctionClassification),
      ],
    );
  }

  /// Una fila del panel: avatar, nombre y en qué estado está.
  ///
  /// En horizontal y no como las celdas de una rejilla: aquí caben quince
  /// modelos y apilados se ven tres. Es una lista para elegir de un vistazo, no
  /// un escaparate.
  Widget _row(BuildContext context, RecognitionModelEntity model) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Sin entrenar se mete igual: colocarlo en el árbol y entrenarlo después es
    // el orden natural, y al reconocer se salta con su aviso.
    final isTrained = model.isUsable;
    final note = isTrained
        ? texts.modelFernieCount(model.fernieCount)
        : texts.treeNodeNotTrained;

    final row = InkWell(
      onTap: widget.onPlace == null ? null : () => widget.onPlace!(model),
      mouseCursor: WidgetStateMouseCursor.clickable,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            FernAvatar(
              imagePath: model.picturePath,
              fallbackIcon: Symbols.hub,
              radius: AppSizes.avatarSmall,
              iconSize: AppSizes.iconSmall,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isTrained
                          ? context.colors.unremarked
                          : context.colors.error,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.add,
              size: AppSizes.iconSmall,
              color: context.colors.unremarked,
            ),
          ],
        ),
      ),
    );

    return FernDraggableCard<TreeDragPayload>(
      data: TreeModelPayload(modelId: model.id, name: model.name),
      isEnabled: widget.onPlace != null,
      // Lo que se lleva pegado al cursor es una tarjeta con el ancho de las del
      // árbol: es lo que va a acabar siendo, y así se ve si cabe donde se va a
      // soltar.
      feedback: SizedBox(width: AppSizes.treeNodeWidth, child: row),
      child: row,
    );
  }

  Widget _nothing(BuildContext context, AppLocalizations texts) {
    return Text(
      widget.models.isEmpty ? texts.treeAllInTree : texts.treeNoModels,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.unremarked),
    );
  }
}
