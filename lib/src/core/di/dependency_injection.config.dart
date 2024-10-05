// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:my_app/src/core/di/modules/modules.dart' as _i560;
import 'package:my_app/src/core/interceptor.dart' as _i330;
import 'package:my_app/src/core/services/settings_datasource.dart' as _i94;
import 'package:my_app/src/core/supabase/client.dart' as _i880;
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart' as _i992;
import 'package:my_app/src/features/auth/data/auth_repository.dart' as _i427;
import 'package:my_app/src/features/game/cubit/game_cubit.dart' as _i584;
import 'package:my_app/src/features/game/data/game_repository.dart' as _i34;
import 'package:my_app/src/features/player/cubit/player_cubit.dart' as _i126;
import 'package:my_app/src/features/player/data/player_repository.dart'
    as _i406;
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart' as _i931;
import 'package:my_app/src/features/ranking/data/ranking_repository.dart'
    as _i34;
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart'
    as _i303;
import 'package:my_app/src/features/settings/data/settings_repository.dart'
    as _i621;
import 'package:my_app/src/features/splash/cubit/app_cubit.dart' as _i1038;
import 'package:my_app/src/router/router.dart' as _i63;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final modules = _$Modules();
    final supabaseModule = _$SupabaseModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => modules.prefs,
      preResolve: true,
    );
    gh.singleton<_i330.SupabaseServiceImpl>(() => _i330.SupabaseServiceImpl());
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.client);
    gh.singleton<_i427.AuthRepository>(
        () => _i427.AuthRepository(gh<_i454.SupabaseClient>()));
    gh.singleton<_i63.RouterController>(
        () => _i63.RouterController(gh<_i454.SupabaseClient>()));
    gh.singleton<_i34.RankingRepository>(() => _i34.RankingRepository(
          gh<_i330.SupabaseServiceImpl>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.singleton<_i34.GameRepository>(() => _i34.GameRepository(
          gh<_i330.SupabaseServiceImpl>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.singleton<_i406.PlayerRepository>(() => _i406.PlayerRepository(
          gh<_i330.SupabaseServiceImpl>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.singleton<_i94.SettingsDatasource>(() => _i621.SettingsRepository(
          gh<_i330.SupabaseServiceImpl>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.factory<_i584.GameCubit>(() => _i584.GameCubit(
          gh<_i454.SupabaseClient>(),
          gh<_i34.GameRepository>(),
          gh<_i406.PlayerRepository>(),
        ));
    gh.factory<_i303.SettingsCubit>(
        () => _i303.SettingsCubit(gh<_i94.SettingsDatasource>()));
    gh.factory<_i931.RankingCubit>(
        () => _i931.RankingCubit(gh<_i34.RankingRepository>()));
    gh.factory<_i126.PlayerCubit>(() => _i126.PlayerCubit(
          gh<_i454.SupabaseClient>(),
          gh<_i406.PlayerRepository>(),
        ));
    gh.factory<_i992.AuthCubit>(() => _i992.AuthCubit(
          gh<_i427.AuthRepository>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.factory<_i1038.AppCubit>(() => _i1038.AppCubit(
          gh<_i34.GameRepository>(),
          gh<_i454.SupabaseClient>(),
        ));
    return this;
  }
}

class _$Modules extends _i560.Modules {}

class _$SupabaseModule extends _i880.SupabaseModule {}
