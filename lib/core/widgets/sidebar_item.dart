import 'package:flutter/material.dart';


class SidebarItem {
  /// Lo que identifica al botón dentro del menú, y con lo que se sabe cuál está
  /// marcado. No vale la posición: las etiquetas cambian de sitio en cuanto se
  /// crea otra, y lo marcado se quedaría en el botón equivocado.
  final String id;

  final String title;

  /// El icono con el que se pinta el botón. Es lo que se ve siempre, salvo que
  /// haya [avatarPath].
  final IconData icon;

  /// Icono en forma de imagen del paquete, para lo que no tiene glifo propio.
  /// Manda sobre [icon] cuando viene.

  /// Imagen con la que se pinta el botón en lugar del icono.
  ///
  /// La llevan las etiquetas que tienen avatar cuando el ajuste de apariencia lo
  /// pide; sin ella el botón se queda con su icono, que es lo que pasa también
  /// con las etiquetas que no tienen imagen puesta.
  final String? avatarPath;

  final VoidCallback onTap;

  /// Nivel del botón en la jerarquía: 0 el de las opciones normales y las
  /// etiquetas raíz, uno más por cada etiqueta que cuelga de otra.
  final int depth;

  /// Cuántos avisos hay pendientes en la pantalla a la que lleva. A cero no se
  /// pinta nada.
  final int badgeCount;

  /// La etiqueta esconde contenido tras el filtro NSFW.
  ///
  /// El menú la marca con un distintivo al final de la fila, donde no tapa su
  /// avatar: la imagen es con lo que se reconoce una etiqueta de un vistazo, y
  /// quitársela para avisar de algo cuesta más de lo que aporta.
  final bool isNsfw;

  /// Qué hacer con el contenido que se suelte encima de esta fila.
  ///
  /// Con esto puesto, la fila acepta que se le arrastren contenidos desde la
  /// rejilla. Sin ello se comporta como siempre: no todas las filas del menú
  /// significan algo que se le pueda poner a un contenido.
  final void Function(List<int> mediaIds)? onMediaDropped;

  SidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.onTap,
    this.avatarPath,
    this.depth = 0,
    this.badgeCount = 0,
    this.isNsfw = false,
    this.onMediaDropped,
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

  /// Con qué nombre puede señalar aquí el tutorial, si es que puede.
  ///
  /// Lo lleva el **rótulo** de la sección y no la sección entera: los botones se
  /// pintan uno a uno según se ven —las etiquetas pueden ser cientos— y meterlos
  /// todos en un mismo widget para poder medirlo obligaría a construirlos todos
  /// siempre.
  final String? anchorId;

  const SidebarSection({
    required this.title,
    required this.items,
    this.emptyMessage,
    this.anchorId,
  });
}
