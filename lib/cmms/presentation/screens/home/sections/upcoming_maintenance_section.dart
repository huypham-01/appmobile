import 'package:flutter/material.dart';
import '../models/upcoming_maintenance.dart';
import '../widgets/upcoming_maintenance_item.dart';

class UpcomingMaintenanceSection extends StatelessWidget {
  final List<UpcomingMaintenance> maintenances;

  const UpcomingMaintenanceSection({super.key, required this.maintenances});

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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  "Upcoming Maintenance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: điều hướng sang màn hình khác
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View All"),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: maintenances.length,
                itemBuilder: (context, index) {
                  final m = maintenances[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: UpcomingMaintenanceItem(maintenance: m),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
