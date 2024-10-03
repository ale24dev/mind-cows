import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:my_app/src/features/ranking/data/ranking_repository.dart';

part 'ranking_state.dart';
part 'ranking_cubit.freezed.dart';

@injectable
class RankingCubit extends Cubit<RankingState> {
  RankingCubit(this._rankingRepository) : super(const RankingState()) {
    _listenRankingChanges();
  }

  final RankingRepository _rankingRepository;

  void _listenRankingChanges() {
    _rankingRepository.listenRanking(loadRanking);
  }

  void loadRanking() {
    emit(state.copyWith(status: RankingStateStatus.loading));
  
    _rankingRepository.getRanking().then((result) {
      result.fold(
        (error) => emit(state.copyWith(status: RankingStateStatus.error)),
        (ranking) => emit(
          state.copyWith(
            ranking: ranking ?? [],
            status: RankingStateStatus.loaded,
          ),
        ),
      );
    });
  }
}
