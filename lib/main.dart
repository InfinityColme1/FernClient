import 'dart:ui' show AppExitResponse;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/recognition/data/services/import_recognition_hook.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/domain/usecases/purge_old_rejections_usecase.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/media/presentation/services/dialog_import_decisions.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/settings/presentation/theme_palette.dart';
import 'package:Fern/l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'config/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/service_locator.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // El techo de la caché de imágenes, antes de que se pinte nada. De fábrica son
  // 100 MB, que con las imágenes de veinte megapíxeles de una biblioteca de
  // verdad se agotan en una pantalla de rejilla: a partir de ahí la aplicación
  // se pasa el rato decodificando y tirando lo que acaba de decodificar, y eso
  // es lo que se nota al desplazarse deprisa.
  PaintingBinding.instance.imageCache.maximumSizeBytes = imageCacheMaxBytes;

  // Poner la base de datos al día es lo primero que se hace y lo único que puede
  // impedir que la aplicación abra: con las filas a medio convertir, cualquier
  // pantalla que las leyera las estropearía un poco más.
  try {
    await initializeDependencies();
  } on SchemaMigrationException catch (error) {
    runApp(StartupErrorApp(details: error.toString()));
    return;
  }

  // Una importación puede necesitar preguntarle algo al usuario por el camino
  // (una publicación con varios enlaces, por ejemplo). Aquí se dice quién
  // contesta: con diálogos, y por encima de la pantalla que esté puesta.
  getIt<ImportDecisions>().handler = const DialogImportDecisions();

  // La papelera se vacía sola: lo que lleve más de una semana marcado sale de la
  // base de datos al arrancar, sin que haya que entrar en la pantalla de
  // eliminados a mirar.
  await getIt<PurgeExpiredDeletedMediaUseCase>()();

  // Y con ella, los rechazos viejos. Van juntos porque son lo mismo: cosas que
  // caducan y que nadie va a ir a limpiar a mano. Sin `await`: no hay ninguna
  // pantalla esperando a que termine, y arrancar es lo que no puede esperar.
  unawaited(getIt<PurgeOldRejectionsUseCase>()());

  runApp(const MyApp());
}

/// Lo único que se enseña cuando la base de datos no se ha podido poner al día.
///
/// No hay ajustes ni idioma elegido que valgan (los ajustes viven detrás de lo
/// que ha fallado), así que va con el tema claro y el idioma del sistema. El
/// detalle técnico se enseña tal cual: es lo que hace falta para poder contar
/// qué ha pasado.
class StartupErrorApp extends StatelessWidget {
  final String details;

  const StartupErrorApp({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final texts = AppLocalizations.of(context);
          final theme = Theme.of(context);

          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.startupErrorMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppSizes.iconHuge,
                        color: context.colors.error,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        texts.startupFailedTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        texts.startupFailedDatabase,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        texts.startupFailedHint,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.gray),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SelectableText(
                        details,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.gray),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();

    // Cerrar la ventana tiene que llevarse también lo que la aplicación haya
    // arrancado por detrás. Sin esto, el Python del reconocimiento se quedaba
    // vivo después de salir y, como tiene abiertos los ficheros de su propio
    // entorno, la siguiente instalación fallaba con "Acceso denegado" sin que
    // hubiera forma de arreglarlo desde la aplicación.
    _lifecycle = AppLifecycleListener(onExitRequested: _onExitRequested);
  }

  Future<AppExitResponse> _onExitRequested() async {
    // Lo que estuviera esperando para mandarse a reconocer se queda sin mandar:
    // el temporizador está vivo y encolaría un trabajo contra una aplicación que
    // ya se está yendo.
    getIt<ImportRecognitionHook>().dispose();

    await getIt<RecognitionEngine>().dispose();

    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // El bloc de ajustes se provee desde la raíz porque el idioma y el tema son
    // suyos: al cambiar cualquiera de los dos se reconstruye la aplicación
    // entera, que es lo que hace que el cambio se vea al instante y sin
    // reiniciar.
    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.language != current.settings.language ||
            previous.settings.themeMode != current.settings.themeMode ||
            previous.settings.customTheme != current.settings.customTheme,
        builder: (context, state) {
          final settings = state.settings;

          // Con el tema a medida no hay dos temas entre los que elegir: hay uno,
          // el del usuario, y se pone tanto en el claro como en el oscuro para
          // que el sistema no pueda cambiarlo por debajo.
          final custom = settings.themeMode == AppThemeMode.custom
              ? AppTheme.of(settings.customTheme.palette)
              : null;

          return MaterialApp.router(
            title: appName,
            theme: custom ?? AppTheme.lightTheme,
            darkTheme: custom ?? AppTheme.darkTheme,
            themeMode: switch (settings.themeMode) {
              AppThemeMode.system => ThemeMode.system,
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
              AppThemeMode.custom => ThemeMode.light,
            },
            locale: Locale(settings.language.code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
