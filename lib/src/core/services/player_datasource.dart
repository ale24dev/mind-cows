import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

abstract class PlayerDatasource {
  Future<Either<AppException, Player?>> getPlayerById(String id);
}
