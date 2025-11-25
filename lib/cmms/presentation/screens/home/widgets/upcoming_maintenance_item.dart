import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/upcoming_maintenance.dart';

class UpcomingMaintenanceItem extends StatelessWidget {
  final UpcomingMaintenance maintenance;

  const UpcomingMaintenanceItem({super.key, required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maintenance.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Scheduled: ${dateFormat.format(maintenance.scheduledDate)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: maintenance.priority == 'ML03'
                  ? Colors.red[100]
                  : (maintenance.priority == 'ML02'
                        ? Colors.orange[100]
                        : Colors.green[100]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              maintenance.priority,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
