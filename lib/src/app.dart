import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/di/dependency_injection.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart';
import 'package:my_app/src/features/splash/cubit/app_cubit.dart';
import 'package:my_app/src/router/router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = RouterController(getIt.get()).router;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();
    final settings = BlocProvider.of<SettingsCubit>(context, listen: true);
    log('Settings: ${settings.state.theme}');
    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingCubit>(create: (_) => getIt.get()),
        BlocProvider<AppCubit>(create: (_) => getIt.get()),
        BlocProvider<AuthCubit>(create: (_) => getIt.get()),
        BlocProvider<GameCubit>(create: (_) => getIt.get()),
        BlocProvider<PlayerCubit>(create: (_) => getIt.get()),
        // BlocProvider<SettingsCubit>(create: (_) => getIt.get()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme.light,
        darkTheme: theme.dark,
        locale: settings.state.locale,
        themeMode: settings.state.theme,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
