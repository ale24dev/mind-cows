import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_cows/resources/resources.dart';

void main() {
  test('app_images assets test', () {
    expect(File(AppImages.appLoading).existsSync(), isTrue);
    expect(File(AppImages.bullSearchGame).existsSync(), isTrue);
    expect(File(AppImages.cowSearchGame).existsSync(), isTrue);
    expect(File(AppImages.firstPlace).existsSync(), isTrue);
    expect(File(AppImages.gamePoints).existsSync(), isTrue);
    expect(File(AppImages.loseGame).existsSync(), isTrue);
    expect(File(AppImages.noPhoto).existsSync(), isTrue);
    expect(File(AppImages.playButton).existsSync(), isTrue);
    expect(File(AppImages.secondPlace).existsSync(), isTrue);
    expect(File(AppImages.thirdPlace).existsSync(), isTrue);
    expect(File(AppImages.winGame).existsSync(), isTrue);
  });
}
