import 'package:flutter/material.dart';
import 'models/recent_activity.dart';
import 'models/task_model.dart';
import 'models/upcoming_maintenance.dart';
import 'sections/done_rating_progress_section.dart';
import 'sections/recent_activities_section.dart';
import 'sections/stat_card_grid.dart';
import 'sections/today_tasks_section.dart';
import 'sections/upcoming_maintenance_section.dart';
// import '../work_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final tasks = [
      TaskModel(
        code: "TGN001_OUT",
        location: "null",
        equipment: "Cooling Tower",
        status: "INCOMPLETE",
      ),
      TaskModel(
        code: "TGN002_IN",
        location: "Zone A",
        equipment: "Pump 2",
        status: "COMPLETE",
      ),
      TaskModel(
        code: "TGN001_OUT",
        location: "null",
        equipment: "Cooling Tower",
        status: "INCOMPLETE",
      ),
      TaskModel(
        code: "TGN002_IN",
        location: "Zone A",
        equipment: "Pump 2",
        status: "COMPLETE",
      ),
      TaskModel(
        code: "TGN001_OUT",
        location: "null",
        equipment: "Cooling Tower",
        status: "INCOMPLETE",
      ),
      TaskModel(
        code: "TGN002_IN",
        location: "Zone A",
        equipment: "Pump 2",
        status: "COMPLETE",
      ),
      TaskModel(
        code: "TGN001_OUT",
        location: "null",
        equipment: "Cooling Tower",
        status: "INCOMPLETE",
      ),
      TaskModel(
        code: "TGN002_IN",
        location: "Zone A",
        equipment: "Pump 2",
        status: "COMPLETE",
      ),
    ];
    final demoActivities = [
      RecentActivity(
        message: "Completed preventive maintenance on Machine #15",
        timeAgo: "2 hours ago",
        colorCode: 0xFF4CAF50,
      ),
      RecentActivity(
        message: "Temperature alert resolved on Furnace #3",
        timeAgo: "4 hours ago",
        colorCode: 0xFFF44336,
      ),
      RecentActivity(
        message: "New work order created for Conveyor #8",
        timeAgo: "6 hours ago",
        colorCode: 0xFF3F51B5,
      ),
      RecentActivity(
        message: "System backup completed successfully",
        timeAgo: "8 hours ago",
        colorCode: 0xFF9E9E9E,
      ),

      RecentActivity(
        message: "New work order created for Conveyor #8",
        timeAgo: "6 hours ago",
        colorCode: 0xFF3F51B5,
      ),
      RecentActivity(
        message: "System backup completed successfully",
        timeAgo: "8 hours ago",
        colorCode: 0xFF9E9E9E,
      ),
    ];
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.grey[100])),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatCardGrid(),
                const SizedBox(height: 16),
                // QuickActionSection(),
                // const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: TodayTasksSection(tasks: tasks)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: RecentActivitiesSection(
                              activities: demoActivities,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: UpcomingMaintenanceSection(
                              maintenances: demoMaintenances,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          TodayTasksSection(tasks: tasks),
                          const SizedBox(height: 16),
                          RecentActivitiesSection(activities: demoActivities),
                          const SizedBox(height: 16),
                          UpcomingMaintenanceSection(
                            maintenances: demoMaintenances,
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                DoneRatingProgressSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
