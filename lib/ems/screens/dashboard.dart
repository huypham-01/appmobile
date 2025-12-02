import 'dart:async'; // 🔹 Quan trọng để dùng Timer
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/screens/widgets/machine_detail_efficiency_popup.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../utils/routes/ems_routes.dart';
import '../data/models/machine_model.dart';
import 'widgets/machine_detail_all_popup.dart';
import 'widgets/machine_detail_output_popup.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SummaryReport? _reportData;
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _timer; // 🔹 Thêm biến Timer

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();

    // 🔁 Thiết lập auto refresh mỗi 5 giây
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _loadData();
      print('loadd');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 🔹 Dừng timer khi widget bị hủy
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final todayAtSeven = DateTime(now.year, now.month, now.day, 7, 0);
      final DateTime to = todayAtSeven;
      final DateTime from = to.subtract(const Duration(days: 1));

      final data = await EmsApiService.fetchSummaryReport(from: from, to: to);

      if (!mounted) return; // 🔹 Đảm bảo widget còn tồn tại

      setState(() {
        _reportData = data;
        _isLoading = false;
        _errorMessage = data == null ? 'Unable to load data.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  bool get isTablet {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.emsdashboard,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: "NotoSansSC",
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0), // cách lề phải 10
            child: Material(
              color: Colors.transparent,
              elevation: 0, // độ đổ bóng
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pushNamed(context, EmsRoutes.family);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.family,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.molding),
                  Tab(text: AppLocalizations.of(context)!.tufting),
                  Tab(text: AppLocalizations.of(context)!.blistering),
                ],
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.normal,
                ),
                indicator: BoxDecoration(color: Colors.grey[100]),
                indicatorSize: TabBarIndicatorSize.tab,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return TabBarView(
        controller: _tabController,
        children: [
          DashboardSkeleton(isTablet: isTablet),
          DashboardSkeleton(isTablet: isTablet),
          DashboardSkeleton(isTablet: isTablet),
        ],
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }

    if (_reportData == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildProcessView("Mold", _reportData!.mold),
        _buildProcessView("Tuft", _reportData!.tuft),
        _buildProcessView("Blister", _reportData!.blister),
      ],
    );
  }

  Widget _buildProcessView(String processName, MachineData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 10 : 8),
      child: _buildProcessCard(processName, data),
    );
  }

  Widget _buildProcessCard(String processName, MachineData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.only(top: 2, left: 12, right: 12),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [Colors.blue[50]!, Colors.white],
          //     ),
          //     borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(12),
          //       topRight: Radius.circular(12),
          //     ),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Text(
          //         processName,
          //         style: TextStyle(
          //           fontSize: isTablet ? 18 : 16,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.grey[800],
          //         ),
          //       ),
          //       const Spacer(),
          //       TextButton.icon(
          //         onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => MachineDetailAllPopup(
          //                 processName: _convertProcessName(processName),
          //                 status: "total",
          //               ),
          //             ),
          //           );
          //         },
          //         icon: const Icon(Icons.info_outline, color: Colors.blue),
          //         label: Text(
          //           AppLocalizations.of(context)!.detail,
          //           style: TextStyle(color: Colors.blue),
          //         ),
          //         style: TextButton.styleFrom(
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 4,
          //             vertical: 2,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(isTablet ? 6 : 4),
            child: Column(
              children: [
                _buildStatusSection(processName, data.status),
                const SizedBox(height: 8),
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildEfficiencySection(
                          processName,
                          data.efficiency,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOutputSection(processName, data.output),
                      ),
                    ],
                  )
                else ...[
                  _buildEfficiencySection(processName, data.efficiency),
                  const SizedBox(height: 8),
                  _buildOutputSection(processName, data.output),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Status section cứng
  Widget _buildStatusSection(String processName, StatusData status) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(233, 255, 253, 253),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.status,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  AppLocalizations.of(context)!.total,
                  status.total.toString(),
                  Colors.blue,
                  Icons.precision_manufacturing,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MachineDetailAllPopup(
                          processName: processName,
                          status: "total",
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: isTablet ? 12 : 6),
              Expanded(
                child: _buildStatusCard(
                  AppLocalizations.of(context)!.running,
                  status.running.toString(),
                  Colors.green,
                  Icons.play_circle_filled,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MachineDetailAllPopup(
                          processName: processName,
                          status: "running",
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildStatusCard(
                  AppLocalizations.of(context)!.breakdown,
                  "0",
                  Colors.orange,
                  Icons.warning,
                  () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MachineDetailAllPopup(
                    //       processName: processName,
                    //       status: "breakdown ",
                    //     ),
                    //   ),
                    // );
                  },
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildStatusCard(
                  AppLocalizations.of(context)!.warning,
                  status.warning.toString(),
                  Colors.red,
                  Icons.error_outline,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MachineDetailAllPopup(
                          processName: processName,
                          status: "warning",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 6 : 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon(icon, color: color, size: isTablet ? 24 : 20),
            // SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencySection(
    String processName,
    EfficiencyData efficiency,
  ) {
    return Container(
      padding: EdgeInsets.all((isTablet ? 6 : 4)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(233, 255, 253, 253),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 240, 244, 241)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: Colors.grey[800],
                size: isTablet ? 20 : 18,
              ),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.efficiency,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          _buildEfficiencyItem(
            '${AppLocalizations.of(context)!.dateshift} (07:00 - 19:00)',
            efficiency.day,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailEfficiencyPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "day",
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 8 : 6),
          _buildEfficiencyItem(
            '${AppLocalizations.of(context)!.nightshift} (19:00 - 07:00)',
            efficiency.night,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailEfficiencyPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "night",
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 8 : 2),
          Divider(color: const Color.fromARGB(255, 182, 186, 189)),
          SizedBox(height: isTablet ? 8 : 2),
          _buildEfficiencyItem(
            AppLocalizations.of(context)!.average,
            efficiency.average,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailEfficiencyPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "average",
                  ),
                ),
              );
            },
            isAverage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyItem(
    String title,
    double percentage,
    VoidCallback onTap, {
    bool isAverage = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(255, 240, 244, 241),
            width: isAverage ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: isAverage ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: isTablet ? 60 : 50,
              height: isTablet ? 60 : 50,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[600]!,
                      ),
                      strokeWidth: isTablet ? 6 : 5,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection(String processName, OutputData output) {
    return Container(
      padding: EdgeInsets.all((isTablet ? 6 : 4)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(233, 255, 253, 253),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 240, 244, 241)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                color: Colors.grey[700],
                size: isTablet ? 20 : 18,
              ),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.output,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          _buildOutputItem(
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailOutputPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "day",
                  ),
                ),
              );
            },
            '${AppLocalizations.of(context)!.dateshift} (07:00 - 19:00)',
            output.day,
            output.dayLostPcs.toString(),
            output.dayLossPercent.toStringAsFixed(2),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          _buildOutputItem(
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailOutputPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "night",
                  ),
                ),
              );
            },
            '${AppLocalizations.of(context)!.nightshift} (19:00 - 07:00)',
            output.night,
            output.nightLostPcs.toString(),
            output.nightLossPercent.toStringAsFixed(2),
          ),
          SizedBox(height: isTablet ? 8 : 2),
          Divider(color: const Color.fromARGB(255, 182, 186, 189)),
          SizedBox(height: isTablet ? 8 : 2),
          _buildOutputItem(
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailOutputPopup(
                    processName: _convertProcessName(processName),
                    keyWork: "total",
                  ),
                ),
              );
            },
            AppLocalizations.of(context)!.totaloutput,
            output.total,
            null,
            null,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOutputItem(
    VoidCallback onTap,
    String title,
    int output,
    String? lostPcs,
    String? lossPercent, {
    bool isTotal = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(255, 240, 244, 241),
            width: isTotal ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // '$output ${AppLocalizations.of(context)!.pcs}///',
                      '${NumberFormat('#,###').format(output)} ${AppLocalizations.of(context)!.pcs}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 47, 46, 46),
                      ),
                    ),
                    if (lostPcs != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '$lostPcs ${AppLocalizations.of(context)!.pcs}',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ],
                ),
                if (lossPercent != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$lossPercent%',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _convertProcessName(String process) {
    const mapping = {
      'Molding': 'Mold',
      'Tufting': 'Tuft',
      'Blistering': 'Blister',
    };
    return mapping[process] ?? process;
  }
}

