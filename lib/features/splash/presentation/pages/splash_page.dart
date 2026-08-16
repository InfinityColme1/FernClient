import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// La pantalla con la que arranca la aplicación: el logo sobre blanco mientras
/// dura su animación, y de ahí a la biblioteca.
///
/// La animación se monta con las animaciones de Flutter en lugar de traerse un
/// fichero de Lottie: es un logo que aparece y un círculo que se abre detrás,
/// que es lo que se pide, y así no hay ni librería ni asset nuevos que mantener
/// para dos segundos de pantalla.
///
/// Se sale sola y no se vuelve: se navega con `go`, así que la pantalla de
/// bienvenida no queda debajo de la biblioteca ni se llega a ella con el botón
/// de atrás.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// El logo aparece y crece hasta su tamaño, con un rebote al asentarse.
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  /// El círculo de detrás se abre y se apaga a la vez, de modo que acompaña al
  /// logo sin llegar a competir con él.
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: splashDuration);

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: splashLogoInitialScale, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _haloScale =
        Tween<double>(begin: splashHaloMinScale, end: splashHaloMaxScale)
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _haloOpacity = Tween<double>(begin: splashHaloOpacity, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().whenComplete(_enterLibrary);
  }

  /// A la biblioteca en cuanto termina la animación. La comprobación es por si
  /// la pantalla ya no está: la animación puede acabar con la aplicación
  /// cerrándose.
  void _enterLibrary() {
    if (!mounted) return;
    context.go(mediaRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Blanco y no el fondo de la aplicación: la bienvenida es la marca, y el
      // logo se lee sobre blanco.
      backgroundColor: context.colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          // El logo se pasa como `child` para que no se reconstruya en cada
          // fotograma: lo único que cambia por fotograma es cómo se pinta.
          child: Image.asset(appLogo, width: splashLogoWidth),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: _haloOpacity.value,
                  child: Transform.scale(
                    scale: _haloScale.value,
                    child: Container(
                      width: splashHaloSize,
                      height: splashHaloSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
