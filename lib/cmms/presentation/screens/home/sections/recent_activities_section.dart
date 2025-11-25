import 'package:flutter/material.dart';
import '../models/recent_activity.dart';
import '../widgets/recent_activity_item.dart';

class RecentActivitiesSection extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivitiesSection({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(221, 229, 226, 226),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 247, 249, 252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  "Recent Activities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return RecentActivityItem(activity: activity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
