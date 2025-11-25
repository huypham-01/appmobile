import 'package:flutter/material.dart';

class WorkSchedulePage extends StatefulWidget {
  const WorkSchedulePage({super.key});

  @override
  _WorkSchedulePageState createState() => _WorkSchedulePageState();
}

class _WorkSchedulePageState extends State<WorkSchedulePage> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();

  // Sample work data
  Map<String, List<WorkTask>> workSchedule = {
    '2024-12-20': [
      WorkTask(
        id: '1',
        title: 'Bảo trì máy nén khí A1',
        description: 'Kiểm tra và thay dầu máy nén khí tại khu vực A1',
        priority: Priority.high,
        status: TaskStatus.pending,
        startTime: '08:00',
        endTime: '10:00',
        assignee: 'Nguyễn Văn A',
      ),
      WorkTask(
        id: '2',
        title: 'Kiểm tra hệ thống điện',
        description: 'Kiểm tra tủ điện chính và các thiết bị điện',
        priority: Priority.medium,
        status: TaskStatus.inProgress,
        startTime: '14:00',
        endTime: '16:00',
        assignee: 'Trần Văn B',
      ),
    ],
    '2024-12-21': [
      WorkTask(
        id: '3',
        title: 'Vệ sinh khu vực sản xuất',
        description: 'Vệ sinh và khử trùng toàn bộ khu vực sản xuất',
        priority: Priority.low,
        status: TaskStatus.completed,
        startTime: '06:00',
        endTime: '08:00',
        assignee: 'Lê Thị C',
      ),
    ],
    '2024-12-22': [
      WorkTask(
        id: '4',
        title: 'Thay thế bộ lọc',
        description: 'Thay thế bộ lọc khí cho hệ thống thông gió',
        priority: Priority.high,
        status: TaskStatus.pending,
        startTime: '09:00',
        endTime: '11:30',
        assignee: 'Phạm Văn D',
      ),
      WorkTask(
        id: '5',
        title: 'Kiểm tra an toàn lao động',
        description: 'Kiểm tra các thiết bị bảo hộ lao động',
        priority: Priority.medium,
        status: TaskStatus.pending,
        startTime: '13:30',
        endTime: '15:00',
        assignee: 'Hoàng Thị E',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lịch Làm Việc CMMS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
                currentMonth = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 30),
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 30),
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // Calendar Widget
          Container(color: Colors.white, child: _buildCalendar()),

          // Divider
          Container(height: 8, color: Colors.grey[100]),

          // Work Content Section
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.work_outline, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          'Công việc ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildWorkContent()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Days of week header
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10),

          // Calendar days
          ..._buildCalendarWeeks(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    DateTime firstDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    int startingWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;
    int daysInMonth = lastDayOfMonth.day;

    List<Widget> days = [];

    // Add empty cells for days before the first day of month
    for (int i = 0; i < startingWeekday; i++) {
      days.add(Expanded(child: Container()));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
      bool isSelected =
          selectedDate.day == day &&
          selectedDate.month == currentMonth.month &&
          selectedDate.year == currentMonth.year;
      bool hasWork = _hasWorkOnDate(date);

      days.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              height: 45,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue[700]
                    : (hasWork ? Colors.orange[100] : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: hasWork && !isSelected
                    ? Border.all(color: Colors.orange[300]!, width: 1)
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (hasWork ? Colors.orange[700] : Colors.black),
                        fontWeight: isSelected || hasWork
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (hasWork && !isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Group days into weeks
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(
        Row(
          children: days.sublist(i, i + 7 > days.length ? days.length : i + 7),
        ),
      );
      if (i + 7 < days.length) {
        weeks.add(SizedBox(height: 8));
      }
    }

    return weeks;
  }

  Widget _buildWorkContent() {
    String dateKey =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    List<WorkTask> tasks = workSchedule[dateKey] ?? [];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Không có công việc nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để thêm công việc mới',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index]);
      },
    );
  }

  Widget _buildTaskCard(WorkTask task) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(task.priority),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(task.priority),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(task.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(task.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${task.startTime} - ${task.endTime}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Spacer(),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  task.assignee,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasWorkOnDate(DateTime date) {
    String dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return workSchedule.containsKey(dateKey) &&
        workSchedule[dateKey]!.isNotEmpty;
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[month];
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Cao';
      case Priority.medium:
        return 'Trung bình';
      case Priority.low:
        return 'Thấp';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Chờ thực hiện';
      case TaskStatus.inProgress:
        return 'Đang thực hiện';
      case TaskStatus.completed:
        return 'Hoàn thành';
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thêm công việc mới'),
          content: Text(
            'Chức năng thêm công việc sẽ được phát triển trong phiên bản tiếp theo.',
          ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Data Models
class WorkTask {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final TaskStatus status;
  final String startTime;
  final String endTime;
  final String assignee;

  WorkTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.assignee,
  });
}

enum Priority { high, medium, low }

enum TaskStatus { pending, inProgress, completed }
