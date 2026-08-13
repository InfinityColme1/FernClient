import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Campo de texto con su etiqueta en negrita encima.
class FernLabeledTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
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
        Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
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
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
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
