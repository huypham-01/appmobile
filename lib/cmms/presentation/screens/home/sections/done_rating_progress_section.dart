import 'package:flutter/material.dart';
import '../models/done_rating_progress_model.dart';
import '../widgets/done_rating_progress.dart';

class DoneRatingProgressSection extends StatefulWidget {
  const DoneRatingProgressSection({super.key});

  @override
  State<DoneRatingProgressSection> createState() =>
      _DoneRatingProgressSectionState();
}

class _DoneRatingProgressSectionState extends State<DoneRatingProgressSection> {
  late DoneRatingProgress data;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    data = DoneRatingProgress.getSampleData();
    startDate = data.startDate;
    endDate = data.endDate;
  }

  // void _selectStartDate() async {}
  // void _selectEndDate() async {}
  void _applyDateRange() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 216, 213, 213),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gộp header + stats row vào 1 container nền đỏ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 247, 249, 252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile =
                        constraints.maxWidth <
                        600; // Nếu nhỏ hơn 600px thì coi là mobile

                    final stats = [
                      StatCard(
                        value: "${data.averageCompletion.toInt()}%",
                        label: "Average Completion",
                        valueColor: Colors.white,
                      ),
                      StatCard(
                        value: "${data.totalDays}",
                        label: "Total Days",
                        valueColor: Colors.white,
                      ),
                      StatCard(
                        value: "${data.bestDay.toInt()}%",
                        label: "Best Day (10)",
                        valueColor: Colors.white,
                      ),
                    ];

                    if (isMobile) {
                      // Hiển thị dọc
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < stats.length; i++) ...[
                            stats[i],
                            if (i < stats.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      );
                    } else {
                      // Hiển thị ngang
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < stats.length; i++) ...[
                            Expanded(child: stats[i]),
                            if (i < stats.length - 1) const SizedBox(width: 15),
                          ],
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Chart
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.dailyProgress.map((daily) {
                    return ProgressBar(
                      percentage: daily.percentage,
                      day: daily.day,
                      isHighest: daily.percentage == data.bestDay,
                    );
                  }).toList(),
                ),
                Positioned.fill(child: TrendLine(data: data.dailyProgress)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 6),
          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nếu màn hình nhỏ hơn 600px coi là điện thoại
        bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.check,
                      color: Colors.green.shade700,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Phần chọn ngày + Apply button
              Row(
                children: [
                  _dateBox(startDate),
                  const SizedBox(width: 8),
                  const Text("to"),
                  const SizedBox(width: 8),
                  _dateBox(endDate),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyDateRange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(
                        12,
                      ), // Smaller padding for icon-only button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Keep rounded corners
                      ),
                      minimumSize: const Size(
                        35,
                        35,
                      ), // Square shape for icon button
                    ),
                    child: const Icon(Icons.search, size: 18), // Search icon
                  ),
                ],
              ),
            ],
          );
        } else {
          // Tablet, desktop → giữ nguyên dạng Row
          return Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade700,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _dateBox(startDate),
              const SizedBox(width: 8),
              const Text("to"),
              const SizedBox(width: 8),
              _dateBox(endDate),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8), // vuông đều 4 cạnh
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // bo góc 8px
                  ),
                  minimumSize: const Size(38, 40), // ép nút thành hình vuông
                ),
                child: const Text("Apply"),
              ),
            ],
          );
        }
      },
    );
  }
}
// class DoneRatingProgressSection extends StatefulWidget {
//   const DoneRatingProgressSection({super.key});

//   @override
//   _DoneRatingProgressSectionState createState() =>
//       _DoneRatingProgressSectionState();
// }

// class _DoneRatingProgressSectionState extends State<DoneRatingProgressSection> {

// }
