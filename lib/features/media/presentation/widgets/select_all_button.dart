import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Marcar de golpe todo lo que hay a la vista, o soltarlo.
///
/// El mismo botón en la pantalla de contenido y en la de importación. Estaba
/// escrito sólo en la primera, y en la segunda es donde más falta hace: allí se
/// revisan tandas de trescientos, y marcarlos uno a uno para aceptarlos o
/// tirarlos es lo que hace que nadie revise nada.
///
/// Es un botón y no dos: con todo marcado, lo único que se puede querer es lo
/// contrario, y son el mismo gesto.
class SelectAllButton extends StatelessWidget {
  /// Lo que hay **a la vista**, ya filtrado.
  ///
  /// A la vista y no todo lo que hay: marcar lo que no se está viendo y luego
  /// borrarlo es la clase de sorpresa que no se puede deshacer.
  final List<MediaSummaryEntity> visible;

  final Set<int> selectedIds;

  /// Qué hacer con lo que hay a la vista.
  ///
  /// Va por parámetro en vez de hablar con el bloc desde aquí: así el botón se
  /// puede montar solo para comprobar qué pide y cuándo, que es lo único suyo.
  final ValueChanged<List<int>> onSelectAll;

  const SelectAllButton({
    super.key,
    required this.visible,
    required this.selectedIds,
    required this.onSelectAll,
  });

  /// Si ya está marcado todo lo que se ve.
  bool get _isEverythingSelected =>
      visible.isNotEmpty && visible.every((one) => selectedIds.contains(one.id));

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return IconButton(
      tooltip: _isEverythingSelected
          ? texts.selectNoneTooltip
          : texts.selectAllTooltip,
      onPressed: visible.isEmpty
          ? null
          : () => onSelectAll([for (final one in visible) one.id]),
      icon: Icon(_isEverythingSelected ? Symbols.deselect : Symbols.select_all),
    );
  }
}
