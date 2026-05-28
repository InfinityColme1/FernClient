import 'package:fernclient/core/config/theme/app_theme.dart';
import 'package:fernclient/presentation/hub/bloc/hub_cubit.dart';
import 'package:fernclient/presentation/hub/pages/hub.dart';
import 'package:fernclient/presentation/splash/pages/splash.dart';
import 'package:fernclient/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HubCubit())
      ],
      child: MaterialApp(
          title: 'Fern',
          theme: AppTheme.lightTheme,
          home: const HubPage(),
        ),
    );
  }
}
