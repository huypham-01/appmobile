import 'package:flutter/material.dart';
import 'package:mobile/cmms/presentation/main_navigation.dart';
import 'package:mobile/cmms/presentation/screens/equipment/equipment_detail_scan.dart';
import 'package:mobile/cmms/presentation/screens/equipment/equipment_screen.dart';
import 'package:mobile/cmms/presentation/screens/home/work_schedula.dart';
import 'package:mobile/cmms/presentation/screens/task/maintenance_screen.dart';
import 'package:mobile/cmms/presentation/screens/task/overdue_screen.dart';
import 'package:mobile/cmms/presentation/screens/task/task_screen.dart';

class CmmsRoutes {
  // static const login = '/cmms/login';
  static const main = '/cmms/main';
  static const todayTasks = '/cmms/today_tasks';
  static const maintenanceTasks = '/cmms/maintenance_tasks';
  static const equipment = '/cmms/equipment';
  static const workschedule = '/cmms/workschedule';
  static const qrscan = '/cmms/qrscan';
  static const qrscanDetail = '/cmms/qrscan_detail';
  static const overdue = '/cmms/overdue';

  /// ✅ Thay vì Map, ta viết 1 hàm nhận RouteSettings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case login:
      //   return MaterialPageRoute(builder: (_) => LoginScreen(keyWork: "cmms",));
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case overdue:
        return MaterialPageRoute(builder: (_) => const OverdueScreen());
      case todayTasks:
        return MaterialPageRoute(builder: (_) => TasksScreen());
      case maintenanceTasks:
        return MaterialPageRoute(builder: (_) => MaintenanceScreen());
      case equipment:
        return MaterialPageRoute(builder: (_) => EquipmentScreen());
      case workschedule:
        return MaterialPageRoute(builder: (_) => WorkSchedulePage());
      case qrscanDetail:
        final uuid = settings.arguments as String?; // ✅ Nhận tham số
        return MaterialPageRoute(
          builder: (_) => EquipmentDetailScreen(uuid: uuid),
        );
      default:
        return null; // Cho AppRoutes xử lý tiếp
    }
  }
}
