import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../data/models/machine_model.dart';

class MachineDetailOutputPopup extends StatefulWidget {
  final String processName;
  final String keyWork;
  const MachineDetailOutputPopup({
    super.key,
    required this.processName,
    required this.keyWork,
  });

  @override
  State<MachineDetailOutputPopup> createState() =>
      _MachineDetailOutputPopupState();
}

class _MachineDetailOutputPopupState extends State<MachineDetailOutputPopup> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedFamily = 'All';
  List<String> familyList = ['All'];
  bool isLoading = false;
  DetailMachineOutput? outputData;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadFamilyList();
    _loadOutputData();
  }

  void _initializeDates() {
    final now = DateTime.now();

    switch (widget.keyWork.toLowerCase()) {
      case 'day':
        // 7:00 sáng hôm qua đến 19:00 tối hôm qua
        final yesterday = now.subtract(const Duration(days: 1));
        fromDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          7,
          0,
        );
        toDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          19,
          0,
        );
        break;
      case 'night':
        // 19:00 tối hôm qua đến 7:00 sáng hôm nay
        final yesterday = now.subtract(const Duration(days: 1));
        fromDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          19,
          0,
        );
        toDate = DateTime(now.year, now.month, now.day, 7, 0);
        break;
      case 'total':
        // 7:00 sáng hôm qua đến 7:00 sáng hôm nay
        final yesterday = now.subtract(const Duration(days: 1));
        fromDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          7,
          0,
        );
        toDate = DateTime(now.year, now.month, now.day, 7, 0);
        break;
      default:
        fromDate = DateTime(now.year, now.month, now.day, 7, 0);
        toDate = DateTime(now.year, now.month, now.day, 19, 0);
    }
  }

  Future<void> _loadFamilyList() async {
    try {
      final response = await EmsApiService.fetchFamilyList(
        _convertProcessNameLower(widget.processName),
      );
      if (response != null && mounted) {
        setState(() {
          familyList = ['All', ...response.families];
        });
      }
    } catch (e) {
      print('Error loading family list: $e');
    }
  }

  Future<void> _loadOutputData() async {
    if (fromDate == null || toDate == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await EmsApiService.fetchDetailMachineOutput(
        fromDate: fromDate!,
        toDate: toDate!,
        processName: _convertProcessNameLower(widget.processName),
        family: selectedFamily == 'All' ? '' : selectedFamily,
      );

      if (mounted) {
        setState(() {
          outputData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _convertProcessNameLower(String process) {
    const mapping = {
      'Molding': 'mold',
      'Tufting': 'tuft',
      'Blistering': 'blister',
    };
    return mapping[process] ?? process.toLowerCase();
  }

  String _convertNameL(String process) {
    final mapping = {
      'Mold': AppLocalizations.of(context)!.mold,
      'Tuft': AppLocalizations.of(context)!.tuft,
      'Blister': AppLocalizations.of(context)!.blister,
    };
    return mapping[process] ?? process;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 15,
              right: 15,
              bottom: 8,
            ),
            width: double.infinity,
            color: const Color.fromARGB(255, 247, 245, 245),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${_convertNameL(widget.processName)} - ${AppLocalizations.of(context)!.outputreport}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 20 : 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: isTablet ? 30 : 26,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isTablet
                ? _buildTabletView(context)
                : _buildMobileView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletView(BuildContext context) {
    if (outputData == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 0,
            headingRowHeight: 40,
            dataRowHeight: 36,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF5F5F5)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
            dataTextStyle: const TextStyle(fontSize: 11, color: Colors.black87),
            border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1),
            columns: const [
              DataColumn(label: SizedBox(width: 80, child: Text('Mold ID'))),
              DataColumn(label: SizedBox(width: 120, child: Text('Family'))),
              DataColumn(label: SizedBox(width: 60, child: Text('Process'))),
              DataColumn(label: SizedBox(width: 60, child: Text('M.Cavity'))),
              DataColumn(label: SizedBox(width: 60, child: Text('A.Cavity'))),
              DataColumn(
                label: SizedBox(width: 80, child: Text('Capacity/hr')),
              ),
              DataColumn(label: SizedBox(width: 80, child: Text('Efficiency'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Cur.Cycle'))),
              DataColumn(label: SizedBox(width: 60, child: Text('Target'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Up.Limit'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Lo.Limit'))),
              DataColumn(label: SizedBox(width: 80, child: Text('Lost pcs'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Lost time'))),
            ],
            rows: _buildDataRows(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    final groupedData = _getGroupedMachineData();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Output Summary
        _buildOutputSummary(),
        const SizedBox(height: 4),

        // Filter Section
        _buildFilterSection(),
        const SizedBox(height: 8),

        // Data grouped by family
        if (outputData != null && outputData!.details.isNotEmpty)
          ...groupedData.entries.map((familyGroup) {
            final familyName = familyGroup.key;
            final items = familyGroup.value;
            final subTotal = _calculateSubTotal(items);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  // Family header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          familyName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.subtotal}: ${formatNumber(subTotal)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Items in family
                  ...items.map((item) => _buildMachineCard(item)),
                  const SizedBox(height: 8),
                ],
              ),
            );
          })
        else
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No data available')),
          ),
      ],
    );
  }

  Widget _buildOutputSummary() {
    if (outputData == null) return const SizedBox.shrink();

    final summary = outputData!.summary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.outputsummary,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Shift headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "07:00 ~ 19:00",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "19:00 ~ 07:00",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.total,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // Output row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColumn(
                AppLocalizations.of(context)!.outputPcs,
                // summary.dayOutput.toStringAsFixed(0),
                NumberFormat('#,###').format(summary.dayOutput),
              ),
              _buildColumn(
                AppLocalizations.of(context)!.outputPcs,
                // summary.nightOutput.toStringAsFixed(0),
                NumberFormat('#,###').format(summary.nightOutput),
              ),
              _buildColumn(
                AppLocalizations.of(context)!.outputPcs,
                // summary.totalOutput.toStringAsFixed(0),
                NumberFormat('#,###').format(summary.totalOutput),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lost row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColumn(
                AppLocalizations.of(context)!.lostpcs,
                "${summary.dayLost.toStringAsFixed(0)} (${summary.dayLossPercent.toStringAsFixed(1)}%)",
                isRed: true,
              ),
              _buildColumn(
                AppLocalizations.of(context)!.lostpcs,
                "${summary.nightLost.toStringAsFixed(0)} (${summary.nightLossPercent.toStringAsFixed(1)}%)",
                isRed: true,
              ),
              _buildColumn(
                AppLocalizations.of(context)!.lostpcs,
                "${summary.totalLost.toStringAsFixed(0)} (${summary.totalLossPercent.toStringAsFixed(1)}%)",
                isRed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date pickers
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  AppLocalizations.of(context)!.fromdateline,
                  fromDate,
                  _selectFromDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDatePicker(
                  AppLocalizations.of(context)!.todateline,
                  toDate,
                  _selectToDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Family selector and Search button
          Row(
            children: [
              Expanded(child: _buildFamilySelector()),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _performSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.search,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(BuildContext) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => onTap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                // Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                // const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                        : AppLocalizations.of(context)!.selectDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null ? Colors.grey[700] : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   AppLocalizations.of(context)!.family,
        //   style: TextStyle(
        //     fontSize: 12,
        //     fontWeight: FontWeight.w600,
        //     color: Colors.black87,
        //   ),
        // ),
        // const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFamily,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: familyList.map((String family) {
                  return DropdownMenuItem<String>(
                    value: family,
                    child: Text(
                      family == AppLocalizations.of(context)!.all
                          ? AppLocalizations.of(context)!.allfamilies
                          : family,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedFamily = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMachineCard(MachineDetailOutput item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${item.machineId} | ${item.process}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      170,
                      181,
                      170,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${AppLocalizations.of(context)!.output}: ${formatNumber(item.output)}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info grid 1
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.moldca,
                    item.moldCavity.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.actca,
                    item.moldCavity.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.capacity,
                    // item.capacity.toString(),
                    formatNumber(item.capacity),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.efficiency,
                    '${item.efficiency.toStringAsFixed(2)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info grid 2
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.curcyc,
                    item.currentCycle.toStringAsFixed(2),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.target,
                    item.target.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.upperlimit,
                    item.upperLimit.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.lowerlimit,
                    item.lowerLimit.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(String label, String value, {bool isRed = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    if (outputData == null) return [];

    return outputData!.details.map((item) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 80,
              child: Text(item.machineId, style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Text(item.family, style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(item.process, style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                item.moldCavity.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text('-', style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                item.capacity.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                '${item.efficiency.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item.currentCycle.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                item.target.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item.upperLimit.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item.lowerLimit.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                item.totalLostPcs.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item.lostTime.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Map<String, List<MachineDetailOutput>> _getGroupedMachineData() {
    if (outputData == null) return {};

    final Map<String, List<MachineDetailOutput>> groupedData = {};

    for (var item in outputData!.details) {
      if (!groupedData.containsKey(item.family)) {
        groupedData[item.family] = [];
      }
      groupedData[item.family]!.add(item);
    }

    return groupedData;
  }

  double _calculateSubTotal(List<MachineDetailOutput> items) {
    return items.fold(0.0, (sum, item) => sum + item.output);
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(fromDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          fromDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(toDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          toDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _performSearch() {
    if (fromDate != null && toDate != null) {
      _loadOutputData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both From and To dates'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
