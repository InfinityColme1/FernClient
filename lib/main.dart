import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/usecases/purge_expired_deleted_media_usecase.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
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
    // El bloc de ajustes se provee desde la raíz porque el idioma es suyo: al
    // cambiarlo se reconstruye la aplicación entera con el nuevo `locale`, que
    // es lo que hace que el cambio se vea al instante y sin reiniciar.
    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.language != current.settings.language,
        builder: (context, state) => MaterialApp.router(
          title: appName,
          theme: AppTheme.lightTheme,
          locale: Locale(state.settings.language.code),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
