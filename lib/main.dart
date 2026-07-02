import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/service_locator.dart';
import 'features/media/presentation/blocs/media_bloc.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
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
        BlocProvider(create: (BuildContext context) => MediaBloc())
      ],
      child: MaterialApp.router(
        title: appName,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
