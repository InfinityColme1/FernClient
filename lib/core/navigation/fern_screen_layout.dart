import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/navigation/screen_choreography.dart';
import 'package:Fern/core/navigation/screen_slot.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:flutter/material.dart';

/// El armazón de las pantallas que son **una cabecera y una rejilla**: la
/// biblioteca, la importación, la papelera, los favoritos, el navegador y los
/// modelos.
///
/// **Por qué existe.** Las seis repetían la misma maquetación copiada —el mismo
/// relleno de página, el mismo hueco bajo la cabecera, el mismo `Expanded`— y
/// ninguna decía cuál de sus dos trozos era cuál. Eso último es lo que hace
/// falta para que la transición entre pantallas signifique algo: la cabecera se
/// retira hacia arriba y la rejilla hacia abajo, cada una por donde estaba.
///
/// Diciéndolo aquí se dice una vez.
class FernGridScreen extends StatelessWidget {
  /// La fila de arriba: cuentas, filtros, botones. Se va por arriba.
  final Widget header;

  /// Lo que ocupa el resto. Se va por abajo.
  final Widget body;

  /// Relleno de la pantalla. El de siempre salvo que se diga otro.
  final EdgeInsetsGeometry padding;

  /// Hueco entre la cabecera y lo de abajo.
  final EdgeInsetsGeometry headerPadding;

  const FernGridScreen({
    super.key,
    required this.header,
    required this.body,
    this.padding =
        const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
    this.headerPadding = const EdgeInsets.only(
      right: AppSpacing.xl,
      bottom: AppSpacing.l,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenSlotTransition(
            slot: ScreenSlot.header,
            child: Padding(
              padding: headerPadding,
              child: TutorialAnchor(
                id: TutorialAnchorId.screenHeader,
                child: header,
              ),
            ),
          ),
          Expanded(
            child: ScreenSlotTransition(
              slot: ScreenSlot.grid,
              child: TutorialAnchor(
                id: TutorialAnchorId.screenBody,
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// El armazón de las pantallas de **gestión**: la de etiquetas y la de
/// creadores.
///
/// Tres piezas y cada una entra por su lado: la ficha desde arriba, la rejilla
/// de lo que cuelga de ella desde abajo y la lista desde la derecha, que es
/// donde vive.
class FernManagementScreen extends StatelessWidget {
  /// La ficha editable de lo que esté elegido.
  ///
  /// Recibe el hueco de la columna entera —ficha y rejilla— porque hay quien lo
  /// necesita: la ficha de un creador reparte ese alto con la rejilla de debajo
  /// para que todos los creadores tengan la misma y la rejilla no se mueva de
  /// sitio al cambiar de uno a otro. Dentro de la columna ese dato ya no está: al
  /// no ser la pieza que se estira, se le ofrece alto ilimitado.
  final Widget Function(BuildContext context, BoxConstraints space) cardBuilder;

  /// La rejilla del contenido que cuelga de ello.
  final Widget grid;

  /// La lista de la derecha.
  final Widget list;

  /// Lo ancha que es la lista.
  final double listWidth;

  final EdgeInsetsGeometry padding;

  const FernManagementScreen({
    super.key,
    required this.cardBuilder,
    required this.grid,
    required this.list,
    required this.listWidth,
    this.padding = AppSpacing.pagePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, space) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenSlotTransition(
                    slot: ScreenSlot.card,
                    child: TutorialAnchor(
                      id: TutorialAnchorId.screenCard,
                      child: cardBuilder(context, space),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Expanded(
                    child: ScreenSlotTransition(
                      slot: ScreenSlot.grid,
                      child: TutorialAnchor(
                        id: TutorialAnchorId.screenBody,
                        child: grid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          SizedBox(
            width: listWidth,
            child: ScreenSlotTransition(
              slot: ScreenSlot.list,
              child: TutorialAnchor(
                id: TutorialAnchorId.screenList,
                child: list,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
