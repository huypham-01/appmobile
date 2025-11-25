import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/screens/widgets/issuse_dialog.dart';
import 'package:mobile/ems/screens/widgets/machine_detail.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../data/auth_api_service.dart';
import '../../data/models/machine_model.dart';

class TabScreen extends StatefulWidget {
  final String keywork;
  final bool canAction;
  final Function(TabStats)? onStatsUpdate;
  const TabScreen({
    super.key,
    required this.keywork,
    this.onStatsUpdate,
    required this.canAction,
  });
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  List<Machine> deviceDataList = [];
  bool isLoading = false;
  String? errorMessage;
  Timer? _refreshTimer;
  bool isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadData(showLoading: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!isLoading) {
        _loadData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = false}) async {
    if (isLoading) {
      print('⚠️ Already loading, skip this call');
      return;
    }

    if (showLoading) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await EmsApiService.fetchMachine(widget.keywork);
      if (mounted) {
        setState(() {
          deviceDataList = response;
          isLoading = false;
          isInitialLoad = false;
        });
        print('✅ Data loaded: ${deviceDataList.length} devices');
        _calculateAndSendStats();
      }
    } catch (e) {
      if (showLoading || isInitialLoad) {
        if (mounted) {
          setState(() {
            errorMessage = e.toString();
            isLoading = false;
          });
          _showErrorDialog(e.toString());
        }
      } else {
        print('⚠️ Silent refresh failed: $e');
      }
    }
  }

  void _calculateAndSendStats() {
    if (widget.onStatsUpdate == null) return;

    int total = deviceDataList.length;
    int online = deviceDataList
        .where((m) => m.status.toUpperCase() == 'NORMAL')
        .length;
    int offline = deviceDataList
        .where((m) => m.status.toUpperCase() == 'DISCONNECTED')
        .length;
    int flexible = deviceDataList.where((m) => m.isFlex).length;
    int warning = deviceDataList
        .where((m) => m.status.toUpperCase() == 'BREACHED')
        .length;
    int action = deviceDataList.where((m) => m.hasAction).length;

    final stats = TabStats(
      total: total,
      online: online,
      offline: offline,
      flexible: flexible,
      warning: warning,
      action: action,
    );

    widget.onStatsUpdate!(stats);
  }

  List<Machine> get filteredMachineData {
    List<Machine> devices = deviceDataList.toList();

    // Xác định "thứ tự ưu tiên" cho status
    int getPriority(String status) {
      switch (status.toUpperCase()) {
        case 'BREACHED':
          return 0;
        case 'NORMAL':
          return 1;
        case 'DISCONNECTED':
          return 2;
        default:
          return 3; // status khác thì xếp sau cùng
      }
    }

    devices.sort((a, b) {
      final aPriority = getPriority(a.status);
      final bPriority = getPriority(b.status);

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return a.moldId.compareTo(b.moldId); // cùng nhóm thì sort theo moldId
    });

    return devices;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData(showLoading: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && isInitialLoad) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 6, // số lượng skeleton tuỳ ý
        itemBuilder: (context, index) => const MachineCardSkeleton(),
      );
    }

    if (errorMessage != null && deviceDataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(showLoading: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final machines = filteredMachineData;

    if (machines.isEmpty) {
      return const Center(child: Text('No machines available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        return MachineCard(
          machine: machines[index],
          keywork: widget.keywork,
          canAction: widget.canAction,
        );
      },
    );
  }
}

// Widget riêng để hiển thị từng machine card
class MachineCard extends StatelessWidget {
  final Machine machine;
  final String keywork;
  final bool canAction;

  const MachineCard({
    super.key,
    required this.machine,
    required this.keywork,
    required this.canAction,
  });

  // Helper function để format số thông minh
  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra điều kiện vi phạm
    final bool isCycleAboveUL =
        (machine.upperLimit != 999.9) &&
        (machine.currentCycle > machine.upperLimit);

