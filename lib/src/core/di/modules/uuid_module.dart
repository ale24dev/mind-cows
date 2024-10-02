import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@module
abstract class UuidModule {
  @singleton
  Uuid get uuid => const Uuid();
}
