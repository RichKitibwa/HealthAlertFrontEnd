// Run from project root: dart run tool/tint_logo_green.dart
// Creates healthcare_logo_green.png (primary green) for app icon.

import 'dart:io';
import 'package:image/image.dart' as img;

// AppColors.primary = 0xFF0A8F8C
const int greenR = 0x0A;
const int greenG = 0x8F;
const int greenB = 0x8C;

void main() {
  final projectRoot = Directory.current.path;
  if (!projectRoot.endsWith('health_app_frontend')) {
    print('Run from health_app_frontend: dart run tool/tint_logo_green.dart');
    exit(1);
  }
  final inputPath = '$projectRoot/assets/images/healthcare_logo.png';
  final outputPath = '$projectRoot/assets/images/healthcare_logo_green.png';
  final file = File(inputPath);
  if (!file.existsSync()) {
    print('Not found: $inputPath');
    exit(1);
  }
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode image');
    exit(1);
  }
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final a = p.a.toInt();
      if (a > 0) {
        image.setPixel(x, y, img.ColorRgba8(greenR, greenG, greenB, a));
      }
    }
  }
  File(outputPath).writeAsBytesSync(img.encodePng(image));
  print('Written: $outputPath');
}
