import 'package:flutter/material.dart';
import 'package:fpdart/src/either.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/preferences/preferences.dart';
import 'package:my_app/src/core/services/settings_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:my_app/src/features/settings/data/model/rules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Singleton(as: SettingsDatasource)
class SettingsRepository extends SettingsDatasource {
  SettingsRepository(this._preferences, this._client, this._supabaseService);

  final Preferences _preferences;
  final SupabaseClient _client;
  final SupabaseServiceImpl _supabaseService;

  @override
  Locale changeLanguage(String language) {
    _preferences.setLanguage(language);
    return Utils.getLocaleByCode(language);
  }

  @override
  ThemeMode changeTheme() {
    _preferences.changeTheme();

    return _preferences.getTheme();
  }

  @override
  Locale getLanguage() {
    return _preferences.getLanguage();
  }

  @override
  ThemeMode getTheme() {
    return _preferences.getTheme();
  }

  @override
  Future<Either<AppException?, List<Rules>?>> getRules() async {
    return _supabaseService.query<List<Rules>>(
      table: 'getRules',
      request: () => _client.from('rules').select(QuerySupabase.rules),
      queryOption: QueryOption.select,
      fromJsonParse: rulesFromJson,
    );
  }
}
