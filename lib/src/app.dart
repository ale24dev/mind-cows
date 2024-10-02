import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/di/dependency_injection.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/splash/cubit/app_cubit.dart';
import 'package:my_app/src/router/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();
    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingCubit>(create: (_) => getIt.get()),
        BlocProvider<AppCubit>(create: (_) => getIt.get()),
        BlocProvider<AuthCubit>(create: (_) => getIt.get()),
        BlocProvider<GameCubit>(create: (_) => getIt.get()),
        BlocProvider<PlayerCubit>(create: (_) => getIt.get()),
      ],
      child: MaterialApp.router(
        theme: theme.light,
        darkTheme: theme.dark,
        routerConfig: RouterController(getIt.get()).router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
