// ignore_for_file: avoid_print
//
// Check that a locale ARB file has all keys from the template (app_en.arb).
// Usage: dart run tool/check_arb_locale.dart [locale]
// Example: dart run tool/check_arb_locale.dart sw
//
// Exit code: 0 if locale is complete, 1 if keys are missing.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final locale = args.isNotEmpty ? args[0] : 'sw';
  final projectRoot = Directory.current.path;
  final arbDir = '$projectRoot/lib/l10n';
  final templatePath = '$arbDir/app_en.arb';
  final localePath = '$arbDir/app_$locale.arb';

  final templateFile = File(templatePath);
  final localeFile = File(localePath);

  if (!templateFile.existsSync()) {
    print('Template not found: $templatePath');
    exit(1);
  }
  if (!localeFile.existsSync()) {
    print('Locale file not found: $localePath');
    exit(1);
  }

  final templateKeys = _extractTranslationKeys(templateFile);
  final localeKeys = _extractTranslationKeys(localeFile);

  final missing = templateKeys.difference(localeKeys);
  final extra = localeKeys.difference(templateKeys);

  if (missing.isNotEmpty) {
    print('Missing in app_$locale.arb (${missing.length} keys):');
    final sortedMissing = missing.toList()..sort();
    for (final key in sortedMissing) {
      print('  - $key');
    }
    exit(1);
  }

  if (extra.isNotEmpty) {
    print('Keys in app_$locale.arb not in template (${extra.length}):');
    final sortedExtra = extra.toList()..sort();
    for (final key in sortedExtra) {
      print('  - $key');
    }
  }

  print('Locale "$locale" has all ${templateKeys.length} keys from template. Swahili localization check passed.');
  exit(0);
}

Set<String> _extractTranslationKeys(File file) {
  final content = file.readAsStringSync();
  final map = json.decode(content) as Map<String, dynamic>;
  return map.keys
      .where((k) => !k.startsWith('@'))
      .toSet();
}
