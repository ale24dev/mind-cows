import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/player_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'player_state.dart';
part 'player_cubit.freezed.dart';

@injectable
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._client, this._playerRepository)
      : super(const PlayerState()) {
    _listenSupabaseSession();
  }

  final SupabaseClient _client;
  final PlayerRepository _playerRepository;

  void _listenSupabaseSession() {
    _client.auth.onAuthStateChange.listen((authSupState) {
      if (_client.auth.currentUser != null) {
        getPlayerById(_client.auth.currentUser!.id);
      }

      return switch (authSupState.event) {
        AuthChangeEvent.signedOut => refresh(),
        _ => emit(state),
      };
    });
  }

  void getPlayerById(String id) {
    emit(const PlayerState(status: PlayerStatus.loading));

    _playerRepository.getPlayerById(id).then((result) {
      result.fold(
        (error) => emit(
          state.copyWith(status: PlayerStatus.error),
        ),
        (player) =>
            emit(state.copyWith(player: player, status: PlayerStatus.success)),
      );
    });
  }

  void refresh() {
    emit(const PlayerState());
  }
}
