import 'package:flutter/material.dart';

import '../../fmcs/screens/approve_action.dart';
import '../../fmcs/screens/home_fmcs.dart';
import '../../fmcs/screens/location_setting.dart';
import '../../fmcs/screens/login.dart';

class FmcsRoutes {
  static const home = '/fmcs/';
  static const systemSetting = '/fmcs/systemsetting/';
  static const locationSetting = '/fmcs/locationsetting/';
  static const approveAction = '/fmcs/approveaction/';
  static const login = '/fmcs/login/';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeFmcs());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case locationSetting:
        return MaterialPageRoute(builder: (_) => LocationSetting());

      case approveAction:
        return MaterialPageRoute(builder: (_) => ApproveAction());

      default:
        return null;
    }
  }
}
