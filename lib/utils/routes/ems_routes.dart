import 'package:flutter/material.dart';
import 'package:mobile/ems/screens/dashboard.dart';
import 'package:mobile/ems/screens/home_ems.dart';
import 'package:mobile/ems/screens/login_ems.dart';
import 'package:mobile/ems/screens/widgets/action.dart';
import 'package:mobile/ems/screens/widgets/family_detail.dart';
import 'package:mobile/ems/screens/widgets/system_setting_ems.dart';

class EmsRoutes {
  static const home = '/ems/';
  static const login = '/ems/login/';
  static const dashboard = '/ems/dashboard/';
  static const machinedetail = '/ems/dashboard/machidetail/';
  static const action = '/ems/action/';
  static const system = '/ems/system/';
  static const family = '/ems/family/';

  /// ✅ Hàm generateRoute mới (thay vì Map routes)
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeEms());

      case login:
        return MaterialPageRoute(builder: (_) => LoginEms());

      case dashboard:
        return MaterialPageRoute(builder: (_) => Dashboard());

      case action:
        return MaterialPageRoute(builder: (_) => ApproveActionEms());

      case system:
        return MaterialPageRoute(builder: (_) => SystemMachine());

      case family:
        return MaterialPageRoute(builder: (_) => FamilyDetail());

      case machinedetail:
        return MaterialPageRoute(
          builder: (_) => Dashboard(), // ví dụ
        );

      default:
        return null;
    }
  }
}
