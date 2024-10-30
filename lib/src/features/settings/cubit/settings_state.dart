part of 'settings_cubit.dart';

enum SettingsStateStatus { initial, loading, loaded, error }

enum Language { english, spanish }

extension LanguagesX on Language {
  Locale get locale {
    switch (this) {
      case Language.english:
        return const Locale('en');
      case Language.spanish:
        return const Locale('es');
    }
  }
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(SettingsStateStatus.initial) SettingsStateStatus stateStatus,
    Locale? locale,
    List<Rules>? rules,
    ThemeMode? theme,
    AppException? error,
  }) = _SettingsState;
  const SettingsState._();

  bool get isLoading => stateStatus == SettingsStateStatus.loading;
  bool get isLoaded => stateStatus == SettingsStateStatus.loaded;
  bool get isError => stateStatus == SettingsStateStatus.error;
}
