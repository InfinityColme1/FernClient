import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/media/presentation/services/dialog_import_decisions.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/settings/presentation/theme_palette.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'config/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/service_locator.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initializeDependencies();

  // Una importación puede necesitar preguntarle algo al usuario por el camino
  // (una publicación con varios enlaces, por ejemplo). Aquí se dice quién
  // contesta: con diálogos, y por encima de la pantalla que esté puesta.
  getIt<ImportDecisions>().handler = const DialogImportDecisions();

  // La papelera se vacía sola: lo que lleve más de una semana marcado sale de la
  // base de datos al arrancar, sin que haya que entrar en la pantalla de
  // eliminados a mirar.
  await getIt<PurgeExpiredDeletedMediaUseCase>()();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
