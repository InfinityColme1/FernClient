import 'dart:async';
import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/display/region_painter.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Con qué se está trabajando sobre el contenido.
///
/// Son dos oficios sobre el mismo lienzo y no caben a la vez: con [mark],
/// arrastrar dibuja una región nueva; con [edit], arrastrar estira la que esté
/// elegida. Sin separarlas, cada arrastre sería una adivinanza.
enum FernRegionTool { mark, edit }

/// Qué se está haciendo con el ratón encima del contenido.
enum _Drag { none, drawing, moving, resizing, panning }

/// Capa que se pone sobre el contenido para marcar y editar regiones.
///
/// Cuando está apagada no atiende al ratón y sólo dibuja: es lo que usa el visor
/// para resaltar una región al abrirla desde la pantalla de fernies. Cuando está
/// encendida se queda con todos los gestos del contenido, y por eso se encarga
/// también del zoom y del desplazamiento: si sólo interceptara el arrastre, la
/// rueda y el paneo dejarían de llegar al visor que tiene debajo.
///
/// Reparto de gestos con la capa encendida:
///
/// | Gesto                            | Marcar          | Editar               |
/// |----------------------------------|-----------------|----------------------|
/// | Rueda                            | zoom            | zoom                 |
/// | Arrastre con el izquierdo        | dibujar región  | mover o estirar      |
/// | Clic con el izquierdo            | —               | elegir o reasignar   |
/// | Arrastre con el central          | desplazar       | desplazar            |
/// | Espacio mantenido + arrastre     | desplazar       | desplazar            |
/// | Doble clic                       | ajustar         | región de debajo     |
///
/// Con la herramienta de editar, el doble clic **sólo baja**: de la de encima a
/// la de debajo, y al llegar al fondo se queda ahí. Dar la vuelta dejaría sin
/// salida a una región tapada del todo por otra, porque volver a la de arriba
/// taparía otra vez su menú.
///
/// La región elegida y su rectángulo en curso **los manda quien la usa**: la
/// capa pide los cambios y espera a que se los devuelvan. Es lo que permite que
/// el visor pueda avisar antes de perder lo que se lleva editado.
///
/// No sabe nada del dominio: recibe rectángulos normalizados y devuelve
/// rectángulos normalizados. Quien la usa decide qué significan.
class FernRegionSelectionLayer extends StatefulWidget {
  /// El visor que va debajo. Con la capa apagada recibe los gestos él.
  final Widget child;

  final bool enabled;

  /// Con qué se está trabajando. Sin el modo encendido no pinta nada.
  final FernRegionTool tool;

  /// Tamaño del contenido original, en píxeles.
  ///
  /// Es `null` mientras no se haya podido medir el fichero. Sin la medida no hay
  /// forma de saber a qué parte de la imagen corresponde un punto de la
  /// pantalla, así que la capa no dibuja ni deja marcar; el zoom, el paneo y el
  /// doble clic sí siguen funcionando, que no dependen de ella.
  final Size? contentSize;

  /// La transformación del visor. Es la misma que usa el `InteractiveViewer`
  /// que hay debajo, así que las regiones se quedan pegadas al contenido al
  /// hacer zoom.
  final TransformationController controller;

  /// Regiones ya marcadas, normalizadas, en el orden en el que se pintan.
  ///
  /// Las que llegan con `isVisible: false` siguen ocupando su sitio (los índices
  /// no pueden bailar) pero ni se pintan ni responden al ratón.
  final List<RegionVisual> regions;

  /// Por dónde va cada fernie ahora mismo. Se pintan pero no se tocan: son un
  /// recorrido, no regiones.
  final List<RegionVisual> previews;

  /// La región elegida, por su posición en [regions]. La manda quien usa la
  /// capa: aquí sólo se pide cambiarla.
  final int? selectedIndex;

  /// Las regiones que está resaltando ahora mismo el visor, y con qué
  /// intensidad. Varias porque el panel puede estar señalando un grupo de
  /// detecciones: lo mismo visto cuatro veces son cuatro rectángulos.
  final Set<int> highlightedIndexes;
  final double highlightIntensity;

  /// Cuánto se ven las regiones guardadas, de 0 a 1. A cero no se pinta
  /// ninguna, que es como se queda el visor fuera del modo de marcar.
  final double regionsOpacity;

