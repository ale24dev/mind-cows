import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/settings_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Singleton(as: SettingsDatasource)
class SettingsRepository extends SettingsDatasource {
  SettingsRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;
}
