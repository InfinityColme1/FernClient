import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Un texto que va cambiando mientras se instala el entorno.
///
/// Instalar tarda varios minutos y hay tramos enteros en los que no hay número
/// que enseñar: `uv` no dice por dónde va al instalar un paquete. Una barra
/// quieta y un rótulo fijo durante tres minutos parecen un cuelgue, así que esto
/// va rotando frases que dicen que se sigue trabajando.
///
/// No pretende contar lo que está pasando de verdad en cada instante: lo que
/// cuenta es el rótulo de la etapa, que sí es real. Esto es señal de vida.
class SidecarActivityText extends StatefulWidget {
  const SidecarActivityText({super.key});

  @override
  State<SidecarActivityText> createState() => _SidecarActivityTextState();
}

class _SidecarActivityTextState extends State<SidecarActivityText> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      sidecarActivityRotation,
      (_) => setState(() => _index++),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<String> _messages(AppLocalizations texts) => [
        texts.sidecarBusyDownloading,
        texts.sidecarBusyUnpacking,
        texts.sidecarBusyPatience,
        texts.sidecarBusySettling,
        texts.sidecarBusyKeepUsing,
      ];

  @override
  Widget build(BuildContext context) {
    final messages = _messages(AppLocalizations.of(context));

    // El hueco es siempre el mismo, ocupando todo el ancho y con un alto fijo.
    // Sin esto la caja se encoge y se estira con cada frase, y como el
    // `AnimatedSwitcher` centra lo que le pongan dentro, el texto aparecía
    // corrido a la derecha y saltaba a su sitio al desaparecer el anterior.
    return SizedBox(
      width: double.infinity,
      height: AppSizes.sidecarActivityHeight,
      child: AnimatedSwitcher(
        duration: sidecarActivityFade,
        // Primero se va del todo el texto anterior y después entra el nuevo, en
        // lugar de cruzarse los dos a media opacidad, que se lee fatal.
        switchOutCurve: const Interval(0.6, 1.0, curve: Curves.easeIn),
        switchInCurve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        layoutBuilder: (current, previous) => Stack(
          // Pegados a la izquierda: es lo que hace que las frases empiecen todas
          // en la misma columna, midan lo que midan.
          alignment: Alignment.centerLeft,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          // Un desplazamiento mínimo hacia arriba acompaña al fundido: sin él el
          // cambio es correcto pero seco.
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, sidecarActivitySlide),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          // La clave hace que el cambio se vea: sin ella el widget es el mismo y
          // el texto cambiaría de golpe.
          key: ValueKey(_index % messages.length),
          child: Text(
            messages[_index % messages.length],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ),
      ),
    );
  }
}