  /// Área mínima, en tanto por uno del contenido, para que un arrastre cuente
  /// como región. Por debajo se descarta sin decir nada: es lo que evita que un
  /// clic despistado abra el menú de asignación.
  final double minRegionFraction;

  final double minScale;
  final double maxScale;

  /// Una región nueva, con el punto de la pantalla en el que se soltó el ratón:
  /// es donde tiene que abrirse el menú que la asigna a un fernie.
  /// Un toque suelto sobre el contenido, fuera del modo de marcar.
  ///
  /// La capa no sabe qué significa: el visor lo usa para reproducir y parar, que
  /// es lo que hace un toque en cualquier reproductor.
  final VoidCallback? onTap;

  final void Function(Rect normalized, Offset screenPosition)? onRegionDrawn;

  /// Se pide elegir otra región, o soltar la que hubiera con `null`.
  final void Function(int? index)? onSelectionRequested;

  /// Se pide reasignar la región elegida: ha vuelto a pulsarse encima.
  final void Function(Offset screenPosition)? onReassignRequested;

  /// El rectángulo de la región elegida mientras se la mueve o se la estira.
  final ValueChanged<Rect>? onDraftChanged;

  /// Si se está arrastrando un rectángulo ahora mismo.
  ///
  /// Lo mira el visor para apartar sus mandos mientras dura: si no, marcar algo
  /// que toca el borde de arriba obligaría a pelearse con la barra de acciones.
  final ValueChanged<bool>? onDrawingChanged;

  /// Lo que se pinta pegado a la región elegida, con su rectángulo ya en
  /// coordenadas de pantalla.
  ///
  /// Va aquí y no en el pintor porque tiene que poder pulsarse, y lo que dibuja
  /// un `CustomPainter` no atiende al ratón. Lo que lleva dentro lo pone quien
  /// usa la capa: aquí no se sabe qué se puede hacer con una región.
  final Widget Function(BuildContext context, Rect screenRect)?
      selectionOverlayBuilder;

  const FernRegionSelectionLayer({
    super.key,
    required this.child,
    required this.controller,
    this.contentSize,
    this.enabled = false,
    this.tool = FernRegionTool.mark,
    this.regions = const [],
    this.previews = const [],
    this.selectedIndex,
    this.highlightedIndexes = const {},
    this.highlightIntensity = 0,
    this.regionsOpacity = 1,
    this.minRegionFraction = 0.0025,
    this.minScale = 0.5,
    this.maxScale = 8.0,
    this.onTap,
    this.onRegionDrawn,
    this.onSelectionRequested,
    this.onReassignRequested,
    this.onDraftChanged,
    this.onDrawingChanged,
    this.selectionOverlayBuilder,
  });

  @override
  State<FernRegionSelectionLayer> createState() =>
      _FernRegionSelectionLayerState();
}

class _FernRegionSelectionLayerState extends State<FernRegionSelectionLayer> {
  /// Lo que se está arrastrando, si es que se está arrastrando algo.
  _Drag _drag = _Drag.none;

  /// Las dos esquinas del rectángulo que se está dibujando, en coordenadas del
  /// widget. Se guardan sin normalizar porque el arrastre puede ir en cualquier
  /// dirección y sólo al soltar se sabe cuál es la esquina superior izquierda.
  Offset? _anchor;
  Offset? _cursor;

  /// Qué tirador se está arrastrando al estirar la región elegida.
  Alignment? _resizingHandle;

  /// Dónde estaba el ratón en el movimiento anterior, para el desplazamiento y
  /// el movimiento de regiones.
  Offset? _lastPosition;

  /// La apertura del menú de reasignación, en espera de saber si lo que viene
  /// es un doble clic.
  ///
  /// Sólo se espera cuando hay algo debajo del puntero: sin ambigüedad el menú
  /// se abre al momento, que es lo que se hace casi siempre.
  Timer? _reassignTimer;

  /// El rectángulo de la región elegida mientras se la arrastra.
  ///
  /// Lo lleva la capa y no quien la usa porque un arrastre no puede esperar: el
  /// rectángulo de fuera llega en otro turno del bucle de eventos, y para
  /// entonces ya han entrado más movimientos del ratón. Tomando de base uno que
  /// se ha quedado atrás, cada movimiento pisa al anterior y la región avanza
  /// mucho menos de lo que se la mueve.
  ///
  /// Se suelta al terminar el arrastre: a partir de ahí manda otra vez el de
  /// fuera, que es quien sabe si se confirmó o se descartó.
  Rect? _localDraft;

