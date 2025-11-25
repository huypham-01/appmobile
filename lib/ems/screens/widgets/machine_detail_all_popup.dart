import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../data/models/machine_model.dart';

class MachineDetailAllPopup extends StatefulWidget {
  final String processName;
  final String status;
  const MachineDetailAllPopup({
    super.key,
    required this.processName,
    required this.status,
  });

  @override
  State<MachineDetailAllPopup> createState() => _MachineDetailAllPopupState();
}

class _MachineDetailAllPopupState extends State<MachineDetailAllPopup> {
  late Future<List<Machine>> _machineDataFuture;

  @override
  void initState() {
    super.initState();
    _machineDataFuture = EmsApiService.fetchMachineStatus(
      _convertProcessNameLower(widget.processName),
      widget.status,
    );
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
                    "${_convertNameL(widget.processName)} ${AppLocalizations.of(context)!.machinedetails} – ${_convertProcessStatus(widget.status)}",
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

          // Data Table với responsive design
          Expanded(
            child: FutureBuilder<List<Machine>>(
              future: _machineDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _machineDataFuture =
                                  EmsApiService.fetchMachineStatus(
                                    _convertProcessNameLower(
                                      widget.processName,
                                    ),
                                    widget.status,
                                  );
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                final machines = snapshot.data!;
                return isTablet
                    ? _buildTabletView(context, machines)
                    : _buildMobileView(context, machines);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _convertProcessStatus(String process) {
    final mapping = {
      'total': AppLocalizations.of(context)!.all,
      'running': AppLocalizations.of(context)!.running,
      'warning': AppLocalizations.of(context)!.warning,
    };
    return mapping[process] ?? process;
  }

  String _convertNameL(String process) {
    final mapping = {
      'Mold': AppLocalizations.of(context)!.mold,
      'Tuft': AppLocalizations.of(context)!.tuft,
      'Blister': AppLocalizations.of(context)!.blister,
    };
    return mapping[process] ?? process;
  }

  String _convertProcessNameLower(String process) {
    const mapping = {
      'Molding': 'mold',
      'Tufting': 'tuft',
      'Blistering': 'blister',
    };
    return mapping[process] ?? process.toLowerCase();
  }

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 90) return Colors.green;
    if (efficiency >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTabletView(BuildContext context, List<Machine> machines) {
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
            rows: _buildDataRows(machines),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, List<Machine> machines) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        final efficiencyColor = _getEfficiencyColor(machine.efficiency);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${machine.moldId} - ${machine.family}",
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
                        machine.process ?? 'N/A',
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

                // Grid info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.moldca,
                        machine.moldCavity.toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.actca,
                        machine.actualCavity.toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.capacityhr,
                        // machine.capacityPerHr.toStringAsFixed(2),
                        formatNumber(machine.capacityPerHr),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.efficiency,
                        '${machine.efficiency.toStringAsFixed(2)}%',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.currentcycle,
                        machine.currentCycle.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Lost info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.target,
                        machine.target.toStringAsFixed(2),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.upperlimit,
                        machine.upperLimit.toStringAsFixed(2),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.lowerlimit,
                        machine.lowerLimit.toStringAsFixed(2),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.lostPcs,
                        // machine.totalLostPcs.toStringAsFixed(0),
                        formatNumber(machine.totalLostPcs)
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.losttime,
                        '${machine.lostTime.toStringAsFixed(0)} mins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  List<DataRow> _buildDataRows(List<Machine> machines) {
    return machines.map((machine) {
      final efficiencyColor = _getEfficiencyColor(machine.efficiency);

      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 80,
              child: Text(machine.moldId, style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Text(machine.family, style: const TextStyle(fontSize: 10)),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                machine.process ?? 'N/A',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                machine.moldCavity.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                machine.actualCavity.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                machine.capacityPerHr.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                '${machine.efficiency.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: efficiencyColor,
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
                machine.currentCycle.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 60,
              child: Text(
                machine.target.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                machine.upperLimit.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                machine.lowerLimit.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                machine.totalLostPcs.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 70,
              child: Text(
                '${machine.lostTime.toStringAsFixed(0)} mins',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
