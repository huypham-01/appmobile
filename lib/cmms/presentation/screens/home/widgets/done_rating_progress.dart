import 'package:flutter/material.dart';

import '../models/done_rating_progress_model.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final String label;

  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.onTap,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const StatCard({
    Key? key,
    required this.value,
    required this.label,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // nền màu trắng
        borderRadius: BorderRadius.circular(12), // bo góc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // bóng nhẹ
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double percentage;
  final String day;
  final bool isHighest;

  const ProgressBar({
    Key? key,
    required this.percentage,
    required this.day,
    this.isHighest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            "${percentage.toInt()}%",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background bar
                Container(
                  width: 24,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress bar
                Container(
                  width: 24,
                  height: (200 * percentage / 100),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? Colors.green.shade600
                        : Colors.green.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Trend line dot
                if (isHighlight)
                  Positioned(
                    bottom: (200 * percentage / 100) - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  bool get isHighlight => percentage == 80.0 || percentage > 65.0;
}

class TrendLine extends StatelessWidget {
  final List<DailyProgress> data;

  const TrendLine({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 200),
      painter: TrendLinePainter(data),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  final List<DailyProgress> data;

  TrendLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final path = Path();
    final itemWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = (i * itemWidth) + (itemWidth / 2);
      final y = (size.height - (size.height * data[i].percentage / 100)).clamp(
        0.0,
        size.height,
      );

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots on the trend line
    for (int i = 0; i < data.length; i++) {
      final x = (i * itemWidth) + (itemWidth / 2);
      final y = (size.height - (size.height * data[i].percentage / 100)).clamp(
        0.0,
        size.height,
      );

      final dotPaint = Paint()
        ..color = Colors.orange.shade600
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
