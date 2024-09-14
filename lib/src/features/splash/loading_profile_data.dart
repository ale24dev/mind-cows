import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/router/router.dart';

class LoadingProfileData extends StatefulWidget {
  const LoadingProfileData({super.key});

  @override
  State<LoadingProfileData> createState() => _LoadingProfileDataState();
}

class _LoadingProfileDataState extends State<LoadingProfileData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          if (state.status == PlayerStatus.success) {
            context.read<GameCubit>().setUserPlayer(state.player!);

            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            });
          }
          return const Center(
            child: Text('Splash Screen'),
          );
        },
      ),
    );
  }
}
