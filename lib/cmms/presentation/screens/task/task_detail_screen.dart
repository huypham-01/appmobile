// screens/equipment_detail.dart
import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/task_equipment_today.dart';
import '../../../data/services/task_equipment_today_service.dart';
import 'checklist_detail_popup.dart';

class TaskDetailScreen extends StatefulWidget {
  final String uuid;
  final String equipmentId;
  final DateTime dateFrom;
  final DateTime dateTo;

  const TaskDetailScreen({
    super.key,
    required this.uuid,
    required this.equipmentId,
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<List<DetailTaskEquipment>> futureEquipment;

  @override
  void initState() {
    super.initState();
    futureEquipment = InspectionService.fetchEquipmentByUuid(
      widget.uuid,
      widget.dateFrom,
      widget.dateTo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: white,
        appBar: _buildAppBar(),
        body: FutureBuilder<List<DetailTaskEquipment>>(
          future: futureEquipment,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data found"));
            }

            final allTasks = snapshot.data!;
            final incompleteTasks = allTasks
                .where((e) => e.status == "null")
                .toList();
            final completedTasks = allTasks
                .where((e) => e.status == "done")
                .toList();

            return Column(
              children: [
                _buildSummaryBar(incompleteTasks.length, completedTasks.length),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList(incompleteTasks, isCompleted: false),
                      _buildTaskList(completedTasks, isCompleted: true),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 67, 103, 164),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      title: Text(
        '${AppLocalizations.of(context)!.equipmentsTitle} - ${widget.equipmentId}',
        style: const TextStyle(color: Colors.white, fontSize: 21),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 67, 103, 164),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            tabs: [
              _buildTab(
                Icons.access_time,
                AppLocalizations.of(context)!.incomplete,
              ),
              _buildTab(
                Icons.check_circle,
                AppLocalizations.of(context)!.complete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(int incompleteCount, int completedCount) {
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 210, 204, 204),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem(
            AppLocalizations.of(context)!.incomplete,
            incompleteCount,
            Colors.red,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            AppLocalizations.of(context)!.complete,
            completedCount,
            Colors.green,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildSummaryItem(
            AppLocalizations.of(context)!.total,
            incompleteCount + completedCount,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Row(
      children: [
        Text(
          "$label :",
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        SizedBox(width: 3),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(
    List<DetailTaskEquipment> tasks, {
    required bool isCompleted,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? AppLocalizations.of(context)!.noTasksFound
                  : AppLocalizations.of(context)!.noTasksFound,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: 8, right: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskCard(tasks[index], isCompleted),
    );
  }

  Widget _buildTaskCard(DetailTaskEquipment task, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [Colors.white, const Color(0xFFF0F9FF)]
              : [Colors.white, const Color(0xFFFFFBF0)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status indicator stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isCompleted
                        ? [Colors.green[300]!, Colors.green[200]!]
                        : [Colors.red[300]!, Colors.red[200]!],
                  ),
                ),
              ),

              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with code and status
                      Row(
                        children: [
                          // Task code badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.code,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Status badge for completed tasks
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(task.status),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(
                                      task.status,
                                    ).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(task.status),
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.status ?? "Unknown",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Task content
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2, right: 12),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Progress indicator for incomplete tasks
                      // if (!isCompleted) ...[
                      //   const SizedBox(height: 16),
                      //   Row(
                      //     children: [
                      //       Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 8,
                      //           vertical: 4,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: Colors.orange[50],
                      //           borderRadius: BorderRadius.circular(6),
                      //           border: Border.all(
                      //             color: Colors.orange[200]!,
                      //             width: 1,
                      //           ),
                      //         ),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Icon(
                      //               Icons.schedule,
                      //               size: 12,
                      //               color: Colors.orange[600],
                      //             ),
                      //             const SizedBox(width: 4),
                      //             Text(
                      //               "Pending",
                      //               style: TextStyle(
                      //                 fontSize: 11,
                      //                 fontWeight: FontWeight.w600,
                      //                 color: Colors.orange[700],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ),

              // Action button
              _buildActionButton(task, isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green[600]!;
      case 'in_progress':
      case 'working':
        return Colors.blue[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'failed':
      case 'error':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'done':
        return Icons.check_circle_outline;
      case 'in_progress':
      case 'working':
        return Icons.sync;
      case 'pending':
        return Icons.schedule;
      case 'failed':
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildActionButton(DetailTaskEquipment task, bool isCompleted) {
    return Container(
      width: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [cusBlue, const Color.fromARGB(255, 71, 137, 203)]
              : [
                  const Color.fromARGB(255, 51, 109, 167),
                  const Color.fromARGB(255, 46, 123, 190),
                ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(task.uuid),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.edit_outlined
                        : Icons.play_circle_fill_sharp,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCompleted
                      ? AppLocalizations.of(context)!.edit
                      : AppLocalizations.of(context)!.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(String formId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            ChecklistDetailPopup(keyW: "daily", formId: formId),
      ),
    );
    // Nếu từ màn hình con trả về true thì load lại dữ liệu
    if (result == true) {
      setState(() {
        futureEquipment = InspectionService.fetchEquipmentByUuid(
          widget.uuid,
          widget.dateFrom,
          widget.dateTo,
        );
      });
    }
  }

  Tab _buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 13)),
        ],
      ),
    );
  }

  // Color _getStatusColor(String? status) {
  //   switch (status) {
  //     case "done":
  //       return Colors.green;
  //     case "good":
  //       return Colors.blue;
  //     case "issue":
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }
}
