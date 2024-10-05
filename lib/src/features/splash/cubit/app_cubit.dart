import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/features/game/data/game_repository.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_state.dart';
part 'app_cubit.freezed.dart';

@injectable
class AppCubit extends Cubit<AppState> {
  AppCubit(this._gameRepository, this._client) : super(const AppState());

  final GameRepository _gameRepository;

  final SupabaseClient _client;

  Future<void> initialize() async {
    if (_client.auth.currentSession != null) {
      emit(state.copyWith(status: AppStatus.loading));

      final gameStatusState = await getAllGameStatus();
      if (gameStatusState.status == AppStatus.error) {
        emit(state.copyWith(status: AppStatus.error));
        return;
      }
      emit(gameStatusState);
      emit(state.copyWith(initialized: true));
    }
    emit(state.copyWith(status: AppStatus.success));
  }

  Future<AppState> getAllGameStatus() async {
    return _gameRepository.getAllGameStatus().then((value) {
      return value.fold(
        (error) => state.copyWith(status: AppStatus.error),
        (gameStatus) => state.copyWith(
          gameStatus: gameStatus ?? [],
        ),
      );
    });
  }
}
