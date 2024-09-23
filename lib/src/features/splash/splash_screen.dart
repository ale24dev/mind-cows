import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/splash/cubit/app_cubit.dart';
import 'package:my_app/src/router/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // final client = Supabase.instance.client;
    context.read<AppCubit>().initialize();

    // client.auth.onAuthStateChange.listen((authSupState) {
    //   log('AUTH message');

    //   final route = switch (authSupState.event) {
    //     AuthChangeEvent.initialSession => AppRoutes.initProfileData,
    //     AuthChangeEvent.signedIn => AppRoutes.initProfileData,
    //     AuthChangeEvent.signedOut => AppRoutes.auth,
    //     _ => AppRoutes.home,
    //   };
    //   WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
    //     log(route);
    //     Navigator.pushReplacementNamed(context, route);
    //   });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.isSuccess && state.initialized) {
            context.read<GameCubit>().setGameStatus(state.gameStatus);
          }
          if (state.isError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text('An error has occurred'),
                ),
                const Gutter(),
                GenericButton(
                  widget: Text(
                    'Retry',
                    style: AppTextStyle().body.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    context.read<AppCubit>().initialize();
                  },
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
