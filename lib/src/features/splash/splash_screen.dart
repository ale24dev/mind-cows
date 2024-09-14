import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/splash/cubit/app_cubit.dart';
import 'package:my_app/src/router/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AppCubit>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.isSuccess) {
            context.read<GameCubit>().setGameStatus(state.gameStatus);

            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
            });
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
