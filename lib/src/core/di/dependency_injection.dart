import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/di/dependency_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<GetIt> configureDependencies() => getIt.init();
