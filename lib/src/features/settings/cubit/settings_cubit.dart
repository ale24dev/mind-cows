import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/services/settings_datasource.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsDatasource) : super(const SettingsState());

  final SettingsDatasource _settingsDatasource;
}
