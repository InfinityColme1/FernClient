import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Columna de presentación de los diálogos, en dos variantes:
///
/// * la de por defecto, con avatar, título y separador;
/// * [FernDialogSidePanel.list], con una cabecera y, en el centro, una lista
///   vertical de elementos (las etiquetas del contenido, por ejemplo).
class FernDialogSidePanel extends StatelessWidget {
  /// Avatar de la variante por defecto.
  final Widget? avatar;
  final String? title;

  /// Color del título. Sirve para apagarlo mientras el valor no está
  /// confirmado.
  final Color? titleColor;

  /// Cabecera de la variante en lista; normalmente un `FernSectionHeader`.
  final Widget? header;

  /// Elementos de la variante en lista, en vertical y desplazables.
  final List<Widget>? items;
  final double itemSpacing;
  final double maxItemsHeight;

  final Widget? footer;

  const FernDialogSidePanel({
    super.key,
    required Widget this.avatar,
    required String this.title,
    this.titleColor,
    this.footer,
  })  : header = null,
        items = null,
        itemSpacing = AppSpacing.s,
        maxItemsHeight = 0;

  const FernDialogSidePanel.list({
    super.key,
    required Widget this.header,
    required List<Widget> this.items,
    this.itemSpacing = AppSpacing.s,
    this.maxItemsHeight = 240,
    this.footer,
  })  : avatar = null,
        title = null,
        titleColor = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items == null ? _avatarChildren(context) : _listChildren(),
    );
  }

  List<Widget> _avatarChildren(BuildContext context) {
    return [
      avatar!,
      const SizedBox(height: AppSpacing.l),
      Text(
        title!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
      ),
      const SizedBox(height: AppSpacing.s),
      const Divider(thickness: 2),
      if (footer != null) footer!,
    ];
  }

  List<Widget> _listChildren() {
    final items = this.items!;

    return [
      header!,
      const SizedBox(height: AppSpacing.s),
      const Divider(thickness: 2),
      const SizedBox(height: AppSpacing.m),
      // La lista se pinta bajo demanda y con altura acotada: el panel aguanta
      // igual con dos elementos que con cien.
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxItemsHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: itemSpacing),
          itemBuilder: (_, index) => Align(
            alignment: Alignment.centerLeft,
            child: items[index],
          ),
        ),
      ),
      if (footer != null) footer!,
    ];
  }
}
