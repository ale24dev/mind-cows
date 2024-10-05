part of 'settings_cubit.dart';

enum SettingsStateStatus { initial, loading, loaded, error }

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(SettingsStateStatus.initial) SettingsStateStatus stateStatus,
    AppException? error,
  }) = _SettingsState;
  const SettingsState._();

  bool get isLoading => stateStatus == SettingsStateStatus.loading;
  bool get isLoaded => stateStatus == SettingsStateStatus.loaded;
  bool get isError => stateStatus == SettingsStateStatus.error;
}
