class DoneRatingProgress {
  final String title;
  final double averageCompletion;
  final int totalDays;
  final double bestDay;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyProgress> dailyProgress;

  DoneRatingProgress({
    required this.title,
    required this.averageCompletion,
    required this.totalDays,
    required this.bestDay,
    required this.startDate,
    required this.endDate,
    required this.dailyProgress,
  });

  static DoneRatingProgress getSampleData() {
    return DoneRatingProgress(
      title: "Done Rating Progress",
      averageCompletion: 56,
      totalDays: 12,
      bestDay: 80,
      startDate: DateTime(2025, 8, 31),
      endDate: DateTime(2025, 9, 11),
      dailyProgress: [
        DailyProgress(day: "31", percentage: 56, date: DateTime(2025, 8, 31)),
        DailyProgress(day: "01", percentage: 46, date: DateTime(2025, 9, 1)),
        DailyProgress(day: "02", percentage: 40, date: DateTime(2025, 9, 2)),
        DailyProgress(day: "03", percentage: 54, date: DateTime(2025, 9, 3)),
        DailyProgress(day: "04", percentage: 56, date: DateTime(2025, 9, 4)),
        DailyProgress(day: "05", percentage: 54, date: DateTime(2025, 9, 5)),
        DailyProgress(day: "06", percentage: 45, date: DateTime(2025, 9, 6)),
        DailyProgress(day: "07", percentage: 45, date: DateTime(2025, 9, 7)),
        DailyProgress(day: "08", percentage: 60, date: DateTime(2025, 9, 8)),
        DailyProgress(day: "09", percentage: 69, date: DateTime(2025, 9, 9)),
        DailyProgress(day: "10", percentage: 80, date: DateTime(2025, 9, 10)),
        DailyProgress(day: "11", percentage: 66, date: DateTime(2025, 9, 11)),
      ],
    );
  }
}

class DailyProgress {
  final String day;
  final double percentage;
  final DateTime date;

  DailyProgress({
    required this.day,
    required this.percentage,
    required this.date,
  });
}
