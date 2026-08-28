import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Lo que se decide en el diálogo: con qué se dispara el hijo, o descolgarlo.
class EdgeConditionResult {
  /// El fernie elegido, o `null` para «cualquier detección del padre».
  final int? fernieId;

  /// Se ha pedido quitar la arista.
  final bool isDisconnected;

  const EdgeConditionResult({this.fernieId, this.isDisconnected = false});
}

/// Con qué clase del padre se dispara el hijo.
///
/// Es la decisión que hace que el árbol sirva de algo: sin ella, todos los
/// modelos especializados se ejecutan ante cualquier detección del padre, que es
/// el triple de trabajo para nada.
///
/// Se ofrecen los fernies **del padre**, que son las clases que sabe distinguir.
/// Los del hijo no pintan nada aquí: el hijo todavía no ha mirado el contenido.
class EdgeConditionDialog extends StatefulWidget {
  final String parentName;
  final String childName;
  final List<ModelFernieEntity> parentFernies;
  final int? conditionFernieId;

  const EdgeConditionDialog({
    super.key,
    required this.parentName,
    required this.childName,
    required this.parentFernies,
    this.conditionFernieId,
  });

  @override
  State<EdgeConditionDialog> createState() => _EdgeConditionDialogState();
}

class _EdgeConditionDialogState extends State<EdgeConditionDialog> {
  late int? _fernieId = widget.conditionFernieId;

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texts.treeEdgeConditionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.treeEdgeConditionMessage(widget.childName, widget.parentName),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.colors.unremarked),
          ),
          const SizedBox(height: AppSpacing.l),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: AppSizes.edgeConditionListHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // «Cualquier cosa» va el primero porque es lo que hay puesto
                  // al crear la arista: quien abre esto viene a cambiarlo, y
                  // tiene que ver de qué está saliendo.
                  FernRadioTile<int?>(
                    value: null,
                    groupValue: _fernieId,
                    label: texts.treeEdgeAnyDetection,
                    onChanged: (value) => setState(() => _fernieId = value),
                  ),
                  for (final assignment in widget.parentFernies)
                    FernRadioTile<int?>(
                      value: assignment.fernie.id,
                      groupValue: _fernieId,
                      label: assignment.fernie.name,
                      onChanged: (value) => setState(() => _fernieId = value),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(
                  const EdgeConditionResult(isDisconnected: true),
                ),
                child: Text(texts.treeEdgeDisconnect),
              ),
              const Spacer(),
              FernPillButton(
                label: texts.actionConfirm,
                icon: Symbols.check,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.black,
                onPressed: () => Navigator.of(context).pop(
                  EdgeConditionResult(fernieId: _fernieId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
