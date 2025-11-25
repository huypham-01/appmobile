// screens/inspection_list_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/cmms/presentation/screens/task/checklist_detail_popup.dart';
import 'package:mobile/cmms/presentation/screens/task/overdue_detail_screen.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/task_equipment_today.dart';
import '../../../data/services/task_equipment_today_service.dart';

class OverdueScreen extends StatefulWidget {
  const OverdueScreen({super.key});

  @override
  State<OverdueScreen> createState() => _OverdueScreenState();
}

class _OverdueScreenState extends State<OverdueScreen>
    with TickerProviderStateMixin {
  late Future<List<TaskOverDue>> futureOverDue;
  List<TaskOverDue> allInspections = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    futureOverDue = InspectionService.fetchOverDue();
    await _loadInspections();
  }

  Future<void> _loadInspections() async {
    try {
      final inspections = await InspectionService.fetchOverDue();
      if (mounted) {
        setState(() {
          allInspections = inspections;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
      print('Error loading inspections: $e');
    }
  }

  Widget _buildTasksList(List<TaskOverDue> inspections) {
    if (inspections.isEmpty) {
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
    }

    return RefreshIndicator(
      onRefresh: _loadInspections,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 8, right: 8),
        itemCount: inspections.length,
        itemBuilder: (context, index) {
          final inspection = inspections[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                    // Main content area
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OverDueDetailScreen(
                                  uuid: inspection.uuid,
                                  equipmentId: inspection.machineId,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with machine info
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cusBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${AppLocalizations.of(context)!.machineid}: ${inspection.machineId}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 3),

                                // Machine details
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _buildInfoRow(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.cavities,
                                        value: inspection.cavity,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildInfoRow(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.total,
                                        value: inspection.total.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Action button area
                    // Container(
                    //   width: 65,
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       begin: Alignment.topCenter,
                    //       end: Alignment.bottomCenter,
                    //       colors: [cusBlue, cusBlue.withOpacity(0.8)],
                    //     ),
                    //   ),
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     child: InkWell(
                    //       onTap: () async {
                    //         // await showModalBottomSheet(
                    //         //   context: context,
                    //         //   isScrollControlled: true,
                    //         //   backgroundColor: Colors.transparent,
                    //         //   constraints: BoxConstraints(
                    //         //     maxHeight:
                    //         //         MediaQuery.of(context).size.height * 0.8,
                    //         //   ),
                    //         //   builder: (_) => Container(
                    //         //     decoration: const BoxDecoration(
                    //         //       color: Colors.white,
                    //         //       borderRadius: BorderRadius.only(
                    //         //         topLeft: Radius.circular(8),
                    //         //         topRight: Radius.circular(8),
                    //         //       ),
                    //         //     ),
                    //         //     child: EquipmentDetailBottomSheet(
                    //         //       equipment: inspection,
                    //         //     ),
                    //         //   ),
                    //         // );

                    //         if (mounted) {
                    //           FocusScope.of(context).unfocus();
                    //         }
                    //       },
                    //       borderRadius: const BorderRadius.only(
                    //         topRight: Radius.circular(16),
                    //         bottomRight: Radius.circular(16),
                    //       ),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(vertical: 12),
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Container(
                    //               padding: const EdgeInsets.all(8),
                    //               decoration: BoxDecoration(
                    //                 color: Colors.white.withOpacity(0.2),
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               child: const Icon(
                    //                 Icons.arrow_forward_ios,
                    //                 color: Colors.white,
                    //                 size: 16,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             const Text(
                    //               "Detail",
                    //               style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.w600,
                    //                 fontSize: 12,
                    //                 letterSpacing: 0.5,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: cusBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shadowColor: const Color.fromARGB(0, 255, 255, 255),
        title: Text(
          AppLocalizations.of(context)!.overDueTask,
          style: const TextStyle(color: Colors.white, fontSize: 21),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInspections,
          ),
        ],
      ),
      body: FutureBuilder<List<TaskOverDue>>(
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
                    "${AppLocalizations.of(context)!.errorTitle}: ${snapshot.error}",
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInspections,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          } else {
            // Sử dụng allInspections từ setState để hỗ trợ refresh
            final inspectionsToShow = allInspections.isNotEmpty
                ? allInspections
                : (snapshot.data ?? []);
            return _buildTasksList(inspectionsToShow);
          }
        },
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      children: [
        SizedBox(width: 16),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
