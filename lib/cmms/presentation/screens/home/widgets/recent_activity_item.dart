import 'package:flutter/material.dart';
import '../models/recent_activity.dart';

class RecentActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Chấm tròn màu
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(activity.colorCode).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Nội dung + thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
