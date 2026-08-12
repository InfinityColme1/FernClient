import 'package:flutter/material.dart';


class SidebarItem {
  /// Lo que identifica al botón dentro del menú, y con lo que se sabe cuál está
  /// marcado. No vale la posición: las etiquetas cambian de sitio en cuanto se
  /// crea otra, y lo marcado se quedaría en el botón equivocado.
  final String id;

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  /// Nivel del botón en la jerarquía: 0 el de las opciones normales y las
  /// etiquetas raíz, uno más por cada etiqueta que cuelga de otra.
  final int depth;

  SidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.onTap,
    this.depth = 0,
  });
}

/// Un bloque del menú lateral: su rótulo y los botones que cuelgan de él.
///
/// Los bloques se separan entre sí con una línea horizontal, así que la sección
/// es también la unidad con la que se decide dónde va cada separador.
class SidebarSection {
  final String title;
  final List<SidebarItem> items;

  /// Qué pintar cuando la sección no tiene ningún botón (las etiquetas, mientras
  /// no se haya creado ninguna). Sin texto, la sección vacía no se pinta.
  final String? emptyMessage;

  const SidebarSection({
    required this.title,
    required this.items,
    this.emptyMessage,
  });
}
