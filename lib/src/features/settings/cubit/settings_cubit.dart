import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/services/settings_datasource.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsDatasource) : super(const SettingsState()) {
    _initData();
  }

  final SettingsLocalDatasource _settingsDatasource;

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
  }

  void getTheme() {
    emit(state.copyWith(theme: _settingsDatasource.getTheme()));
  }

  void getLanguage() {
    emit(state.copyWith(locale: _settingsDatasource.getLanguage()));
  }
}
