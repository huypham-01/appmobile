// ignore_for_file: library_private_types_in_public_api

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:mobile/ems/data/action_provider_ems.dart';
import 'package:mobile/utils/helper/onboarding_helper.dart';
import 'package:mobile/utils/routes/app_routes.dart';
import 'package:mobile/utils/services/notification_service.dart';
import 'package:mobile/utils/services/update_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fmcs/data/action_provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/helper/permission_helper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MaintenanceNotificationService.init();

  print("✅ Notification scheduling completed");

  final firstTime = await OnboardingHelper.isFirstTime();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActionProvider()),
        ChangeNotifierProvider(create: (_) => IssueActionProvider()),
      ],
      child: MyApp(showOnboarding: firstTime),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  late final AppLinks _appLinks;
  String? _initialRoute;
  bool _isInitialized = false;

  void changeLanguage(Locale locale) async {
    setState(() => _locale = locale);

    await MaintenanceNotificationService.saveCurrentLocale(locale.languageCode);
    await MaintenanceNotificationService.fetchAndSaveMaintenanceData();
    await MaintenanceNotificationService.scheduleDailyAlarms();
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('🚀 [Main App] Bắt đầu khởi tạo...');
    _appLinks = AppLinks();

    // ------------------------------------------------------------
    // 🔥 XIN QUYỀN LẦN ĐẦU CÀI APP (ĐÃ SỬA)
    // ------------------------------------------------------------
    // if (widget.showOnboarding) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     PermissionHelper.requestAllPermissions(navigatorKey.currentContext!);
    //   });
    // }

    // ------------------------------------------------------------
    // 🔥 1) LOAD NGÔN NGỮ ĐÃ LƯU
    // ------------------------------------------------------------
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString("selectedLanguage") ?? "English";

    Locale startupLocale;
    switch (savedLang) {
      case "Vietnamese":
        startupLocale = const Locale('vi');
        break;
      case "Chinese":
        startupLocale = const Locale('zh');
        break;
      case "Taiwanese":
        startupLocale = const Locale('zh', 'TW');
        break;
      default:
        startupLocale = const Locale('en');
    }

    _locale = startupLocale;
    await MaintenanceNotificationService.saveCurrentLocale(
      startupLocale.languageCode,
    );

    // ------------------------------------------------------------
    // 2) LOAD DEEP LINK
    // ------------------------------------------------------------
    final initialUri = await _appLinks.getInitialLink();
    print("🔍 Initial link: $initialUri");

    String startRoute = AppRoutes.home;
    if (initialUri != null && initialUri.host == 'change_password') {
      startRoute = AppRoutes.changepassword;
    }

    _appLinks.uriLinkStream.listen((uri) {
      print("📩 Stream deep link: $uri");
      _handleDeepLink(uri);
    });

    setState(() {
      _initialRoute = startRoute;
      _isInitialized = true;
    });

    print("🎯 Initialized: $_initialRoute — locale: $_locale");

    // ------------------------------------------------------------
    // 🔥 NEW: KIỂM TRA CẬP NHẬT APP
    // ------------------------------------------------------------
    // Sử dụng addPostFrameCallback để đảm bảo App đã render xong màn hình Home
    // thì mới hiện popup update.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Chỉ kiểm tra update nếu không phải deep link đổi mật khẩu (để tránh làm phiền)
    //   if (startRoute == AppRoutes.home) {
    //     // Sử dụng navigatorKey.currentContext để lấy context ở mọi nơi
    //     if (navigatorKey.currentContext != null) {
    //       UpdateService.checkForUpdate(navigatorKey.currentContext!);
    //     }
    //   }
    // });
  }

  void _handleDeepLink(Uri uri) {
    print('🔄 [Main App] Xử lý URI: $uri (host: ${uri.host})');

    if (uri.host == 'login') {
      print('ℹ️ [Main App] Login deep link detected - no navigation needed');
      return;
    } else if (uri.host == 'change_password') {
      print('➡️ [Main App] Navigate to ChangePassword');
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } else {
      print('ℹ️ [Main App] Unknown host: ${uri.host}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
        Locale('zh'),
        Locale('zh', 'TW'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      initialRoute: widget.showOnboarding
          ? AppRoutes.onboarding
          : _initialRoute,
      onGenerateRoute: (settings) {
        print('🔍 [MaterialApp] onGenerateRoute: ${settings.name}');

        if (settings.name != null &&
            (settings.name!.contains('?otp=') ||
                settings.name!.contains('://login'))) {
          print(
            '⚠️ [MaterialApp] Deep link callback detected, blocking navigation',
          );
          return null;
        }

        return AppRoutes.generateRoute(settings);
      },
    );
  }
}