  /// Dónde está el ratón, para saber qué cursor toca.
  ///
  /// Se guarda el cursor ya resuelto y no la posición: así el widget sólo se
  /// rehace cuando el cursor **cambia**, y no en cada píxel que se mueve el
  /// puntero.
  MouseCursor _hoverCursor = SystemMouseCursors.basic;

  /// Si el arrastre en curso ha llegado a mover algo.
  ///
  /// Es lo que distingue un clic de un arrastre sobre la región elegida: lo
  /// primero abre el menú para reasignarla, lo segundo la mueve.
  bool _hasMoved = false;

  Size _size = Size.zero;

  double get _scale => widget.controller.value.getMaxScaleOnAxis();

  bool get _isEnabled => widget.enabled && widget.contentSize != null;

  bool get _isMarking => _isEnabled && widget.tool == FernRegionTool.mark;

  bool get _isEditing => _isEnabled && widget.tool == FernRegionTool.edit;

  /// El rectángulo con el que hay que trabajar ahora mismo: el del arrastre en
  /// curso si lo hay, y el de fuera en cualquier otro caso.
  Rect _rectOf(int index) {
    if (index == _selected && _localDraft != null) return _localDraft!;

    return widget.regions[index].rect;
  }

  /// Las regiones tal y como hay que pintarlas, con el arrastre en curso ya
  /// puesto encima.
  List<RegionVisual> get _visuals {
    final draft = _localDraft;
    final index = _selected;
    if (draft == null || index == null) return widget.regions;

    return [
      for (var i = 0; i < widget.regions.length; i++)
        if (i == index)
          RegionVisual(
            rect: draft,
            label: widget.regions[i].label,
            isDimmed: widget.regions[i].isDimmed,
            isVisible: widget.regions[i].isVisible,
          )
        else
          widget.regions[i],
    ];
  }

  /// La región elegida, si la hay, sigue existiendo y se ve.
  ///
  /// Al moverse a otro fotograma, la que estaba elegida se esconde: deja de
  /// haber nada que tocar hasta volver a su instante.
  int? get _selected {
    final index = widget.selectedIndex;
    if (index == null || index < 0 || index >= widget.regions.length) {
      return null;
    }
    if (!widget.regions[index].isVisible) return null;

    return index;
  }

  /// El espacio se mantiene pulsado para desplazar, que es la alternativa al
  /// botón central para ratones sin rueda pulsable.
  bool get _isPanKeyPressed => HardwareKeyboard.instance.logicalKeysPressed
      .contains(LogicalKeyboardKey.space);

  @override
  void initState() {
    super.initState();

    // El cursor de partida es el que toque sin haber movido el ratón todavía:
    // con la herramienta de marcar, la cruz se ve nada más entrar al modo.
    _hoverCursor =
        _isMarking ? SystemMouseCursors.precise : SystemMouseCursors.basic;
  }

  @override
  void didUpdateWidget(covariant FernRegionSelectionLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Al salir del modo o al cambiar de herramienta se suelta lo que estuviera a
    // medias: al volver se empieza de cero.
    if ((oldWidget.enabled && !widget.enabled) ||
        oldWidget.tool != widget.tool) {
      _reset();
    }

    // Otra región elegida es otro rectángulo: el del arrastre anterior ya no
    // pinta nada.
    if (oldWidget.selectedIndex != widget.selectedIndex) _localDraft = null;
  }

  @override
  void dispose() {
    _cancelPendingReassign();
    super.dispose();
  }

  void _cancelPendingReassign() {
    _reassignTimer?.cancel();
    _reassignTimer = null;
  }

  void _reset() {
    _cancelPendingReassign();

    _localDraft = null;
    _hoverCursor =
        _isMarking ? SystemMouseCursors.precise : SystemMouseCursors.basic;

    // Salir a medio arrastre deja los mandos escondidos si no se dice que ya no
    // se está marcando.
    if (_drag == _Drag.drawing) widget.onDrawingChanged?.call(false);

    _drag = _Drag.none;
    _anchor = null;
    _cursor = null;
    _resizingHandle = null;
    _hasMoved = false;
  }

