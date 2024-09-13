// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:my_app/src/core/supabase/client.dart' as _i880;
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart' as _i992;
import 'package:my_app/src/features/auth/data/auth_repository.dart' as _i427;
import 'package:my_app/src/features/home/cubit/game_cubit.dart' as _i671;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final supabaseModule = _$SupabaseModule();
    gh.factory<_i671.GameCubit>(() => _i671.GameCubit());
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.client);
    gh.singleton<_i427.AuthRepository>(
        () => _i427.AuthRepository(gh<_i454.SupabaseClient>()));
    gh.factory<_i992.AuthCubit>(() => _i992.AuthCubit(
          gh<_i427.AuthRepository>(),
          gh<_i454.SupabaseClient>(),
        ));
    return this;
  }
}

class _$SupabaseModule extends _i880.SupabaseModule {}
