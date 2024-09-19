part of 'app_cubit.dart';

enum AppStatus { initial, loading, success, error }

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(AppStatus.initial) AppStatus status,
    @Default([]) List<GameStatus> gameStatus,
    @Default(false) bool initialized, 
  }) = _AppState;
  const AppState._();

  bool get isLoading => status == AppStatus.loading;
  bool get isSuccess => status == AppStatus.success;
  bool get isError => status == AppStatus.error;
}
