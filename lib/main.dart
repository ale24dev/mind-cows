import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/src/app.dart';
import 'package:my_app/src/core/di/dependency_injection.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/features/home/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('ANON_KEY'),
  );

  configureDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt.get()),
        BlocProvider<GameCubit>(create: (_) => getIt.get()),
        BlocProvider<PlayerCubit>(create: (_) => getIt.get()),
      ],
      child: const MyApp(),
    ),
  );
}
