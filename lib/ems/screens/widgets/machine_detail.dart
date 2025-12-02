import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile/ems/screens/widgets/create_action_dialog.dart';
import 'package:mobile/utils/constants.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../data/models/machine_model.dart';
import 'search_data_by_date.dart';

class MachineDetail extends StatefulWidget {
  final Machine machine;
  final String keyw;
  const MachineDetail({super.key, required this.machine, required this.keyw});

  @override
  State<MachineDetail> createState() => _MachineDetailState();
}

class _MachineDetailState extends State<MachineDetail> {
  String selectedTimeFrame = 'Today';

  Map<String, List<HourlyDataModel>> hourlyDataByDate = {};
  bool isLoading = true;
  bool canCreateAction = false;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllHourlyData();
    _loadPermissions();
  }

  void _loadPermissions() async {
    canCreateAction = await PermissionHelper.has("create.action.ems");
    setState(() {});
  }

  void _scrollToTop() {
    if (_verticalScrollController.hasClients) {
      _verticalScrollController.jumpTo(0);
    }
  }

  String _getDateForTimeFrame(String timeFrame) {
    final today = DateTime.now();
    DateTime targetDate;

    if (timeFrame == 'Today') {
      targetDate = today;
    } else if (timeFrame == 'Yesterday') {
      targetDate = today.subtract(const Duration(days: 1));
    } else {
      // '2 day ago'
      targetDate = today.subtract(const Duration(days: 2));
    }

    return '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchAllHourlyData() async {
    try {
      setState(() => isLoading = true);

      const List<String> timeFrames = ['2 day ago', 'Yesterday', 'Today'];

      for (String timeFrame in timeFrames) {
        await _fetchHourlyDataForDate(widget.machine.moldId, timeFrame);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _fetchHourlyDataForDate(
    String deviceId,
    String timeFrame,
  ) async {
    try {
      final reportDate = _getDateForTimeFrame(timeFrame);
      final url = Uri.parse(
        '$baseUrl/ems/api.php?action=get_hourly_report&device_id=$deviceId&report_date=$reportDate',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List hourlyList = data['hourly_data'] ?? [];

        setState(() {
          hourlyDataByDate[timeFrame] = hourlyList
              .map((e) => HourlyDataModel.fromJson(e))
              .toList();
        });
      } else {
        throw Exception('Failed to load data for $timeFrame');
      }
    } catch (e) {
      print('Error fetching data for $timeFrame: $e');
    }
  }

  // New method to compute daily totals based on selectedTimeFrame
  (double totalLost, double totalIdle) _getDailyTotals() {
    if (isLoading) {
      return (0, 0);
    }

    List<HourlyDataModel> currentData =
        hourlyDataByDate[selectedTimeFrame] ?? [];

    double totalLost = 0;
    double totalIdle = 0;

    for (int i = 0; i < 24; i++) {
      int expectedHour = (7 + i) % 24;
      final dataPoint = currentData.firstWhere(
        (item) => item.hour == expectedHour,
        orElse: () => HourlyDataModel(
          hour: expectedHour,
          avgEfficiency: 0,
          totalOutput: 0,
          totalLossPcs: 0,
          totalIdleBreakdown: 0,
        ),
      );

      totalLost += dataPoint.totalLossPcs;
      totalIdle += dataPoint.totalIdleBreakdown;
    }

    return (totalLost, totalIdle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "${widget.machine.moldId} - ${widget.machine.family}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,

        actions: [
          if (canCreateAction && !useMock) // 👈 Chỉ hiện khi có quyền
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.addAction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) =>
                        CreateActionDialog(device: widget.machine),
                  );
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMachineInfoCard(),

            const SizedBox(height: 4),
            _buildHourlyEfficiency(),
            const SizedBox(height: 4),
            _buildLossReportTable(),
            const SizedBox(height: 4),

            SearchDataByDate(
              deviceId: widget.machine.moldId,
              keyy: widget.keyw,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 227, 223, 222),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.black, size: 24),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.information,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final value = widget.machine;
    final bool isCavity = value.moldCavity != value.actualCavity;
    final bool isUpp =
        (value.upperLimit != 999.9) && (value.currentCycle > value.upperLimit);
    final bool isLow =
        (value.lowerLimit != 999.9) && (value.currentCycle < value.lowerLimit);

    // Get dynamic totals
    final (totalLost, totalIdle) = _getDailyTotals();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(
                    AppLocalizations.of(context)!.machineid,
                    value.moldId,
                    false,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.process,
                    value.process ?? "N/A",
                    false,
                  ),
                  const SizedBox(height: 2),

                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 2),

                  _buildInfoItem(
                    AppLocalizations.of(context)!.moldcavity,
                    value.moldCavity.toString(),
                    isCavity,
                  ),
                  const SizedBox(height: 2),

                  _buildInfoItem(
                    AppLocalizations.of(context)!.actualcavity,
                    value.actualCavity.toString(),
                    isCavity,
                  ),
                  const SizedBox(height: 2),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.capacity,
                    "${_formatNumber(value.capacityPerHr)} pcs/h",
                    false,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.efficiency,
                    '${_formatNumber(value.efficiency)}%',
                    false,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.effrequirement,
                    '${_formatNumber(value.efficiencylowerlimit)}%',
                    false,
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 24,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(
                    AppLocalizations.of(context)!.currentcycle,
                    '${_formatNumber(value.currentCycle)} ${_formatUnit(widget.keyw)}',
                    isUpp || isLow,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.target,
                    value.target == 999.9 ? "N/A" : _formatNumber(value.target),
                    false,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.upperlimit,
                    value.upperLimit == 999.9
                        ? "N/A"
                        : _formatNumber(value.upperLimit),
                    isUpp,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.lowerlimit,
                    value.lowerLimit == 999.9
                        ? "N/A"
                        : _formatNumber(value.lowerLimit),
                    isLow,
                  ),
                  const SizedBox(height: 2),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.totallostpcs,
                    _formatNumber(totalLost),
                    false,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.losttime,
                    '${totalIdle.round()} min',
                    false,
                  ),
                  const SizedBox(height: 2),
                  if (widget.keyw == "mold")
                    _buildInfoItem(
                      AppLocalizations.of(context)!.shotcount,
                      '${_formatNumber(value.cavityCount!)} shot',
                      false,
                    ),
                  if (widget.keyw == "tuft")
                    _buildInfoItem(
                      AppLocalizations.of(context)!.totalrpm,
                      '${_formatNumber(value.totalrpm!)} cycle',
                      false,
                    ),
                  if (widget.keyw == "blister")
                    _buildInfoItem(
                      AppLocalizations.of(context)!.totalcycle,
                      '${_formatNumber(value.totalcycle!)} cycle',
                      false,
                    ),
                  const SizedBox(height: 2),
                  _buildInfoItem(
                    AppLocalizations.of(context)!.totalcount,
                    '${_formatNumber(value.totalCount!)} pcs',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isErr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isErr ? Colors.red : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyEfficiency() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 227, 223, 222),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.assessment, color: Colors.black, size: 24),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.hourlyefficiency,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildEfficiencyChart(),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChart() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<HourlyDataModel> currentData =
        hourlyDataByDate[selectedTimeFrame] ?? [];

    // Calculate dynamic maxY
    double maxOutput = 0;
    for (var item in currentData) {
      if (item.totalOutput > maxOutput) {
        maxOutput = item.totalOutput;
      }
    }
    double maxY = maxOutput > 0 ? (maxOutput / 100).ceil() * 100 : 100;

    // Calculate tick intervals
    const int numTicks = 5;
    double tickInterval = maxY / numTicks;
    const double percentInterval = 20;
    double rightInterval = (percentInterval / 100) * maxY;

    List<BarChartGroupData> barGroups = [];
    List<FlSpot> efficiencySpots = [];
    List<FlSpot> requirementSpots = [];

    for (int i = 0; i < 24; i++) {
      int expectedHour = (7 + i) % 24;
      final dataPoint = currentData.firstWhere(
        (item) => item.hour == expectedHour,
        orElse: () => HourlyDataModel(
          hour: expectedHour,
          avgEfficiency: 0,
          totalOutput: 0,
          totalLossPcs: 0,
          totalIdleBreakdown: 0,
        ),
      );

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dataPoint.totalOutput.toDouble(),
              color: Colors.lightBlue.withOpacity(0.7),
              width: 12,
            ),
          ],
        ),
      );

      double yEfficiency = _convertPercentToY(
        dataPoint.avgEfficiency.toDouble(),
        maxY,
      );
      efficiencySpots.add(FlSpot(i.toDouble(), yEfficiency));
      requirementSpots.add(FlSpot(i.toDouble(), _convertPercentToY(95, maxY)));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['2 day ago', 'Yesterday', 'Today'].map((timeFrame) {
              final isSelected = timeFrame == selectedTimeFrame;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedTimeFrame = timeFrame);
                      // Optional: Nếu có scroll cho chart container, thêm _scrollToTop() ở đây
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeFrame,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.black87,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String hour = _getHourLabel(groupIndex);
                          return BarTooltipItem(
                            '$hour\n${AppLocalizations.of(context)!.output} ${rod.toY.round()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: rightInterval,
                          getTitlesWidget: (value, meta) {
                            int percent = ((value / maxY) * 100).round();
                            if (percent % 20 == 0 || percent == 0) {
                              return Text(
                                '$percent%',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: tickInterval,
                          getTitlesWidget: (value, meta) {
                            if ((value / tickInterval).round() % 1 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 3 == 0) {
                              return Text(
                                _getHourLabel(value.toInt()),
                                style: const TextStyle(fontSize: 8),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: tickInterval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      ),
                    ),
                  ),
                ),
                // LineChart(
                //   LineChartData(
                //     gridData: FlGridData(show: false),
                //     titlesData: FlTitlesData(show: false),
                //     borderData: FlBorderData(show: false),
                //     lineBarsData: [
                //       LineChartBarData(
                //         spots: efficiencySpots,
                //         isCurved: false,
                //         color: Colors.red,
                //         barWidth: 2,
                //         dotData: FlDotData(
                //           show: true,
                //           getDotPainter: (spot, percent, barData, index) {
                //             if (_getOriginalEfficiency(spot.y, maxY) > 0) {
                //               return FlDotCirclePainter(
                //                 radius: 3,
                //                 color: Colors.red,
                //                 strokeWidth: 1,
                //                 strokeColor: Colors.white,
                //               );
                //             }
                //             return FlDotCirclePainter(
                //               radius: 0,
                //               color: Colors.transparent,
                //             );
                //           },
                //         ),
                //       ),
                //       LineChartBarData(
                //         spots: requirementSpots,
                //         isCurved: false,
                //         color: Colors.red.withOpacity(0.8),
                //         barWidth: 2,
                //         dashArray: const [5, 5],
                //         dotData: FlDotData(show: false),
                //       ),
                //     ],
                //     minY: 0,
                //     maxY: maxY,
                //     lineTouchData: LineTouchData(
                //       enabled: true,
                //       touchTooltipData: LineTouchTooltipData(
                //         getTooltipColor: (touchedSpot) => Colors.black87,
                //         getTooltipItems: (touchedSpots) {
                //           return touchedSpots.map((LineBarSpot touchedSpot) {
                //             String hour = _getHourLabel(touchedSpot.x.toInt());
                //             double efficiency = _getOriginalEfficiency(
                //               touchedSpot.y,
                //               maxY,
                //             );
                //             return LineTooltipItem(
                //               '$hour\nEfficiency: ${efficiency.toInt()}%',
                //               const TextStyle(
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 12,
                //               ),
                //             );
                //           }).toList();
                //         },
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                AppLocalizations.of(context)!.efficiency,
                Colors.red,
                false,
              ),
              _buildLegendItem(
                AppLocalizations.of(context)!.output,
                Colors.blue,
                false,
              ),
              _buildLegendItem(
                AppLocalizations.of(context)!.effrequirement,
                Colors.red,
                true,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  double _convertPercentToY(double percent, double maxY) =>
      (percent / 100) * maxY;

  double _getOriginalEfficiency(double y, double maxY) => (y / maxY) * 100;

  String _getHourLabel(int index) {
    int hour = (7 + index) % 24;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(color: color),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color),
                  size: const Size(20, 2),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLossReportTable() {
    if (isLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    List<HourlyDataModel> currentData =
        hourlyDataByDate[selectedTimeFrame] ?? [];

    // Reuse the computation
    final (totalLost, totalIdle) = _getDailyTotals();

    List<DataRow> rows = [];

    for (int i = 0; i < 24; i++) {
      int expectedHour = (7 + i) % 24;
      final dataPointFixed = currentData.firstWhere(
        (item) => item.hour == expectedHour,
        orElse: () => HourlyDataModel(
          hour: expectedHour,
          avgEfficiency: 0,
          totalOutput: 0,
          totalLossPcs: 0,
          totalIdleBreakdown: 0,
        ),
      );

      String timeLabel = _getHourLabel(i);
      String lostStr = dataPointFixed.totalLossPcs.round().toString();
      String idleStr = dataPointFixed.totalIdleBreakdown.round().toString();

      rows.add(_buildDataRow(timeLabel, lostStr, idleStr, false));
    }

    // Thêm hàng Total
    rows.add(
      _buildDataRow(
        AppLocalizations.of(context)!.total,
        totalLost.round().toString(),
        totalIdle.round().toString(),
        true,
      ),
    );

    // Scroll to top sau khi build (để luôn bắt đầu từ 07:00)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 227, 223, 222),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.report, color: Colors.black, size: 24),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.lossidletimereport,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.4, // Responsive height, khoảng 40% màn hình
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 45,
                  headingRowHeight: 35,
                  dataRowHeight: 28,
                  columns: [
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context)!.time,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context)!.lostPcs,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppLocalizations.of(context)!.idleBreakdown,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: rows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static DataRow _buildDataRow(
    String time,
    String lostPcs,
    String idle,
    bool isTotal,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            time,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
        DataCell(
          Text(
            lostPcs,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              idle,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  final formatter = NumberFormat('#,###'); // định dạng có dấu phẩy

  // Nếu là số nguyên, hiển thị không có phần thập phân
  if (value == value.roundToDouble()) {
    return formatter.format(value.toInt());
  } else {
    // Nếu có phần thập phân khác 0, hiển thị 1 chữ số thập phân
    // nhưng vẫn có dấu phẩy ngăn cách phần nghìn
    final formattedIntPart = formatter.format(value.truncate());
    final decimalPart = value.toStringAsFixed(1).split('.')[1];
    return '$formattedIntPart.$decimalPart';
  }
}

String _formatUnit(String keyy) {
  switch (keyy) {
    case "mold":
      return "s";
    case "tuft":
      return "pcs";
    case "blister":
      return "cycle";
    default:
      return "";
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 3;
    double dashSpace = 2;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