    final bool isCycleBelowLL =
        (machine.lowerLimit != 999.9) &&
        (machine.currentCycle < machine.lowerLimit);
    final bool isCavityMismatch = machine.moldCavity != machine.actualCavity;
    final bool isCavityefficiency =
        machine.efficiency < machine.efficiencylowerlimit;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính toán kích thước động dựa trên constraints
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        // Tính toán font size dựa trên kích thước card
        final headerFontSize = (cardWidth * 0.08).clamp(12.0, 15.0);
        final headerSubFontSize = (cardWidth * 0.07).clamp(10.0, 12.0);
        final highlightFontSize = (cardWidth * 0.9).clamp(14.0, 17.0);
        final normalFontSize = (cardWidth * 0.09).clamp(10.0, 14.0);
        final labelFontSize = (cardWidth * 0.04).clamp(9.0, 11.0);
        final footerFontSize = (cardWidth * 0.05).clamp(8.0, 10.0);

        // Tính toán padding dựa trên kích thước card
        final headerPadding = (cardHeight * 0.015).clamp(3.0, 6.0);
        final cellPadding = (cardHeight * 0.012).clamp(4.0, 8.0);
        final footerPadding = (cardHeight * 0.008).clamp(2.0, 4.0);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) =>
                    MachineDetail(machine: machine, keyw: keywork),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: headerPadding,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusHeaderColor(machine.status),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            machine.moldId,
                            style: TextStyle(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if (headerPadding > 3)
                            SizedBox(height: headerPadding * 0.2),
                          Text(
                            machine.family,
                            style: TextStyle(
                              fontSize: headerSubFontSize,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Badge góc phải
                    if (machine.hasAction)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            bool loggedIn = await ApiServiceAuth.isLoggedIn();
                            if (loggedIn) {
                              if (canAction) {
                                _showIssuesDialog(context, machine.moldId);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.errorLogin,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 130, 94, 192),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topRight: Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "A",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (machine.isFlex)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              86,
                              181,
                              198,
                            ), // màu tím như ảnh
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(9),
                              topLeft: Radius.circular(
                                10,
                              ), // bo đúng góc dưới bên trái
                            ),
                            border: Border.all(
                              color: Colors.white, // màu viền
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "F",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Body
                machine.lastUpdated == null
                    ? Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.nodata,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Hàng 1: Current Cycle & Efficiency
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildCell(
                                      "${_formatNumber(machine.currentCycle)}${_getUnit(keywork)}",
                                      AppLocalizations.of(
                                        context,
                                      )!.currentcycle,
                                      flex: 1,
                                      highlight: true,
                                      borderRight: true,
                                      borderBottom: true,
                                      highlightFontSize: highlightFontSize,
                                      normalFontSize: normalFontSize,
                                      labelFontSize: labelFontSize,
                                      cellPadding: cellPadding,
                                      isError: isCycleAboveUL || isCycleBelowLL,
                                    ),
                                    _buildCell(
                                      "${_formatNumber(machine.efficiency)}%",
                                      AppLocalizations.of(context)!.efficiency,
                                      flex: 1,
                                      highlight: true,
                                      borderBottom: true,
                                      highlightFontSize: highlightFontSize,
                                      normalFontSize: normalFontSize,
                                      labelFontSize: labelFontSize,
                                      cellPadding: cellPadding,
                                      isError: isCavityefficiency,
                                    ),
                                  ],
                                ),
                              ),
                              // Hàng 2: UL, Target, LL
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildCell(
                                      machine.upperLimit == 999.9
                                          ? "N/A"
                                          : _formatNumber(machine.upperLimit),
                                      "UL",
                                      borderRight: true,
                                      borderBottom: true,
                                      highlightFontSize: highlightFontSize,
                                      normalFontSize: normalFontSize,
                                      labelFontSize: labelFontSize,
                                      cellPadding: cellPadding,
                                      isError: isCycleAboveUL,
                                    ),
                                    _buildCell(
                                      machine.target == 999.9
                                          ? "N/A"
                                          : _formatNumber(machine.target),
                                      AppLocalizations.of(context)!.target,
                                      borderRight: true,
                                      borderBottom: true,
                                      highlightFontSize: highlightFontSize,
                                      normalFontSize: normalFontSize,
                                      labelFontSize: labelFontSize,
                                      cellPadding: cellPadding,
                                    ),
                                    _buildCell(
                                      machine.target == 999.9
                                          ? "N/A"
                                          : _formatNumber(machine.lowerLimit),
                                      "LL",
                                      borderBottom: true,
                                      highlightFontSize: highlightFontSize,
                                      normalFontSize: normalFontSize,
                                      labelFontSize: labelFontSize,
                                      cellPadding: cellPadding,
                                      isError: isCycleBelowLL,
                                    ),
                                  ],
                                ),
                              ),
                              // Hàng 3: Process, Actual Cavity, Mold Cavity
                              if (keywork == "mold")
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildCell(
                                        machine.process.toString(),
                                        AppLocalizations.of(context)!.process,
                                        borderRight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                      ),
                                      _buildCell(
                                        machine.actualCavity.toString(),
                                        AppLocalizations.of(
                                          context,
                                        )!.actualcavity,
                                        borderRight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                        isError: isCavityMismatch,
                                      ),
                                      _buildCell(
                                        machine.moldCavity.toString(),
                                        AppLocalizations.of(
                                          context,
                                        )!.moldcavity,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                        isError: isCavityMismatch,
                                      ),
                                    ],
                                  ),
                                ),
                              if (keywork == "tuft")
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildCell(
                                        machine.process.toString(),
                                        AppLocalizations.of(context)!.process,
                                        borderRight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                      ),
                                      _buildCell(
                                        machine.holePerBrush == null
                                            ? "N/A"
                                            : _formatNumber(machine.rpm!),
                                        // "aa",
                                        AppLocalizations.of(context)!.rpm,
                                        flex: 1,
                                        highlight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                      ),
                                    ],
                                  ),
                                ),
                              if (keywork == "blister")
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildCell(
                                        machine.bushPerCycle == null
                                            ? "N/A"
                                            : _formatNumber(
                                                machine.bushPerCycle!,
                                              ),
                                        AppLocalizations.of(
                                          context,
                                        )!.brushesPerCycle,
                                        borderRight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                      ),
                                      _buildCell(
                                        machine.output == null
                                            ? "N/A"
                                            : _formatNumber(machine.output!),
                                        AppLocalizations.of(context)!.pcsMinute,
                                        flex: 1,
                                        highlight: true,
                                        borderBottom: false,
                                        highlightFontSize: highlightFontSize,
                                        normalFontSize: normalFontSize,
                                        labelFontSize: labelFontSize,
                                        cellPadding: cellPadding,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                // Footer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: footerPadding,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(153, 239, 235, 235),
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      right: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    machine.lastUpdated ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: footerFontSize,
                      color: const Color.fromARGB(255, 85, 84, 84),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _getUnit(String key) {
    switch (key) {
      case 'mold':
        return "s";
      case 'tuft':
        return "pcs";
      case 'blister':
        return "cycles";
    }
  }

  Color _getStatusHeaderColor(String status) {
    switch (status.toUpperCase()) {
      case 'NORMAL':
        return Colors.green.shade400;
      case 'DISCONNECTED':
        return Colors.grey.shade400;
      case 'BREACHED':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildCell(
    String value,
    String label, {
    int flex = 1,
    bool highlight = false,
    bool borderRight = false,
    bool borderBottom = false,
    required double highlightFontSize,
    required double normalFontSize,
    required double labelFontSize,
    required double cellPadding,
    bool isError = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: cellPadding * 0.8,
          horizontal: cellPadding * 0.6,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: borderRight
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
            bottom: borderBottom
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: highlight ? highlightFontSize : normalFontSize,
                    fontWeight: FontWeight.bold,
                    color: isError ? Color(0xFFE74C3C) : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: cellPadding * 0.05),
            Flexible(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIssuesDialog(BuildContext context, String deviecId) {
    showDialog(
      context: context,
      builder: (context) => IssuesDialog(deviceId: deviecId),
    );
  }
}

class MachineCardSkeleton extends StatelessWidget {
  const MachineCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // ---------------------------
          // Header Skeleton
          // ---------------------------
          Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // ---------------------------
          // Body Skeleton
          // ---------------------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---------------------------
          // Footer Skeleton
          // ---------------------------
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
