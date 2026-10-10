import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:bsmart/app.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/l10n/locale_storage.dart';
import 'package:bsmart/core/storage/hive_boxes.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await HiveBoxes.openAll();

  setupDependencyInjection();

  final savedLanguage = await LocaleStorage().read();

  runApp(
    ProviderScope(
      overrides: [savedLanguageCodeProvider.overrideWithValue(savedLanguage)],
      child: const BsmartApp(),
    ),
  );
}