  // ---------------------------------------------------------------------------
  // Conversión de coordenadas
  // ---------------------------------------------------------------------------

  Rect _toNormalized(Rect widgetRect) {
    return widgetRectToNormalized(
      widgetRect,
      transform: widget.controller.value,
      widgetSize: _size,
      imageSize: widget.contentSize ?? Size.zero,
    );
  }

  Rect _toScreen(Rect normalized) {
    return normalizedRectToWidget(
      normalized,
      transform: widget.controller.value,
      widgetSize: _size,
      imageSize: widget.contentSize ?? Size.zero,
    );
  }

  /// El rectángulo que se está dibujando, en coordenadas del widget.
  Rect? get _pendingWidgetRect {
    final anchor = _anchor;
    final cursor = _cursor;
    if (anchor == null || cursor == null) return null;

    return Rect.fromPoints(anchor, cursor);
  }

  Rect? get _pendingNormalized {
    final rect = _pendingWidgetRect;
    if (rect == null || widget.contentSize == null) return null;

    return _toNormalized(rect);
  }

  // ---------------------------------------------------------------------------
  // Zoom y desplazamiento
  // ---------------------------------------------------------------------------

  /// Zoom con la rueda, alrededor del cursor: lo que hay debajo del puntero se
  /// queda debajo del puntero, que es lo que hace que acercarse a una zona
  /// concreta sea apuntar y girar.
  void _onScroll(PointerScrollEvent event) {
    final factor = event.scrollDelta.dy > 0 ? 1 / _zoomStep : _zoomStep;
    final target = (_scale * factor).clamp(widget.minScale, widget.maxScale);
    if (target == _scale) return;

    final matrix = Matrix4.tryInvert(widget.controller.value);
    if (matrix == null) return;

    final scene = MatrixUtils.transformPoint(matrix, event.localPosition);

    widget.controller.value = Matrix4.identity()
      ..translateByDouble(event.localPosition.dx, event.localPosition.dy, 0, 1)
      ..scaleByDouble(target, target, target, 1)
      ..translateByDouble(-scene.dx, -scene.dy, 0, 1);
  }

  static const _zoomStep = 1.15;

  void _panBy(Offset delta) {
    widget.controller.value = widget.controller.value.clone()
      ..translateByDouble(delta.dx / _scale, delta.dy / _scale, 0, 1);
  }

  /// Ajusta a pantalla: deshace zoom y desplazamiento de una vez.
  void _fitToScreen() => widget.controller.value = Matrix4.identity();

  /// Doble clic: con la herramienta de editar y varias regiones apiladas, baja
  /// a la siguiente; en cualquier otro caso, ajusta a pantalla.
  void _onDoubleTapAt(Offset position) {
    // Lo que venía era esto y no un clic suelto: el menú que estaba a punto de
    // abrirse se queda sin abrir.
    _cancelPendingReassign();

    if (!_isEditing) {
      _fitToScreen();
      return;
    }

    final stacked = _regionsAt(position);
    if (stacked.length < 2) {
      _fitToScreen();
      return;
    }

    // Se baja un peldaño desde la que esté elegida, y al llegar al fondo se
    // queda ahí.
    //
    // No da la vuelta a propósito: si volviera a la de encima, una región tapada
    // del todo por otra se quedaría sin forma de abrir su menú, que es lo que
    // este gesto viene a resolver. Sin nada elegido se coge la de más arriba,
    // que es la que gana al clic normal.
    final current = _selected;
    final next = (current == null ? -1 : stacked.indexOf(current)) + 1;

    if (next >= stacked.length) return;

    widget.onSelectionRequested?.call(stacked[next]);
  }

  // ---------------------------------------------------------------------------
  // Gestos
  // ---------------------------------------------------------------------------

