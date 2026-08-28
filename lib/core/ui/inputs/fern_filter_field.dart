import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Campo para acotar una lista larga escribiendo parte de un nombre.
///
/// No es el buscador de la aplicación: aquél busca contenido por toda la
/// biblioteca y sugiere. Éste no sale de la lista que tiene debajo y no propone
/// nada — sólo esconde lo que no encaja. Con veinte etiquetas sobra la lista;
/// con doscientas, hace falta esto.
///
/// Lleva su propia cruz de limpiar: sin ella hay que borrar a mano lo escrito
/// para volver a ver la lista entera, y eso con un nombre largo son quince
/// pulsaciones.
class FernFilterField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const FernFilterField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<FernFilterField> createState() => _FernFilterFieldState();
}

class _FernFilterFieldState extends State<FernFilterField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(String value) {
    widget.onChanged(value);

    // Sólo cuando aparece o desaparece la cruz: repintar el campo en cada tecla
    // no cambiaría nada más.
    if (value.isEmpty || _controller.text.isEmpty) setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: _controller,
      onChanged: _set,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hintText,
        isDense: true,
        prefixIcon: Icon(
          Symbols.search,
          size: AppSizes.iconMedium,
          color: colors.unremarked,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: AppSizes.filterFieldIconSlot,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: _clear,
                icon: Icon(
                  Symbols.close,
                  size: AppSizes.iconMedium,
                  color: colors.unremarked,
                ),
              ),
      ),
    );
  }
}
