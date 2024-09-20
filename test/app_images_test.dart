import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/resources/resources.dart';

void main() {
  test('app_images assets test', () {
    expect(File(AppImages.bullSearchGame).existsSync(), isTrue);
    expect(File(AppImages.cowSearchGame).existsSync(), isTrue);
    expect(File(AppImages.noPhoto).existsSync(), isTrue);
    expect(File(AppImages.playButton).existsSync(), isTrue);
  });
}
