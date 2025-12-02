import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../data/models/machine_model.dart';

// Giả sử bạn đã import model từ file model của bạn
// import 'path_to_your_model/detail_machine_response.dart';

class MachineDetailEfficiencyPopup extends StatefulWidget {
  final String processName;
  final String keyWork;

  const MachineDetailEfficiencyPopup({
    super.key,
    required this.processName,
    required this.keyWork,
  });

  @override
  State<MachineDetailEfficiencyPopup> createState() =>
      _MachineDetailEfficiencyPopupState();
}

enum SortOption {
  moldId,
  family,
  process,
  efficiency,
  capacity,
  lostPcs,
  lostTime,
  output,
}

enum SortDirection { ascending, descending }

class _MachineDetailEfficiencyPopupState
    extends State<MachineDetailEfficiencyPopup> {
  DateTime? fromDate;
  DateTime? toDate;
  late String processName;
  late String keyWork;

  SortOption currentSortOption = SortOption.efficiency;
  SortDirection currentSortDirection = SortDirection.ascending;
  bool isSortExpanded = false;

  List<Map<String, dynamic>> machineData = [];
  DetailMachineResponse? apiResponse;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    processName = widget.processName;
    keyWork = widget.keyWork;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (keyWork == 'day') {
      fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 7, 0);
      toDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 19, 0);
    } else if (keyWork == 'night') {
      fromDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        19,
        0,
      );
      toDate = DateTime(now.year, now.month, now.day, 7, 0);
    } else if (keyWork == 'average') {
      fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 7, 0);
      toDate = DateTime(now.year, now.month, now.day, 7, 0);
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final from = fromDate ?? DateTime.now();
      final to = toDate ?? DateTime.now();
      final response = await EmsApiService.fetchMachineEfficiency(
        from,
        to,
        _convertProcessNameLower(processName),
      );

      if (response != null) {
        setState(() {
          apiResponse = response;
          machineData = _convertToMapList(response.details);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error';
        isLoading = false;
      });
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

  List<Map<String, dynamic>> _convertToMapList(List<DetailMachine> details) {
    return details.map((machine) {
      final efficiency = machine.efficiency ?? 0.0;
      Color efficiencyColor;

      if (efficiency > 0) {
        efficiencyColor = Colors.blue;
      } else {
        efficiencyColor = Colors.black87;
      }

      return {
        'moldId': machine.machineId,
        'family': machine.family,
        'process': machine.process ?? 'N/A',
        'moldCavity': machine.moldCavity?.toString() ?? '0',
        'output': machine.output?.toInt(),
        'actualCavity': machine.actualCavity.toString(),
        'capacity': machine.capacity?.toDouble() ?? 0.00,
        'efficiency': '${efficiency.toStringAsFixed(2)}%',
        'currentCycle': machine.currentCycle.toStringAsFixed(2),
        'target': machine.target?.toStringAsFixed(2) ?? '0.00',
        'upperLimit': machine.upperLimit?.toStringAsFixed(2) ?? '0.00',
        'lowerLimit': machine.lowerLimit?.toStringAsFixed(2) ?? '0.00',
        'totalLostPcs': machine.totalLostPcs?.toDouble(),
        'lostTime': '${formatNumber(machine.lostTime)} mins',
        'efficiencyColor': efficiencyColor,
        'efficiencyValue': efficiency,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                    "${_convertNameL(widget.processName)} - ${AppLocalizations.of(context)!.efficiencyreport}",
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

          // Content - Show loading, error, or data
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : isTablet
                ? _buildTabletView(context)
                : _buildMobileView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletView(BuildContext context) {
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
              DataColumn(label: SizedBox(width: 60, child: Text('Output'))),
              DataColumn(label: SizedBox(width: 80, child: Text('Efficiency'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Cur.Cycle'))),
              DataColumn(label: SizedBox(width: 60, child: Text('Target'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Up.Limit'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Lo.Limit'))),
              DataColumn(label: SizedBox(width: 80, child: Text('Lost pcs'))),
              DataColumn(label: SizedBox(width: 70, child: Text('Lost time'))),
            ],
            rows: _buildDataRows(isTablet: true),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    final data = _getSortedData();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Summary containers
        if (apiResponse != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryColumn(
                  AppLocalizations.of(context)!.molding,
                  apiResponse!.summaryAll.mold.average,
                ),
                _buildSummaryColumn(
                  AppLocalizations.of(context)!.tufting,
                  apiResponse!.summaryAll.tuft.average,
                ),
                _buildSummaryColumn(
                  AppLocalizations.of(context)!.blistering,
                  apiResponse!.summaryAll.blister.average,
                ),
              ],
            ),
          ),

        // Date filters and search
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      AppLocalizations.of(context)!.fromdateline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectFromDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fromDate != null
                                    ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year} ${fromDate!.hour.toString().padLeft(2, '0')}:${fromDate!.minute.toString().padLeft(2, '0')}'
                                    : AppLocalizations.of(context)!.selectDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: fromDate != null
                                      ? Colors.black87
                                      : Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      AppLocalizations.of(context)!.todateline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectToDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                toDate != null
                                    ? '${toDate!.day}/${toDate!.month}/${toDate!.year} ${toDate!.hour.toString().padLeft(2, '0')}:${toDate!.minute.toString().padLeft(2, '0')}'
                                    : AppLocalizations.of(context)!.selectDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: toDate != null
                                      ? Colors.black87
                                      : Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _performSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.search,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
        ),

        // Sort options
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSortExpanded = !isSortExpanded;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.sortoption,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isSortExpanded)
                      Expanded(
                        child: Text(
                          '(${_getSortDisplayName(currentSortOption)} ${currentSortDirection == SortDirection.ascending ? '↑' : '↓'})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    if (isSortExpanded) ...[
                      GestureDetector(
                        onTap: _resetSort,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.reset,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      isSortExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 22,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              if (isSortExpanded) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip(
                      AppLocalizations.of(context)!.machineid,
                      SortOption.moldId,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.family,
                      SortOption.family,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.process,
                      SortOption.process,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.efficiency,
                      SortOption.efficiency,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.capacity,
                      SortOption.capacity,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.lostPcs,
                      SortOption.lostPcs,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.losttime,
                      SortOption.lostTime,
                    ),
                    _buildSortChip(
                      AppLocalizations.of(context)!.output,
                      SortOption.output,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Data cards
        ...data.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${item['moldId']} | ${item['family']}",
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['process'],
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.moldca,
                          item['moldCavity'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.actca,
                          item['actualCavity'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.capacity,

                          // item['capacity'],
                          formatNumber(item['capacity']),
                        ),
                      ),

                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.outputPcs,
                          // item['output'],
                          formatNumber(item['output']),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.efficiency,
                          item['efficiency'],
                          color: item['efficiencyColor'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.curcyc,
                          item['currentCycle'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.target,
                          item['target'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.upperlimit,
                          item['upperLimit'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.lowerlimit,
                          item['lowerLimit'],
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.lostPcs,
                          // item['totalLostPcs'].toString(),
                          formatNumber(item['totalLostPcs']),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          AppLocalizations.of(context)!.losttime,
                          item['lostTime'],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryColumn(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CircularProgressIndicator(
                    value: (value / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 9,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${value.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //TODO
  Widget _buildSortChip(String label, SortOption option) {
    final isSelected = currentSortOption == option;
    final isAscending = currentSortDirection == SortDirection.ascending;

    return GestureDetector(
      onTap: () => _onSortOptionTapped(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSortDisplayName(SortOption option) {
    switch (option) {
      case SortOption.moldId:
        return AppLocalizations.of(context)!.machineid;
      case SortOption.family:
        return AppLocalizations.of(context)!.family;
      case SortOption.process:
        return AppLocalizations.of(context)!.process;
      case SortOption.efficiency:
        return AppLocalizations.of(context)!.efficiency;
      case SortOption.output:
        return AppLocalizations.of(context)!.output;
      case SortOption.capacity:
        return AppLocalizations.of(context)!.capacity;
      case SortOption.lostPcs:
        return AppLocalizations.of(context)!.lostPcs;
      case SortOption.lostTime:
        return AppLocalizations.of(context)!.losttime;
    }
  }

  void _onSortOptionTapped(SortOption option) {
    setState(() {
      if (currentSortOption == option) {
        currentSortDirection = currentSortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending;
        // isSortExpanded == true;
      } else {
        currentSortOption = option;
        currentSortDirection = SortDirection.ascending;
      }
    });
  }

  void _resetSort() {
    setState(() {
      currentSortOption = SortOption.moldId;
      currentSortDirection = SortDirection.ascending;
    });
  }

  List<Map<String, dynamic>> _getSortedData() {
    final data = List<Map<String, dynamic>>.from(machineData);

    data.sort((a, b) {
      dynamic valueA, valueB;

      switch (currentSortOption) {
        case SortOption.moldId:
          valueA = a['moldId'];
          valueB = b['moldId'];
          break;
        case SortOption.family:
          valueA = a['family'];
          valueB = b['family'];
          break;
        case SortOption.process:
          valueA = a['process'];
          valueB = b['process'];
          break;
        case SortOption.output:
          valueA = int.tryParse(a['output']) ?? 0;
          valueB = int.tryParse(b['output']) ?? 0;
          break;
        case SortOption.efficiency:
          valueA = a['efficiencyValue'];
          valueB = b['efficiencyValue'];
          break;
        case SortOption.capacity:
          valueA = double.tryParse(a['capacity'].toString()) ?? 0.0;
          valueB = double.tryParse(b['capacity'].toString()) ?? 0.0;
          break;
        case SortOption.lostPcs:
          valueA = double.tryParse(a['totalLostPcs'].toString()) ?? 0.0;
          valueB = double.tryParse(b['totalLostPcs'].toString()) ?? 0.0;
          break;
        case SortOption.lostTime:
          valueA =
              double.tryParse(
                (a['lostTime'] as String).replaceAll(' min', ''),
              ) ??
              0.0;
          valueB =
              double.tryParse(
                (b['lostTime'] as String).replaceAll(' min', ''),
              ) ??
              0.0;
          break;
      }

      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.toLowerCase().compareTo(valueB.toLowerCase());
      } else if (valueA is num && valueB is num) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = valueA.toString().compareTo(valueB.toString());
      }

      return currentSortDirection == SortDirection.ascending
          ? comparison
          : -comparison;
    });

    return data;
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final initialDate =
        fromDate ?? DateTime.now().subtract(const Duration(days: 1));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      TimeOfDay initialTime = fromDate != null
          ? TimeOfDay.fromDateTime(fromDate!)
          : const TimeOfDay(hour: 7, minute: 0);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      final selectedTime = pickedTime ?? const TimeOfDay(hour: 7, minute: 0);
      setState(() {
        fromDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final initialDate =
        toDate ?? DateTime.now().subtract(const Duration(days: 1));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      TimeOfDay initialTime = toDate != null
          ? TimeOfDay.fromDateTime(toDate!)
          : const TimeOfDay(hour: 19, minute: 0);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      final selectedTime = pickedTime ?? const TimeOfDay(hour: 19, minute: 0);
      setState(() {
        toDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  void _performSearch() {
    if (fromDate != null && toDate != null) {
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both From and To dates'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildInfoItem(String label, String value, {Color? color}) {
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
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildDataRows({bool isTablet = false}) {
    final data = _getSortedData();

    return data.map((item) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 80,
              child: Text(item['moldId'], style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Text(item['family'], style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                item['process'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                item['moldCavity'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                item['actualCavity'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                item['capacity'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(item['output'], style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                item['efficiency'],
                style: TextStyle(
                  color: item['efficiencyColor'],
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item['currentCycle'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(item['target'], style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item['upperLimit'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item['lowerLimit'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                item['totalLostPcs'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                item['lostTime'],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
