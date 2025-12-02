import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../../data/models/equipment.dart';
import '../../../data/services/equipment_service.dart';
import 'equipment_detail_WI_screen.dart';

class EquipmentDetailBottomSheet extends StatefulWidget {
  final dynamic equipment;
  const EquipmentDetailBottomSheet({super.key, required this.equipment});

  @override
  State<EquipmentDetailBottomSheet> createState() =>
      _EquipmentDetailBottomSheetState();
}

class _EquipmentDetailBottomSheetState extends State<EquipmentDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  String? selectedTask;
  late Future<Map<String, List<WIItem>>> futureGroupedCodes;
  Map<String, List<WIItem>> groupedCodes = {};
  late Future<NextWIItem> futureNextWI;
  NextWIItem? nextWIData;
  final List<String> fixedTasks = [
    "Daily Inspection",
    "Maintenance Level 1",
    "Maintenance Level 2",
    "Maintenance Level 3",
  ];

  late TabController _tabController;

  // Helper method để lấy giá trị từ equipment
  dynamic getEquipmentValue(String key) {
    if (widget.equipment is Map) {
      return widget.equipment[key];
    } else {
      switch (key) {
        case 'uuid':
          return widget.equipment.uuid;
        case 'name':
          return widget.equipment.name;
        case 'machineId':
          return widget.equipment.machineId;
        case 'model':
          return widget.equipment.model;
        case 'cavity':
          return widget.equipment.cavity;
        case 'status':
          return widget.equipment.status;
        case 'category':
          return widget.equipment.category;
        case 'manufacturer':
          return widget.equipment.manufacturer;
        case 'manufacturingDate':
          return widget.equipment.manufacturingDate;
        case 'historyCount':
          return widget.equipment.historyCount;
        case 'unit':
          return widget.equipment.unit;
        default:
          return null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Khởi tạo selectedTask mặc định là Daily Inspection
    selectedTask = "Daily Inspection";

    futureGroupedCodes = EquipmentService.getWIEquipmentById(
      getEquipmentValue("uuid"),
    );
    futureGroupedCodes.then((data) {
      setState(() {
        groupedCodes = data;
      });
    });

    // Lấy dữ liệu Next WI
    futureNextWI = EquipmentService.getNextWorkingInstructionById(
      getEquipmentValue("uuid"),
    );
    futureNextWI
        .then((data) {
          setState(() {
            nextWIData = data;
          });
        })
        .catchError((error) {
          print('Error loading next WI: $error');
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // header - Hiển thị khác nhau tùy tab
              // if (_tabController.index == 1)
              // Tab Master Plan: hiển thị header cards
              _buildHeaderCards(),
              // else
              //   // Các tab khác: hiển thị text header
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 8),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const SizedBox(width: 15),
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 _buildHeaderTitle(),
              //                 style: const TextStyle(
              //                   fontSize: 20,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //                 softWrap: true,
              //                 overflow: TextOverflow.visible,
              //               ),
              //               if (_tabController.index == 0) ...[
              //                 Text(
              //                   "Model: ${getEquipmentValue("model")?.toString() ?? ''}",
              //                 ),
              //                 Text(
              //                   "Cavity: ${getEquipmentValue("cavity")?.toString() ?? ''}",
              //                 ),
              //               ],
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 8),

              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                padding: EdgeInsets.zero,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.detail),
                  Tab(text: AppLocalizations.of(context)!.masterPlan),
                  Tab(text: AppLocalizations.of(context)!.breakdown),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildDetailTab(),
                    buildMasterPlanTab(),
                    Center(
                      child: Text(AppLocalizations.of(context)!.noDataFound),
                    ),
                  ],
                ),
              ),

              // Align(
              //   alignment: Alignment.center,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(context),
              //     child: const Text("Close"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // String _buildHeaderTitle() {
  //   final equipmentName = getEquipmentValue("name")?.toString() ?? "No name";
  //   switch (_tabController.index) {
  //     case 0:
  //       return equipmentName;
  //     case 1:
  //       return ""; // Trống vì sẽ dùng _buildHeaderCards
  //     case 2:
  //       return "$equipmentName - Breakdown";
  //     default:
  //       return equipmentName;
  //   }
  // }

  // TAB MASTER PLAN MỚI
  Widget buildMasterPlanTab() {
    return Column(
      children: [
        const SizedBox(height: 5),
        // Task Tabs
        _buildTaskTabs(),
        const SizedBox(height: 5),
        // Task List
        Expanded(child: _buildTaskList()),
      ],
    );
  }

  Widget _buildHeaderCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nếu chiều rộng nhỏ hơn 600 => coi là điện thoại
        bool isTablet = constraints.maxWidth >= 600;
        int crossAxisCount = isTablet ? 4 : 2; // 4 thẻ ngang hoặc 2x2

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: isTablet ? 4 : 3, // tinh chỉnh tỷ lệ thẻ
          padding: EdgeInsets.zero, // Loại bỏ padding mặc định
          children: [
            _buildInfoCard(
              icon: Icons.build_circle_outlined,
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.shade50,
              label: AppLocalizations.of(context)!.machineid,
              value: getEquipmentValue("machineId")?.toString() ?? "-",
            ),
            _buildInfoCard(
              icon: Icons.trending_up,
              iconColor: Colors.green,
              iconBgColor: Colors.green.shade50,
              label: AppLocalizations.of(context)!.currentCount,
              value: getEquipmentValue("historyCount")?.toString() ?? "-",
            ),
            _buildInfoCard(
              icon: Icons.next_plan_rounded,
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.shade50,
              label: AppLocalizations.of(context)!.nextCount,
              value: nextWIData?.countTarget ?? "-",
              onTap: nextWIData != null ? () => _showNextWIDetails() : null,
            ),
            _buildInfoCard(
              icon: Icons.schedule_outlined,
              iconColor: Colors.purple,
              iconBgColor: Colors.purple.shade50,
              label: AppLocalizations.of(context)!.estDate,
              value: formatDate(nextWIData?.dateStart),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.keyboard_arrow_up,
                color: Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTabs() {
    // Map để convert tên task sang display name với số La Mã
    String getTaskDisplayName(String task) {
      final taskCount = groupedCodes[task]?.length ?? 0;

      switch (task) {
        case "Daily Inspection":
          return "Daily ($taskCount)";
        case "Maintenance Level 1":
          return "ML I ($taskCount)";
        case "Maintenance Level 2":
          return "ML II ($taskCount)";
        case "Maintenance Level 3":
          return "ML III ($taskCount)";
        default:
          return "$task ($taskCount)";
      }
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: fixedTasks.asMap().entries.map((entry) {
          final task = entry.value;
          final isActive = selectedTask == task;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTask = task;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  getTaskDisplayName(task),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    // Lấy task đang được chọn
    final currentTask = selectedTask ?? "Daily Inspection";
    final tasks = groupedCodes[currentTask] ?? [];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No tasks available",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Xác định label và màu cho badge

    Color badgeColor;
    Color badgeBgColor;

    if (currentTask == "Daily Inspection") {
      badgeColor = Colors.blue;
      badgeBgColor = Colors.blue.shade50;
    } else if (currentTask == "Maintenance Level 1") {
      badgeColor = Colors.green;
      badgeBgColor = Colors.green.shade50;
    } else if (currentTask == "Maintenance Level 2") {
      badgeColor = Colors.orange;
      badgeBgColor = Colors.orange.shade50;
    } else {
      badgeColor = Colors.red;
      badgeBgColor = Colors.red.shade50;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(1),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 10,
              top: 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TASK CODE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.code,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.frequency == "Unit"
                                  ? "${task.unitValue} ${task.unitType}"
                                  : task.frequency,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          if (task.countTarget != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${task.countTarget} ${task.unitType}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => EquipmentDetailWiScreen(
                              schemaString: task.schema,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // --- DESCRIPTION ---
                Text(
                  task.name,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDetailTab() {
    List<Map<String, String>> details = [
      {
        "label": AppLocalizations.of(context)!.categoryLabel,
        "value": "${getEquipmentValue("category") ?? ''}",
      },
      {
        "label": AppLocalizations.of(context)!.manufacturer,
        "value": "${getEquipmentValue("manufacturer") ?? ''}",
      },
      {
        "label": "Manufacturer Date",
        "value": "${getEquipmentValue("manufacturingDate") ?? ''}",
      },
      {
        "label": AppLocalizations.of(context)!.historycount,
        "value": "${getEquipmentValue("historyCount") ?? ''}",
      },
      {
        "label": AppLocalizations.of(context)!.unit,
        "value": "${getEquipmentValue("unit") ?? ''}",
      },
    ];

    return SingleChildScrollView(
      child: Card(
        color: Colors.white70,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.information,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...details.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, String> detail = entry.value;
                return Container(
                  color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: buildDetailRow(detail["label"]!, detail["value"]!),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Show popup chi tiết Next WI
  void _showNextWIDetails() {
    if (nextWIData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.next_plan_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.nextCount,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextWIData!.countTarget,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Maintenance Level
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                nextWIData!.type,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                nextWIData!.code,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
