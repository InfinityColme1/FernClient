import 'package:flutter/material.dart';

/// El rótulo que va **encima** de un campo y dice qué se escribe en él.
///
/// Es uno solo para todos los campos de la aplicación a propósito. Antes había
/// dos: éste, que se apoyaba flotando sobre el borde de los campos con contorno,
/// y el que el campo de texto normal se pintaba por su cuenta. Como los dos
/// rótulos no eran el mismo, tampoco lo eran los campos: en un mismo diálogo
/// convivían un campo con marco grueso y rótulo colgado del borde y otro con
/// marco fino y rótulo encima, y el primero se llevaba toda la atención sin
/// merecerla más que el segundo.
///
/// Flotar sobre el borde tenía además un coste propio: el rótulo tenía que
/// taparlo con el color de la superficie de debajo, así que había que saber
/// sobre qué se estaba pintando. Encima del campo no tapa nada.
class FernFieldLabel extends StatelessWidget {
  final String text;

  const FernFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
