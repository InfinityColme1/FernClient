import 'package:flutter/material.dart';

/// Si el sistema ha pedido que se mueva lo menos posible.
///
/// **Por qué esto no es opcional.** Hay quien tiene puesto «reducir movimiento»
/// en el sistema porque el movimiento en pantalla le marea de verdad: no es una
/// preferencia estética, es una condición. Windows lo expone y Flutter lo trae
/// en el `MediaQuery`, así que respetarlo cuesta una línea por animación.
///
/// Lo que se hace no es quitar la animación sino **dejarla en cero**: el estado
/// final es el mismo y no hay que escribir dos versiones de cada pantalla.
extension FernMotion on BuildContext {
  /// La duración que toca aquí: la pedida, o ninguna si se ha pedido calma.
  Duration motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : duration;

  /// Si conviene ahorrarse los adornos que sólo se mueven: un halo que late, un
  /// brillo que recorre un esqueleto de carga.
  ///
  /// A diferencia de [motion], aquí no vale con acortar: una animación que se
  /// repite sola en bucle no termina nunca, así que o no está o sigue molestando.
  bool get prefersStillness => MediaQuery.disableAnimationsOf(this);
}
