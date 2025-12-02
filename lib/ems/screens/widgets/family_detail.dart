import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/data/models/machine_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/utils/routes/ems_routes.dart';

class FamilyDetail extends StatefulWidget {
  const FamilyDetail({super.key});

  @override
  State<FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<FamilyDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductionApiService _apiService;

  late DateTime fromDate;
  late DateTime toDate;
  String? selectedFamily;

  List<ProductionData> outputData = [];
  List<EfficiencyDataa> efficiencyDataa = [];
  List<String> familyList = [
    'All',
    'Alpha',
    'Arjun (Oral-B)',
    'Bane',
    'Classic 35 (Oral-B) ST',
    'Classic 40 (Oral-B)',
    'Gucci (Oral-B)',
    'Indicator 35 (U35)',
    'Jordan Green family',
    'Jordan Step 1',
    'Jordan Step 2',
    'Jordan Step 3',
    'Robinhood (Oral-B)',
    'Sherwood 40 (Oral-B)',
    'Wisdom Adult',
    'Wisdom Kids',
    'ZAHA Junior',
    'ZAHA Kids',
  ];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tự động tính toán fromDate và toDate: 7:00 sáng hôm qua đến 7:00 sáng hôm nay
    DateTime now = DateTime.now();
    toDate = DateTime(now.year, now.month, now.day, 7, 0);
    fromDate = toDate.subtract(const Duration(days: 1));

    // Initialize API service with your base URL
    _apiService = ProductionApiService();

    // Load initial data
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiService.getProductionData(
        fromDate: fromDate,
        toDate: toDate,
        family: selectedFamily == 'All' ? '' : (selectedFamily ?? ''),
      );

      setState(() {
        outputData = _apiService.getOutputDataList(response);
        efficiencyDataa = _apiService.getEfficiencyDataList(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getEfficiencyColor(double? efficiency) {
    if (efficiency == null) return Colors.grey.shade100;
    return Colors.red.shade50;
  }

  double? _averageEfficiency(double? Function(EfficiencyDataa data) selector) {
    double sum = 0;
    int count = 0;

    for (final item in efficiencyDataa) {
      final value = selector(item);
      if (value != null) {
        sum += value;
        count++;
      }
    }

    if (count == 0) return null;
    return sum / count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("assets/images/acumenIcon.png", height: 26),
            const SizedBox(width: 10),
            const Text(
              "EMS Family",
              style: TextStyle(
                color: Color.fromARGB(221, 35, 34, 34),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: "NotoSansSC",
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<String>(
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              icon: const Icon(
                Icons.menu_sharp,
                color: Colors.black87,
                size: 30,
              ),
              itemBuilder: (context) => [
                _buildMenuItem(
                  context: context,
                  value: 'menu1',
                  icon: Icons.dashboard_outlined,
                  text: AppLocalizations.of(context)!.monitoring,
                  onTap: () {
                    Navigator.pushNamed(context, EmsRoutes.home);
                  },
                ),

                const PopupMenuDivider(),
                _buildMenuItem(
                  context: context,
                  value: 'menu4',
                  icon: Icons.arrow_back,
                  text: AppLocalizations.of(context)!.back,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, EmsRoutes.home);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                // -------------------------------
                // DATE RANGE PICKER
                // -------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        label: AppLocalizations.of(context)!.fromdateline,
                        dateTime: fromDate,
                        onTap: () => _selectDateTime(context, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateTimeField(
                        label: AppLocalizations.of(context)!.todateline,
                        dateTime: toDate,
                        onTap: () => _selectDateTime(context, false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // -------------------------------
                // FAMILY + SEARCH BUTTON
                // -------------------------------
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isDense:
                            true, // 🔥 Quan trọng để chiều cao không phình to
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.family,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),

                          // 🔥 Padding giống y Input DateTimeField
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),

                        value: selectedFamily,
                        hint: Text(
                          '— ${AppLocalizations.of(context)!.selectfamily} —',
                        ),

                        items: familyList.map((family) {
                          return DropdownMenuItem(
                            value: family,
                            child: Text(family),
                          );
                        }).toList(),

                        onChanged: (value) =>
                            setState(() => selectedFamily = value),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // -------- SEARCH BUTTON --------
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _loadData,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.search,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.outputPcs),
              Tab(text: AppLocalizations.of(context)!.efficiency),
            ],
          ),
          // Tab Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.errorLoadingData,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [_buildOutputTab(), _buildEfficiencyTab()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(dateTime),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isFrom) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isFrom ? fromDate : toDate),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isFrom) {
            fromDate = newDateTime;
          } else {
            toDate = newDateTime;
          }
        });
      }
    }
  }

  Widget _buildOutputTab() {
    if (outputData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        // Card tổng ở trên
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _buildOutputSummaryCard(),
        ),
        const SizedBox(height: 4),
        // List chi tiết bên dưới
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            itemCount: outputData.length,
            itemBuilder: (context, index) {
              return _buildOutputCard(outputData[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyTab() {
    if (efficiencyDataa.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        // Card tổng / trung bình ở trên
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _buildEfficiencySummaryCard(),
        ),
        const SizedBox(height: 4),
        // List chi tiết bên dưới
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            itemCount: efficiencyDataa.length,
            itemBuilder: (context, index) {
              return _buildEfficiencyCard(efficiencyDataa[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOutputCard(ProductionData data) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.family,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.molding,
                    data.molding,
                    Colors.grey.shade100,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.tufting,
                    data.tufting,
                    Colors.grey.shade100,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.blistering,
                    data.blistering,
                    Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard(EfficiencyDataa data) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.family,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.molding,
                    data.moldingEfficiency,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.tufting,
                    data.tuftingEfficiency,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.blistering,
                    data.blisteringEfficiency,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessValue(String label, int? value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          // const SizedBox(height: 2),
          Text(
            value != null ? NumberFormat('#,###').format(value) : '-',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyValue(String label, double? efficiency) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getEfficiencyColor(efficiency),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            efficiency != null ? '${efficiency.toStringAsFixed(2)}%' : '-',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String text,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 28,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) onTap();
        },
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSummaryCard() {
    final int totalMolding = outputData.fold<int>(
      0,
      (sum, item) => sum + (item.molding ?? 0),
    );
    final int totalTufting = outputData.fold<int>(
      0,
      (sum, item) => sum + (item.tufting ?? 0),
    );
    final int totalBlistering = outputData.fold<int>(
      0,
      (sum, item) => sum + (item.blistering ?? 0),
    );

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.totaloutput,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.molding,
                    totalMolding,
                    Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.tufting,
                    totalTufting,
                    Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProcessValue(
                    AppLocalizations.of(context)!.blistering,
                    totalBlistering,
                    Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencySummaryCard() {
    final double? avgMolding = _averageEfficiency((e) => e.moldingEfficiency);
    final double? avgTufting = _averageEfficiency((e) => e.tuftingEfficiency);
    final double? avgBlistering = _averageEfficiency(
      (e) => e.blisteringEfficiency,
    );

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.average,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.molding,
                    avgMolding,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.tufting,
                    avgTufting,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEfficiencyValue(
                    AppLocalizations.of(context)!.blistering,
                    avgBlistering,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
