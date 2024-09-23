part of 'ranking_cubit.dart';

enum RankingStateStatus { initial, loading, loaded, error }

@freezed
class RankingState with _$RankingState {
  const factory RankingState({
    @Default([]) List<Ranking> ranking,
    @Default(RankingStateStatus.initial) RankingStateStatus status,
  }) = _RankingState;
  const RankingState._();

  bool get isLoading => status == RankingStateStatus.loading;
  bool get isLoaded => status == RankingStateStatus.loaded;
  bool get isError => status == RankingStateStatus.error;
}
