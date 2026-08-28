import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Los iconos de la aplicación, y la regla con la que se eligen.
///
/// **Un solo juego: Material Symbols.** Antes convivían dos. El resto de la
/// aplicación usaba `Icons` —los iconos clásicos, de trazo fijo— y la barra del
/// visor usaba `Symbols`, que son los nuevos y sí dejan pedir el grosor. Encima,
/// dentro de `Icons` se mezclaban tres estilos del mismo concepto: `person` con
/// `person_outline`, `label` con `label_outline`. Cada mezcla es pequeña y
/// ninguna rompe nada; el conjunto es lo que se nota, y por eso no lo caza nadie
/// leyendo un diff.
///
/// **El relleno es un eje, no otro icono.** Ésta es la ventaja de fondo de
/// Symbols y por la que se ha unificado hacia ellos: un corazón marcado no es un
/// glifo distinto del sin marcar, es el mismo con `fill: 1`. La diferencia se
/// dice donde se pinta —`Icon(AppIcons.favorite, fill: 1)`— en lugar de con dos
/// nombres que hay que acordarse de mantener emparejados.
///
/// Y sólo significa eso: «esto está puesto». Fuera de un estado, relleno no
/// quiere decir nada y no se usa.
///
/// Los conceptos del dominio salen de aquí y no de un `Icons.` suelto en cada
/// pantalla: así el mismo concepto se dibuja igual en el menú lateral, en el
/// menú de crear, en el buscador y en la ficha, que es donde se veía que no.
class AppIcons {
  const AppIcons._();

  // Lo que la biblioteca guarda.
  static const media = Symbols.image;
  static const video = Symbols.movie;

  /// El favorito. Con `fill: 1` es uno que ya lo es.
  static const favorite = Symbols.favorite;

  static const deleted = Symbols.delete;
  static const collections = Symbols.folder_open;

  // Quién y con qué se clasifica.
  static const creator = Symbols.person;
  static const tag = Symbols.label;

  static const fernie = Symbols.face_retouching_natural;

  // Reconocimiento.
  static const model = Symbols.hub;
  static const modelTree = Symbols.account_tree;

  /// Reconocer. Con `fill: 1` es lo que ya ha pasado por ahí.
  static const recognize = Symbols.auto_awesome;

  // Traer contenido.
  static const import = Symbols.download;
  static const refresh = Symbols.refresh;
  static const folder = Symbols.folder_open;
  static const browser = Symbols.travel_explore;
  static const link = Symbols.link;

  // Acciones de siempre.
  static const add = Symbols.add;
  static const edit = Symbols.edit;
  static const remove = Symbols.delete;
  static const close = Symbols.close;
  static const check = Symbols.check;
  static const settings = Symbols.settings;
  static const info = Symbols.info;
  static const share = Symbols.share;

  // Selección.
  static const unselected = Symbols.radio_button_unchecked;

  /// Lo seleccionado. Con `fill: 1` se distingue de un lugar donde se podría
  /// seleccionar.
  static const selected = Symbols.check_circle;
  static const selectAll = Symbols.select_all;

  // NSFW.
  ///
  /// Con `fill: 1`, ya marcado.
  static const hidden = Symbols.visibility_off;
  static const visible = Symbols.visibility;
  static const locked = Symbols.lock;

  // Lo que va mal.
  static const warning = Symbols.warning_amber;
  static const error = Symbols.error;
  static const brokenMedia = Symbols.broken_image;

  /// Las entradas del menú lateral, por su identificador.
  static const Map<String, IconData> _sidebar = {
    'media': media,
    'import': import,
    'favorites': favorite,
    'collections': collections,
    'deleted': deleted,
  };

  /// El icono de una entrada del menú lateral.
  ///
  /// Devuelve un interrogante si el nombre no está: es preferible a reventar,
  /// porque quien se equivoca aquí lo ve en la pantalla en cuanto la abre.
  static IconData getIcon(String name) =>
      _sidebar[name.toLowerCase().trim()] ?? Symbols.question_mark;
}
