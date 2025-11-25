// screens/equipment_detail.dart
import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../../data/models/task_equipment_today.dart';
import '../../../data/services/task_equipment_today_service.dart';
import 'checklist_detail_popup.dart';

class OverDueDetailScreen extends StatefulWidget {
  final String uuid;
  final String equipmentId;

  const OverDueDetailScreen({
    super.key,
    required this.uuid,
    required this.equipmentId,
  });

  @override
  State<OverDueDetailScreen> createState() => _OverDueDetailScreenState();
}

class _OverDueDetailScreenState extends State<OverDueDetailScreen>
    with TickerProviderStateMixin {
  late Future<List<TaskOverDueDetail>> futureOverDue;

  @override
  void initState() {
    super.initState();
    futureOverDue = InspectionService.fetchOverDueDetail(widget.uuid);
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        futureOverDue = InspectionService.fetchOverDueDetail(widget.uuid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<TaskOverDueDetail>>(
        future: futureOverDue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.errorLoading}: ${snapshot.error}",
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTasksFound,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => futureOverDue,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final task = snapshot.data![index];
                  return _buildTaskCard(task);
                },
              ),
            );
          }
        },
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
        '${AppLocalizations.of(context)!.overDueTask} - ${widget.equipmentId}',
        style: const TextStyle(color: Colors.white, fontSize: 21),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskOverDueDetail task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: getMaintenanceColor(task.type),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: getMaintenanceColor(
                                    task.type,
                                  ).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  task.type,
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

                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${AppLocalizations.of(context)!.dateStart} : ",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatDate(task.dateStart),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),

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
                                  task.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
              ),

              // Action button
              _buildActionButton(task),
            ],
          ),
        ),
      ),
    );
  }

  // Color getMaintenanceColor(String? type) {
  //   switch (type?.toLowerCase()) {
  //     case 'maintenance level 1':
  //       return Colors.cyan[700]!;
  //     case 'maintenance level 2':
  //       return Colors.orange[400]!;
  //     case 'maintenance level 3':
  //       return Colors.red[400]!;
  //     default:
  //       return Colors.indigo[200]!;
  //   }
  // }

  Widget _buildActionButton(TaskOverDueDetail task) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: cusBlue,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(task.type, task.uuid),
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

                  child: const Icon(
                    Icons.play_circle_fill_sharp,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.start,
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

  String getKeyW(String key) {
    switch (key.toLowerCase()) {
      case "maintenance level 1":
        return "maintenance";
      case "maintenance level 2":
        return "maintenance";
      case "maintenance level 3":
        return "maintenance";
      default:
        return "daily";
    }
  }

  void _navigateToDetail(String keyW, String formId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            ChecklistDetailPopup(keyW: getKeyW(keyW), formId: formId),
      ),
    );
    // Nếu từ màn hình con trả về true thì load lại dữ liệu
    if (result == true && mounted) {
      _loadData();
    }
  }
}
