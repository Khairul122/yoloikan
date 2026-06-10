import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/locale_controller.dart';
import '../controllers/realtime_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_colors_dark.dart';
import '../core/constants/app_constants.dart';
import '../views/detail/species_detail_view.dart';
import '../views/gallery/gallery_view.dart';
import '../views/realtime/realtime_view.dart';
import '../views/shell/main_shell.dart';
import '../views/splash/splash_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, LocaleController>(
      builder: (context, themeController, localeController, _) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeController.isDark
                ? Brightness.light
                : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppDarkColors.primary,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppDarkColors.background,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          themeMode: themeController.themeMode,
          locale: localeController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            // Keep AppColors in sync with the resolved theme brightness, and
            // remount the whole subtree on change so every screen rebuilds
            // with the new palette.
            final brightness = Theme.of(context).brightness;
            AppColors.setBrightness(brightness);
            return KeyedSubtree(key: ValueKey(brightness), child: child!);
          },
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashView(),
            '/': (_) => const MainShell(),
            AppConstants.galleryRoute: (_) => const GalleryView(),
            AppConstants.realtimeRoute: (_) => ChangeNotifierProvider(
              create: (_) => RealtimeController(),
              child: const RealtimeView(),
            ),
            AppConstants.detailRoute: (ctx) {
              final args =
                  ModalRoute.of(ctx)!.settings.arguments as SpeciesDetailArgs;
              return SpeciesDetailView(args: args);
            },
          },
        );
      },
    );
  }
}
