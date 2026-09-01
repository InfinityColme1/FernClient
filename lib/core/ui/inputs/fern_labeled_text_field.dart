import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/inputs/fern_field_label.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Campo de texto con su etiqueta en negrita encima.
class FernLabeledTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Qué hacer al pulsar Enter dentro del campo.
  ///
  /// En un diálogo que pide una contraseña, escribir y pulsar Enter es el gesto
  /// de todo el mundo: sin esto había que soltar el teclado e ir a por el botón.
  final ValueChanged<String>? onSubmitted;

  final int? maxLines;

  /// El texto se pinta con puntos: es para los campos que nadie tiene por qué
  /// leer por encima del hombro (contraseñas y claves de las API).
  ///
  /// El campo trae entonces un botón para verlo: quien lo está escribiendo
  /// necesita poder comprobar lo que ha puesto, y esconderlo otra vez.
  final bool obscureText;

  const FernLabeledTextField({
    super.key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  State<FernLabeledTextField> createState() => _FernLabeledTextFieldState();
}

class _FernLabeledTextFieldState extends State<FernLabeledTextField> {
  /// El contenido está tapado. Empieza así en los campos ocultos y sólo cambia
  /// mientras el campo esté a la vista: al volver a la pantalla, lo oculto
  /// vuelve a estarlo.
  late bool _isObscured = widget.obscureText;

  @override
  void didUpdateWidget(FernLabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el campo deja de ser oculto (o pasa a serlo), manda lo que diga quien
    // lo monta.
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // El mismo rótulo que llevan los demás campos, y por el mismo sitio:
        // es de donde sale que todos se lean igual.
        FernFieldLabel(text: widget.label),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          // Con algo que hacer al enviar, la tecla de entrada dice lo que va a
          // pasar en vez de meter un salto de línea.
          textInputAction:
              widget.onSubmitted == null ? null : TextInputAction.done,
          // Un campo oculto es siempre de una línea: `maxLines` distinto de uno
          // no se lleva con `obscureText`.
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          obscureText: _isObscured,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.obscureText
                ? IconButton(
                    tooltip: _isObscured
                        ? texts.showPassword
                        : texts.hidePassword,
                    icon: Icon(
                      _isObscured
                          ? Symbols.visibility
                          : Symbols.visibility_off,
                      size: AppSizes.iconMedium,
                    ),
                    onPressed: () =>
                        setState(() => _isObscured = !_isObscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
