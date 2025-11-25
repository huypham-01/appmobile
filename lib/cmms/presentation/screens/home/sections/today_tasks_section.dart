import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';

class TodayTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;

  const TodayTasksSection({super.key, required this.tasks});

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                  "Today's Tasks",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${tasks.length} items",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
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
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: TaskCard(task: task),
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