class DashboardSkeleton extends StatelessWidget {
  final bool isTablet;
  const DashboardSkeleton({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSkeleton(),
          SizedBox(height: 12),
          _buildEfficiencySkeleton(),
          SizedBox(height: 12),
          _buildOutputSkeleton(),
        ],
      ),
    );
  }

  // ------------------------------
  // 1) STATUS SKELETON
  // ------------------------------
  Widget _buildStatusSkeleton() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 100, height: isTablet ? 16 : 14), // Title skeleton
          SizedBox(height: 10),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _bar(
                        width: isTablet ? 40 : 30,
                        height: isTablet ? 24 : 20,
                      ),
                      SizedBox(height: 6),
                      _bar(
                        width: isTablet ? 60 : 40,
                        height: isTablet ? 12 : 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // 2) EFFICIENCY SKELETON
  // ------------------------------
  Widget _buildEfficiencySkeleton() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circle(size: isTablet ? 20 : 16),
              SizedBox(width: 10),
              _bar(width: 120, height: isTablet ? 16 : 14),
            ],
          ),
          SizedBox(height: 14),

          // 3 efficiency rows skeleton
          _effItemSkeleton(),
          SizedBox(height: 10),
          _effItemSkeleton(),
          SizedBox(height: 10),
          _effItemSkeleton(),
        ],
      ),
    );
  }

  Widget _effItemSkeleton() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 120, height: isTablet ? 14 : 12),
                SizedBox(height: 6),
                _bar(width: 80, height: isTablet ? 20 : 18),
              ],
            ),
          ),
          SizedBox(width: 16),
          _circle(size: isTablet ? 55 : 50),
        ],
      ),
    );
  }

  // ------------------------------
  // 3) OUTPUT SKELETON
  // ------------------------------
  Widget _buildOutputSkeleton() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circle(size: isTablet ? 20 : 16),
              SizedBox(width: 10),
              _bar(width: 120, height: isTablet ? 16 : 14),
            ],
          ),
          SizedBox(height: 14),

          _outputItemSkeleton(),
          SizedBox(height: 10),
          _outputItemSkeleton(),
          SizedBox(height: 10),
          _outputItemSkeleton(),
        ],
      ),
    );
  }

  Widget _outputItemSkeleton() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 160, height: isTablet ? 14 : 12),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 80, height: isTablet ? 18 : 16),
                  SizedBox(height: 4),
                  _bar(width: 60, height: isTablet ? 12 : 10),
                ],
              ),
              _bar(width: 60, height: isTablet ? 14 : 12),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // Helper widgets
  // ------------------------------
  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}
