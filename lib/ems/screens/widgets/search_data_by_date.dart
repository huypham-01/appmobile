import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/data/models/machine_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class SearchDataByDate extends StatefulWidget {
  final String deviceId;
  final String keyy;
  const SearchDataByDate({
    super.key,
    required this.deviceId,
    required this.keyy,
  });

  @override
  State<SearchDataByDate> createState() => _SearchDataByDateState();
}

class _SearchDataByDateState extends State<SearchDataByDate> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  bool isLoading = false;
  int? sortColumnIndex;
  bool sortAscending = true;

  int totalOutput = 0;
  double average = 0;
  bool hasSearched = false;
  List<MachineRecord> tableData = [];

  // Date picker
  Future<void> _pickDateTime(TextEditingController controller) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    final TimeOfDay finalTime =
        pickedTime ?? const TimeOfDay(hour: 12, minute: 0);

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      finalTime.hour,
      finalTime.minute,
    );

    controller.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }

  // Validate date inputs
  bool _validateDatesOnly() {
    if (fromDateController.text.isEmpty || toDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both From and To dates')),
      );
      return false;
    }

    try {
      final DateTime fromDate = DateTime.parse(fromDateController.text);
      final DateTime toDate = DateTime.parse(toDateController.text);

      if (fromDate.isAfter(toDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date range: From must be before To'),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid date format')));
      return false;
    }
    return true;
  }

  // Calculate statistics
  void _calculateStats() {
    if (tableData.isEmpty) {
      totalOutput = 0;
      average = 0;
    } else {
      totalOutput = tableData.fold(0, (sum, record) => sum + record.output);
      double sumCycle = tableData.fold(
        0.0,
        (sum, record) => sum + record.cycleTime,
      );
      average = sumCycle / tableData.length;
    }
  }

  // Sorting function
  void _sort<T extends Comparable<T>>(
    T Function(MachineRecord) getField,
    int columnIndex,
  ) {
    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = true;
      }
      tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    });
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

  void _sortByDateTime() {
    _sort<String>((record) => record.datetime.toString(), 0);
  }

  void _sortByCavities() {
    _sort<num>((record) => record.cavities!, 1);
  }

  void _sortByPcs() {
    _sort<num>((record) => record.cavities!, 1);
  }

  void _sortByCycle() {
    _sort<num>((record) => record.cycleTime, 2);
  }

  void _sortByOutput() {
    _sort<num>((record) => record.output, 3);
  }

  Widget _getSortIcon(int columnIndex) {
    if (sortColumnIndex != columnIndex) {
      return Icon(Icons.unfold_more, size: 14, color: Colors.grey.shade600);
    }
    return Icon(
      sortAscending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      size: 16,
      color: Colors.teal,
    );
  }

  // Fetch data from API
  Future<void> _fetchData() async {
    if (!_validateDatesOnly()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final records = await EmsApiService.fetchMachineRecords(
        deviceId: widget.deviceId,
        from: fromDateController.text,
        to: toDateController.text,
      );

      setState(() {
        tableData = records;
        hasSearched = true;
        _calculateStats();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Found ${records.length} records',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxWidth < 600;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Date Selection with Buttons ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: isSmallScreen
                      ? Column(
                          children: [
                            _buildDateRowWithButtons(
                              AppLocalizations.of(context)!.fromdateline,
                              fromDateController,
                              true,
                            ),
                            const SizedBox(height: 8),
                            _buildDateRowWithButtons(
                              AppLocalizations.of(context)!.todateline,
                              toDateController,
                              false,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildDateRowWithButtons(
                                AppLocalizations.of(context)!.fromdateline,
                                fromDateController,
                                true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateRowWithButtons(
                                AppLocalizations.of(context)!.todateline,
                                toDateController,
                                false,
                              ),
                            ),
                          ],
                        ),
                ),
                const Divider(height: 24, thickness: 1),

                /// --- Statistics ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      context,
                      AppLocalizations.of(context)!.totaloutput,
                      _formatNumber(totalOutput.toDouble()),
                      Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    if (widget.keyy == "mold")
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.averagecycle,
                        average.toStringAsFixed(2),
                        Colors.black87,
                      ),
                    if (widget.keyy == "tuft")
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.averageOutput,
                        average.toStringAsFixed(2),
                        Colors.black87,
                      ),
                    if (widget.keyy == "blister")
                      _buildStatCard(
                        context,
                        AppLocalizations.of(context)!.averagecycle,
                        average.toStringAsFixed(2),
                        Colors.black87,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                /// --- Data Table ---
                SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        color: const Color.fromARGB(255, 225, 230, 230),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 6,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AppLocalizations.of(context)!.dateTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (widget.keyy == 'mold')
                                Expanded(
                                  child: InkWell(
                                    onTap: _sortByCavities,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.capacity,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        _getSortIcon(1),
                                      ],
                                    ),
                                  ),
                                ),
                              if (widget.keyy == 'blister')
                                Expanded(
                                  child: InkWell(
                                    onTap: _sortByPcs,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(context)!.pcs,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        _getSortIcon(1),
                                      ],
                                    ),
                                  ),
                                ),
                              if (widget.keyy != 'tuft')
                                Expanded(
                                  child: InkWell(
                                    onTap: _sortByCycle,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(context)!.cycle,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        _getSortIcon(2),
                                      ],
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: InkWell(
                                  onTap: _sortByOutput,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.outputPcs,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      _getSortIcon(3),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // BODY
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (!hasSearched) {
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!.nodata,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            } else if (tableData.isEmpty) {
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noDataFound,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: tableData.length,
                                itemBuilder: (context, index) {
                                  final record = tableData[index];
                                  return Container(
                                    color: index % 2 == 0
                                        ? Colors.grey.shade50
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                        horizontal: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              DateFormat(
                                                'yyyy-MM-dd HH:mm:ss',
                                              ).format(record.datetime),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          if (widget.keyy == "mold")
                                            Expanded(
                                              child: Text(
                                                record.cavities.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          if (widget.keyy == "blister")
                                            Expanded(
                                              child: Text(
                                                record.brushesperCycle
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          if (widget.keyy != "tuft")
                                            Expanded(
                                              child: Text(
                                                record.cycleTime
                                                    .toStringAsFixed(2),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            child: Text(
                                              record.output.toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
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

  Widget _buildDateRowWithButtons(
    String label,
    TextEditingController dateController,
    bool isFromRow,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _buildCompactDateField(
            dateController,
            AppLocalizations.of(context)!.selectDate,
            Icons.date_range,
            () => _pickDateTime(dateController),
          ),
        ),
        const SizedBox(width: 8),
        if (isFromRow)
          _buildCompactButton(
            icon: Icons.refresh,
            color: const Color.fromARGB(255, 86, 163, 194),
            isOutlined: true,
            onPressed: () {
              fromDateController.clear();
              toDateController.clear();
              setState(() {
                tableData = [];
                hasSearched = false;
                totalOutput = 0;
                average = 0;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Dates reset')));
            },
          )
        else
          _buildCompactButton(
            icon: Icons.search,

            color: const Color.fromARGB(255, 82, 147, 203),
            isOutlined: false,
            onPressed: isLoading ? null : _fetchData,
          ),
      ],
    );
  }

  Widget _buildCompactButton({
    required IconData icon,

    required Color color,
    required bool isOutlined,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      width: 70,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 24)],
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(icon, size: 24)],
                    ),
            ),
    );
  }

  Widget _buildCompactDateField(
    TextEditingController controller,
    String hint,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 32,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          prefixIcon: Icon(icon, size: 16, color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
