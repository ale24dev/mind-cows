import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/core/services/settings_datasource.dart';
import 'package:mind_cows/src/features/settings/data/model/rules.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsDatasource) : super(const SettingsState()) {
    _initData();
  }

  final SettingsDatasource _settingsDatasource;

  void changeLanguage(String language) {
    final locale = _settingsDatasource.changeLanguage(language);

    emit(state.copyWith(locale: locale));
  }

  void changeTheme() {
    final themeMode = _settingsDatasource.changeTheme();
    emit(state.copyWith(theme: themeMode));
  }

  void _initData() {
    getTheme();
    getLanguage();
    getRules();
  }

  void getTheme() {
    emit(state.copyWith(theme: _settingsDatasource.getTheme()));
  }

  void getLanguage() {
    emit(state.copyWith(locale: _settingsDatasource.getLanguage()));
  }

  void getRules() {
    emit(state.copyWith(stateStatus: SettingsStateStatus.loading));

    _settingsDatasource.getRules().then((result) {
      result.fold(
        (error) => emit(
          state.copyWith(
            stateStatus: SettingsStateStatus.error,
            error: error,
          ),
        ),
        (rules) => emit(
          state.copyWith(
            rules: rules ?? [],
            stateStatus: SettingsStateStatus.loaded,
          ),
        ),
      );
    });
  }
}