  void _onPointerDown(PointerDownEvent event) {
    _lastPosition = event.localPosition;
    _hasMoved = false;

    // Si había un menú esperando su turno, el gesto nuevo manda.
    _cancelPendingReassign();

    final isPanRequest =
        event.buttons == kMiddleMouseButton || _isPanKeyPressed;

    if (isPanRequest) {
      setState(() => _drag = _Drag.panning);
      return;
    }

    if (event.buttons != kPrimaryMouseButton) return;

    // Sin la medida del fichero no se puede convertir nada, así que tampoco se
    // deja empezar a marcar: saldría una región en coordenadas inventadas.
    if (!_isEnabled) return;

    if (_isEditing) {
      _onEditPointerDown(event);
      return;
    }

    setState(() {
      _drag = _Drag.drawing;
      _anchor = event.localPosition;
      _cursor = event.localPosition;
    });

    widget.onDrawingChanged?.call(true);
  }

  /// Lo que hace pulsar con la herramienta de editar.
  ///
  /// Por orden: los tiradores de la elegida, el interior de la elegida, otra
  /// región, y por último el hueco, que la suelta.
  void _onEditPointerDown(PointerDownEvent event) {
    final selected = _selected;

    if (selected != null) {
      final handle = _handleAt(event.localPosition, selected);
      if (handle != null) {
        setState(() {
          _drag = _Drag.resizing;
          _resizingHandle = handle;
        });
        return;
      }

      if (_toScreen(_rectOf(selected)).contains(event.localPosition)) {
        setState(() => _drag = _Drag.moving);
        return;
      }
    }

    final index = _regionAt(event.localPosition);
    widget.onSelectionRequested?.call(index);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final previous = _lastPosition ?? event.localPosition;
    _lastPosition = event.localPosition;

    if ((event.localPosition - previous).distance > 0) _hasMoved = true;

    switch (_drag) {
      case _Drag.none:
        return;

      case _Drag.panning:
        _panBy(event.localPosition - previous);

      case _Drag.drawing:
        setState(() => _cursor = event.localPosition);

      case _Drag.moving:
        _moveSelected(event.localPosition - previous);

      case _Drag.resizing:
        _resizeSelected(event.localPosition);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    final drag = _drag;
    final moved = _hasMoved;

    _lastPosition = null;

    switch (drag) {
      case _Drag.none:
      case _Drag.panning:
      case _Drag.resizing:
        setState(() {
          _drag = _Drag.none;
          _resizingHandle = null;
          _localDraft = null;
        });

      case _Drag.drawing:
        _commitDrawn(event.position);

      case _Drag.moving:
        setState(() {
          _drag = _Drag.none;
          _localDraft = null;
        });

        // Pulsar sin arrastrar sobre la región que ya estaba elegida es pedir
        // cambiarla de fernie; arrastrar es moverla.
        if (!moved) _requestReassign(event.position, event.localPosition);
    }
  }

  /// Abre el menú para cambiarle el fernie a la región elegida.
  ///
  /// Con otra región debajo del puntero se espera lo que tarda un doble clic
  /// antes de abrirlo: ese doble clic es la forma de bajar a la de abajo, y si
  /// el menú se abriera al primer toque no habría manera de llegar nunca a ella.
  /// Sin nada debajo no hay ambigüedad y se abre en el acto.
  void _requestReassign(Offset globalPosition, Offset localPosition) {
    _cancelPendingReassign();

    if (_regionsAt(localPosition).length < 2) {
      widget.onReassignRequested?.call(globalPosition);
      return;
    }

    _reassignTimer = Timer(kDoubleTapTimeout, () {
      _reassignTimer = null;
      if (!mounted) return;

      widget.onReassignRequested?.call(globalPosition);
    });
  }

  /// Cierra el arrastre de una región nueva.
  ///
  /// Lo que no llega al área mínima se descarta sin decir nada: un clic suelto o
  /// un temblor de la mano no son una región, y abrir el menú de asignación por
  /// eso sería un estorbo constante.
  void _commitDrawn(Offset screenPosition) {
    final widgetRect = _pendingWidgetRect;

    setState(() {
      _drag = _Drag.none;
      _anchor = null;
      _cursor = null;
    });

    widget.onDrawingChanged?.call(false);

    if (widgetRect == null) return;

    final normalized = _toNormalized(widgetRect);
    if (normalized.width * normalized.height < widget.minRegionFraction) return;

    widget.onRegionDrawn?.call(normalized, screenPosition);
  }

  /// Mueve la región elegida por el interior, en pantalla.
  ///
  /// El desplazamiento se convierte a fracción del contenido pintado, no del
  /// widget: con zoom, mover diez píxeles de pantalla son menos de diez píxeles
  /// de imagen.
  void _moveSelected(Offset delta) {
    final index = _selected;
    if (index == null) return;

    final current = _rectOf(index);
    final painted = containedRect(widget.contentSize ?? Size.zero, _size);
    if (painted.width <= 0 || painted.height <= 0) return;

    final shift = Offset(
      delta.dx / (painted.width * _scale),
      delta.dy / (painted.height * _scale),
    );

    // Se mueve entera o no se mueve: recortarla al llegar al borde la deformaría
    // en lugar de detenerla.
    final moved = current.shift(shift);
    final dx = moved.left.clamp(0.0, 1 - moved.width) - moved.left;
    final dy = moved.top.clamp(0.0, 1 - moved.height) - moved.top;

    _publishDraft(moved.shift(Offset(dx, dy)));
  }

  /// Deja el rectángulo nuevo a la vista y se lo cuenta a quien usa la capa.
  ///
  /// El repintado no espera a la respuesta: la región va con el ratón y el de
  /// fuera se entera cuando le toque.
  void _publishDraft(Rect rect) {
    if (_localDraft == rect) return;

    setState(() => _localDraft = rect);
    widget.onDraftChanged?.call(rect);
  }

  /// Estira la región elegida por el tirador que se esté arrastrando.
  ///
  /// Los tiradores de los lados sólo mueven un eje: su alineación tiene un cero
  /// en el otro, y ese cero es lo que deja el borde contrario quieto.
  void _resizeSelected(Offset position) {
    final index = _selected;
    final handle = _resizingHandle;
    if (index == null || handle == null) return;

    final current = _rectOf(index);
    final point = _toNormalized(Rect.fromPoints(position, position)).topLeft;

    final left = handle.x < 0 ? point.dx : current.left;
    final right = handle.x > 0 ? point.dx : current.right;
    final top = handle.y < 0 ? point.dy : current.top;
    final bottom = handle.y > 0 ? point.dy : current.bottom;

    _publishDraft(clampNormalized(Rect.fromLTRB(
      math.min(left, right),
      math.min(top, bottom),
      math.max(left, right),
      math.max(top, bottom),
    )));
  }

  // ---------------------------------------------------------------------------
  // Aciertos
  // ---------------------------------------------------------------------------

  /// Los ocho tiradores de una región: las cuatro esquinas y el centro de cada
  /// lado, como los de una ventana.
  Map<Alignment, Offset> _handlesOf(Rect rect) {
    return {
      Alignment.topLeft: rect.topLeft,
      Alignment.topCenter: rect.topCenter,
      Alignment.topRight: rect.topRight,
      Alignment.centerLeft: rect.centerLeft,
      Alignment.centerRight: rect.centerRight,
      Alignment.bottomLeft: rect.bottomLeft,
      Alignment.bottomCenter: rect.bottomCenter,
      Alignment.bottomRight: rect.bottomRight,
    };
  }

  /// El tirador de la región [index] que hay bajo [position], si hay alguno.
  Alignment? _handleAt(Offset position, int index) {
    final rect = _toScreen(_rectOf(index));

    for (final entry in _handlesOf(rect).entries) {
      if ((entry.value - position).distance <= regionHandleReach) {
        return entry.key;
      }
    }

    return null;
  }

  /// Las regiones que hay bajo [position], de la de encima a la de debajo.
  ///
  /// Las escondidas no cuentan: no se ven, así que no se pueden pulsar.
  List<int> _regionsAt(Offset position) {
    return [
      for (var index = widget.regions.length - 1; index >= 0; index--)
        if (widget.regions[index].isVisible &&
            _toScreen(_rectOf(index)).contains(position))
          index,
    ];
  }

  /// La región que hay bajo [position]. Gana la que está encima.
  int? _regionAt(Offset position) {
    final stacked = _regionsAt(position);
    return stacked.isEmpty ? null : stacked.first;
  }

  // ---------------------------------------------------------------------------
  // Pintado
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            // La transformación cambia sin que cambie el estado de este widget
            // (el visor de debajo también la toca), así que el dibujo se cuelga
            // de ella y no de una reconstrucción.
            if (widget.contentSize case final contentSize?)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) => CustomPaint(
                      painter: RegionPainter(
                        regions: _visuals,
                        previews: widget.previews,
                        pending: _pendingNormalized,
                        selectedIndex: _isEditing ? _selected : null,
                        highlightedIndexes: widget.highlightedIndexes,
                        highlightIntensity: widget.highlightIntensity,
                        regionsOpacity: widget.regionsOpacity,
                        contentSize: contentSize,
                        transform: widget.controller.value,
                        strokeColor: context.colors.terciary,
                        scrimColor: context.colors.scrim,
                        labelColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: widget.enabled ? _buildInput() : _buildViewingInput(),
            ),
            if (_isEditing && _selected != null) _buildSelectionOverlay(),
          ],
        );
      },
    );
  }

  /// Lo que le falta al visor en modo visualización: el doble clic para ajustar
  /// a pantalla, que `InteractiveViewer` no trae de serie, y el toque suelto
  /// para quien lo esté mirando.
  ///
  /// Va translúcido a propósito, no opaco: así el visor de debajo sigue
  /// recibiendo la rueda y el arrastre, y lo único que se queda esta capa son
  /// los toques.
  Widget _buildViewingInput() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onDoubleTap: _fitToScreen,
    );
  }

  Widget _buildInput() {
    return MouseRegion(
      cursor: _hoverCursor,
      onHover: _onHover,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) _onScroll(event);
        },
        // Opaco para quedarse con todos los gestos del contenido: el visor de
        // debajo no debe recibir ninguno mientras se está marcando.
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTapDown: (details) => _onDoubleTapAt(details.localPosition),
          onDoubleTap: () {},
        ),
      ),
    );
  }

  /// Recalcula el cursor con el ratón donde esté.
  ///
  /// Sólo rehace el widget cuando el cursor cambia de verdad: moverse por dentro
  /// de una región sin cruzar ningún tirador no tiene por qué repintar nada.
  void _onHover(PointerHoverEvent event) {
    final cursor = _cursorAt(event.localPosition);
    if (_hoverCursor == cursor) return;

    setState(() => _hoverCursor = cursor);
  }

  /// El cursor dice qué va a pasar al pulsar, sin tener que pulsar para
  /// averiguarlo.
  ///
  /// Con la herramienta de editar son las mismas flechas que usa cualquier
  /// ventana del sistema para sus bordes, que es donde el usuario ya las ha
  /// aprendido.
  MouseCursor _cursorAt(Offset position) {
    if (_drag == _Drag.panning || _isPanKeyPressed) {
      return SystemMouseCursors.grabbing;
    }

    if (_isMarking) return SystemMouseCursors.precise;
    if (!_isEditing) return SystemMouseCursors.basic;

    final selected = _selected;
    if (selected != null) {
      if (_handleAt(position, selected) case final handle?) {
        return _resizeCursorFor(handle);
      }

      if (_toScreen(_rectOf(selected)).contains(position)) {
        return SystemMouseCursors.move;
      }
    }

    // Sobre otra región, la mano de «esto se puede elegir».
    return _regionAt(position) != null
        ? SystemMouseCursors.click
        : SystemMouseCursors.basic;
  }

  /// La flecha que le toca a cada tirador: en diagonal las esquinas, y recta
  /// para los lados, que sólo estiran en un eje.
  MouseCursor _resizeCursorFor(Alignment handle) {
    if (handle.x == 0) return SystemMouseCursors.resizeUpDown;
    if (handle.y == 0) return SystemMouseCursors.resizeLeftRight;

    return handle.x == handle.y
        ? SystemMouseCursors.resizeUpLeftDownRight
        : SystemMouseCursors.resizeUpRightDownLeft;
  }

  /// Lo que se pinta pegado a la región elegida.
  Widget _buildSelectionOverlay() {
    final builder = widget.selectionOverlayBuilder;
    final index = _selected;
    if (builder == null || index == null) return const SizedBox.shrink();

    final rect = _toScreen(_rectOf(index));

    return Positioned(
      // Pegada por fuera de la esquina superior derecha: dentro taparía justo lo
      // que se está mirando.
      left: rect.right - regionTabWidth,
      top: math.max(0, rect.top - regionTabHeight - AppSpacing.xs),
      child: builder(context, rect),
    );
  }
}
