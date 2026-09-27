import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_locale_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/context_engine/context_provider.dart';
import 'features/main_navigation/presentation/main_screen.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/timetable/providers/timetable_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline notification engine
  await NotificationService().init();

  // Check if first launch; if so, pre-seed realistic sample data for instant context awareness
  final prefs = await SharedPreferences.getInstance();
  final hasSampleData = prefs.getBool(AppConstants.keyHasSampleData) ?? false;
  if (!hasSampleData) {
    await StorageService().seedRealisticDemoData();
    await prefs.setBool(AppConstants.keyHasSampleData, true);
  }

  runApp(const CollegePulseApp());
}

class CollegePulseApp extends StatelessWidget {
  const CollegePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ContextProvider()),
        ChangeNotifierProxyProvider<ContextProvider, TimetableProvider>(
          create: (ctx) {
            final contextProv = ctx.read<ContextProvider>();
            return TimetableProvider(
              onSlotsUpdated: (slots) => contextProv.updateSlots(slots),
            );
          },
          update: (ctx, contextProv, timetableProv) {
            timetableProv?.onSlotsUpdated = (slots) => contextProv.updateSlots(slots);
            return timetableProv!;
          },
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: Consumer2<AppLocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar', ''),
              Locale('en', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
