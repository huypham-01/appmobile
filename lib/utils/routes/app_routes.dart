import 'package:flutter/material.dart';
import 'package:mobile/cmms/presentation/screens/change_password_screen.dart';
import 'package:mobile/cmms/presentation/screens/login_screen.dart';
import 'package:mobile/onboarding_screen.dart';
import 'package:mobile/home.dart';

// Import các module route khác
import 'cmms_routes.dart';
import 'ems_routes.dart';
import 'fmcs_routes.dart';

class AppRoutes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const changepassword = '/change_password';
  static const login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🔍 [AppRoutes] generateRoute called: ${settings.name}');
    print('🔍 [AppRoutes] arguments: ${settings.arguments}');

    // ✅ Bỏ qua deep link URIs
    if (settings.name != null && settings.name!.contains('://')) {
      print(
        '⚠️ [AppRoutes] Detected deep link URI, ignoring: ${settings.name}',
      );
      return MaterialPageRoute(
        builder: (_) => const SizedBox.shrink(),
        settings: RouteSettings(name: settings.name),
      );
    }

    // ✅ QUAN TRỌNG: Bỏ qua routes có query param "otp" - đây là deep link callback
    if (settings.name != null && settings.name!.contains('?otp=')) {
      print(
        '⚠️ [AppRoutes] Detected OTP deep link callback, ignoring: ${settings.name}',
      );
      // Return route hiện tại, không navigate
      return MaterialPageRoute(
        builder: (_) => const SizedBox.shrink(),
        settings: RouteSettings(name: settings.name),
      );
    }

    switch (settings.name) {
      case home:
        print('✅ [AppRoutes] Navigating to Home');
        return MaterialPageRoute(builder: (_) => const Home());
      case login:
        print('✅ [AppRoutes] Navigating to Login');
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case onboarding:
        print('✅ [AppRoutes] Navigating to Onboarding');
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      // case login:
      //   return MaterialPageRoute(
      //     builder: (_) => LoginScreen(keyW: keyW),
      //     settings: settings,
      //   );

      case changepassword:
        print('✅ [AppRoutes] Navigating to ChangePassword');
        return MaterialPageRoute(builder: (_) => const ChangePassword());

      default:
        print('🔍 [AppRoutes] Checking sub-routes...');

        // Gọi các route của CMMS, EMS, FMCS
        final cmmsRoute = CmmsRoutes.generateRoute(settings);
        if (cmmsRoute != null) {
          print('✅ [AppRoutes] Found in CmmsRoutes');
          return cmmsRoute;
        }

        final emsRoute = EmsRoutes.generateRoute(settings);
        if (emsRoute != null) {
          print('✅ [AppRoutes] Found in EmsRoutes');
          return emsRoute;
        }

        final fmcsRoute = FmcsRoutes.generateRoute(settings);
        if (fmcsRoute != null) {
          print('✅ [AppRoutes] Found in FmcsRoutes');
          return fmcsRoute;
        }

        // Nếu không tìm thấy route
        print('❌ [AppRoutes] Route not found: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('404 - Page not found'),
                  const SizedBox(height: 16),
                  Text(
                    'Route: ${settings.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
