///
///// Class để lưu thống kê
class TabStats {
  final int total;
  final int online;
  final int offline;
  final int flexible;
  final int warning;
  final int action;

  TabStats({
    this.total = 0,
    this.online = 0,
    this.offline = 0,
    this.flexible = 0,
    this.warning = 0,
    this.action = 0,
  });
}

class Machine {
  final String moldId;
  final String family;
  final String? process;
  final int moldCavity;
  final int actualCavity;
  final double capacityPerHr;
  final double efficiency;
  final double efficiencylowerlimit;
  final double currentCycle;
  final double? output;
  final double? rpm;
  final double? cycleCount;
  final double target;
  final double? bushPerCycle;
  final double? holePerBrush;
  final double upperLimit;
  final double lowerLimit;
  final double totalLostPcs;
  final double lostTime;
  final String status;
  final String? lastUpdated;
  final bool isFlex;
  final bool hasAction;
  final double? totalCount;
  final double? cavityCount;
  final double? totalrpm;
  final double? totalcycle;

  Machine({
    required this.moldId,
    required this.family,
    this.process,
    required this.moldCavity,
    required this.actualCavity,
    required this.capacityPerHr,
    required this.efficiency,
    required this.efficiencylowerlimit,
    required this.currentCycle,
    this.output,
    this.cycleCount,
    required this.target,
    this.bushPerCycle,
    this.holePerBrush,
    required this.upperLimit,
    required this.lowerLimit,
    this.rpm,
    required this.totalLostPcs,
    required this.lostTime,
    required this.status,
    this.lastUpdated,
    required this.hasAction,
    required this.isFlex,
    this.totalCount,
    this.cavityCount,
    this.totalrpm,
    this.totalcycle,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      moldId: json['mold_id']?.toString() ?? '',
      family: json['family'] ?? '',
      process: json['process'],
      moldCavity: json['mold_cavity'] is int
          ? json['mold_cavity']
          : int.tryParse(json['mold_cavity']?.toString() ?? ''),
      actualCavity: json['actual_cavity'] is int
          ? json['actual_cavity']
          : int.tryParse(json['actual_cavity']?.toString() ?? ''),
      capacityPerHr: (json['capacity_per_hr'] as num?)?.toDouble() ?? 0,
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0,
      efficiencylowerlimit:
          (json['efficiency_lower_limit'] as num?)?.toDouble() ?? 0,
      rpm: (json['rpm'] as num?)?.toDouble() ?? 0,
      currentCycle: (json['current_cycle'] as num?)?.toDouble() ?? 0,
      output: (json['output'] as num?)?.toDouble(),
      cycleCount: (json['cyclecount'] as num?)?.toDouble(),
      target: (json['target'] as num?)?.toDouble() ?? 999.9,
      bushPerCycle: (json['bush_per_cycle'] as num?)?.toDouble(),
      holePerBrush: (json['hole_per_brush'] as num?)?.toDouble(),
      upperLimit: (json['upper_limit'] as num?)?.toDouble() ?? 999.9,
      lowerLimit: (json['lower_limit'] as num?)?.toDouble() ?? 999.9,
      totalLostPcs: (json['total_lost_pcs'] as num?)?.toDouble() ?? 0,
      lostTime: (json['lost_time'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      lastUpdated: json['last_updated'],
      isFlex: json['is_flex'],
      hasAction: json['has_action'],
      totalCount: (json['total_count'] as num?)?.toDouble(),
      cavityCount: (json['total_count'] as num?)?.toDouble(),
      totalrpm: (json['total_rpm'] as num?)?.toDouble(),
      totalcycle: (json['total_cycle'] as num?)?.toDouble(),
    );
  }
}

class IssueModel {
  final int id;
  final String deviceId;
  final String title;
  final String issueType;
  final String desc;
  final String createdAt;
  final String createdByName;
  final String? dueDate;
  final String approvalStatus;
  final String status;
  final String plansDone;
  final int plansTotal;
  final String? plannedCompletionDate;
  final String statusAuto;
  List<ActionPlann> plans;

  IssueModel({
    required this.id,
    required this.deviceId,
    required this.title,
    required this.issueType,
    required this.desc,
    required this.createdAt,
    required this.createdByName,
    this.dueDate,
    required this.approvalStatus,
    required this.status,
    required this.plansDone,
    required this.plansTotal,
    this.plannedCompletionDate,
    required this.statusAuto,
    required this.plans,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      title: json['title'] ?? '',
      issueType: json['issue_type'] ?? '',
      desc: json['desc'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      dueDate: json['due_date'],
      approvalStatus: json['approval_status'] ?? '',
      status: json['status'] ?? '',
      plansDone: json['plans_done']?.toString() ?? '0',
      plansTotal: json['plans_total'] ?? 0,
      plannedCompletionDate: json['planned_completion_date'],
      statusAuto: json['status_auto'] ?? '',
      plans: [], // chỗ này bạn call thêm 1 API con nếu cần action plans
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'title': title,
      'issue_type': issueType,
      'desc': desc,
      'created_at': createdAt,
      'created_by_name': createdByName,
      'due_date': dueDate,
      'approval_status': approvalStatus,
      'status': status,
      'plans_done': plansDone,
      'plans_total': plansTotal,
      'planned_completion_date': plannedCompletionDate,
      'status_auto': statusAuto,
      // 'plans': plans?.map((e) => e.toJson()).toList(),
    };
  }
}

class EfficiencySummary {
  final List<HourlyDataModel> hourlyData;
  final double capacity;
  final double efficiencyLimit;
  final double effLowerLimit;
  final double effUpperLimit;

  EfficiencySummary({
    required this.hourlyData,
    required this.capacity,
    required this.efficiencyLimit,
    required this.effLowerLimit,
    required this.effUpperLimit,
  });

  factory EfficiencySummary.fromJson(Map<String, dynamic> json) {
    return EfficiencySummary(
      hourlyData: (json['hourly_data'] as List<dynamic>)
          .map((e) => HourlyDataModel.fromJson(e))
          .toList(),
      capacity: (json['capacity'] ?? 0).toDouble(),
      efficiencyLimit: (json['efficiency_limit'] ?? 0).toDouble(),
      effLowerLimit: (json['eff_lower_limit'] ?? 0).toDouble(),
      effUpperLimit: (json['eff_upper_limit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourly_data': hourlyData.map((e) => e.toJson()).toList(),
      'capacity': capacity,
      'efficiency_limit': efficiencyLimit,
      'eff_lower_limit': effLowerLimit,
      'eff_upper_limit': effUpperLimit,
    };
  }
}

class HourlyDataModel {
  final int hour;
  final double avgEfficiency;
  final double totalOutput;
  final double totalLossPcs;
  final double totalIdleBreakdown;

  HourlyDataModel({
    required this.hour,
    required this.avgEfficiency,
    required this.totalOutput,
    required this.totalLossPcs,
    required this.totalIdleBreakdown,
  });

  factory HourlyDataModel.fromJson(Map<String, dynamic> json) {
    return HourlyDataModel(
      hour: json['hour'] ?? 0,
      avgEfficiency: (json['avg_efficiency'] ?? 0).toDouble(),
      totalOutput: (json['total_output'] ?? 0).toDouble(),
      totalLossPcs: (json['total_loss_pcs'] ?? 0).toDouble(),
      totalIdleBreakdown: (json['total_idle_breakdown'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'avg_efficiency': avgEfficiency,
      'total_output': totalOutput,
      'total_loss_pcs': totalLossPcs,
      'total_idle_breakdown': totalIdleBreakdown,
    };
  }
}

class MachineRecord {
  final int id;
  final String uuid;
  final DateTime datetime;
  final String moldId;
  final String product;
  final int? cavities;
  final int? brushesperCycle;
  final double cycleTime;
  final int output;

  MachineRecord({
    required this.id,
    required this.uuid,
    required this.datetime,
    required this.moldId,
    required this.product,
    this.cavities,
    this.brushesperCycle,
    required this.cycleTime,
    required this.output,
  });

  factory MachineRecord.fromJson(Map<String, dynamic> json) {
    return MachineRecord(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      datetime: DateTime.parse(json['datetime']),
      moldId: json['mold_id'] ?? '',
      product: json['product'] ?? '',
      cavities: json['cavities'] ?? 0,
      brushesperCycle: json['BrushesperCycle'] ?? 0,
      cycleTime: (json['cycle_time'] ?? 0).toDouble(),
      output: json['output'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'datetime': datetime.toIso8601String(),
      'mold_id': moldId,
      'product': product,
      'cavities': cavities,
      'cycle_time': cycleTime,
      'output': output,
    };
  }
}

class NextActionModel {
  final int nextActionId;
  final String nextActionCode;
  final int nextPlanId;
  final String nextPlanCode;

  NextActionModel({
    required this.nextActionId,
    required this.nextActionCode,
    required this.nextPlanId,
    required this.nextPlanCode,
  });

  factory NextActionModel.fromJson(Map<String, dynamic> json) {
    return NextActionModel(
      nextActionId: json['next_action_id'] ?? 0,
      nextActionCode: json['next_action_code'],
      nextPlanId: json['next_plan_id'] ?? 0,
      nextPlanCode: json['next_plan_code'],
    );
  }
}

class SummaryReport {
  final MachineData mold;
  final MachineData tuft;
  final MachineData blister;
  final RangeData range;

  SummaryReport({
    required this.mold,
    required this.tuft,
    required this.blister,
    required this.range,
  });

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      mold: MachineData.fromJson(json['mold']),
      tuft: MachineData.fromJson(json['tuft']),
      blister: MachineData.fromJson(json['blister']),
      range: RangeData.fromJson(json['_range']),
    );
  }
}

class MachineData {
  final OutputData output;
  final EfficiencyData efficiency;
  final StatusData status;

  MachineData({
    required this.output,
    required this.efficiency,
    required this.status,
  });

  factory MachineData.fromJson(Map<String, dynamic> json) {
    return MachineData(
      output: OutputData.fromJson(json['output']),
      efficiency: EfficiencyData.fromJson(json['efficiency']),
      status: StatusData.fromJson(json['status']),
    );
  }
}

class OutputData {
  final int day;
  final int night;
  final int total;
  final int dayLostPcs;
  final double dayLossPercent;
  final int nightLostPcs;
  final double nightLossPercent;
  final int totalLostPcs;
  final double totalLossPercent;

  OutputData({
    required this.day,
    required this.night,
    required this.total,
    required this.dayLostPcs,
    required this.dayLossPercent,
    required this.nightLostPcs,
    required this.nightLossPercent,
    required this.totalLostPcs,
    required this.totalLossPercent,
  });

  factory OutputData.fromJson(Map<String, dynamic> json) {
    return OutputData(
      day: json['day'] ?? 0,
      night: json['night'] ?? 0,
      total: json['total'] ?? 0,
      dayLostPcs: json['day_lost_pcs'] ?? 0,
      dayLossPercent: (json['day_loss_percent'] ?? 0).toDouble(),
      nightLostPcs: json['night_lost_pcs'] ?? 0,
      nightLossPercent: (json['night_loss_percent'] ?? 0).toDouble(),
      totalLostPcs: json['total_lost_pcs'] ?? 0,
      totalLossPercent: (json['total_loss_percent'] ?? 0).toDouble(),
    );
  }
}

class EfficiencyData {
  final double day;
  final double night;
  final double average;

  EfficiencyData({
    required this.day,
    required this.night,
    required this.average,
  });

  factory EfficiencyData.fromJson(Map<String, dynamic> json) {
    return EfficiencyData(
      day: (json['day'] ?? 0).toDouble(),
      night: (json['night'] ?? 0).toDouble(),
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class StatusData {
  final int running;
  final int breakdown;
  final int warning;
  final int total;
  StatusData({
    required this.breakdown,
    required this.running,
    required this.warning,
    required this.total,
  });
  factory StatusData.fromJson(Map<String, dynamic> json) {
    return StatusData(
      breakdown: json['breakdown'] ?? 0,
      running: json['running'] ?? 0,
      warning: json['warning'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class RangeData {
  final String dayFrom;
  final String dayTo;
  final String nightFrom;
  final String nightTo;

  RangeData({
    required this.dayFrom,
    required this.dayTo,
    required this.nightFrom,
    required this.nightTo,
  });

  factory RangeData.fromJson(Map<String, dynamic> json) {
    return RangeData(
      dayFrom: json['day_from'] ?? '',
      dayTo: json['day_to'] ?? '',
      nightFrom: json['night_from'] ?? '',
      nightTo: json['night_to'] ?? '',
    );
  }
}
//

class Summary {
  final double day;
  final double night;
  final double average;

  Summary({required this.day, required this.night, required this.average});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      day: (json['day'] as num?)?.toDouble() ?? 0,
      night: (json['night'] as num?)?.toDouble() ?? 0,
      average: (json['average'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SummaryAll {
  final Summary mold;
  final Summary tuft;
  final Summary blister;

  SummaryAll({required this.mold, required this.tuft, required this.blister});

  factory SummaryAll.fromJson(Map<String, dynamic> json) {
    return SummaryAll(
      mold: Summary.fromJson(json['mold'] ?? {}),
      tuft: Summary.fromJson(json['tuft'] ?? {}),
      blister: Summary.fromJson(json['blister'] ?? {}),
    );
  }
}

class DetailMachine {
  final String machineId;
  final String family;
  final String? process;
  final int? moldCavity;
  final double? capacityPerHour;
  final double? capacity;
  final double? target;
  final double? upperLimit;
  final double? lowerLimit;
  final int actualCavity;
  final int? output;
  final double currentCycle;
  final double? totalLostPcs;
  final double? lostTime;
  final double efficiency;

  DetailMachine({
    required this.machineId,
    required this.family,
    this.process,
    this.moldCavity,
    this.capacityPerHour,
    this.capacity,
    this.target,
    this.upperLimit,
    this.lowerLimit,
    required this.actualCavity,
    this.output,
    required this.currentCycle,
    this.totalLostPcs,
    this.lostTime,
    required this.efficiency,
  });

  factory DetailMachine.fromJson(Map<String, dynamic> json) {
    return DetailMachine(
      machineId: json['machine_id'] ?? '',
      family: json['family'] ?? '',
      process: json['process'],
      moldCavity: json['mold_cavity'] is int
          ? json['mold_cavity']
          : int.tryParse(json['mold_cavity']?.toString() ?? '0'),
      capacityPerHour: (json['capacity_per_hour'] as num?)?.toDouble(),
      capacity: (json['capacity'] as num?)?.toDouble(),
      target: (json['target'] as num?)?.toDouble(),
      upperLimit: (json['upper_limit'] as num?)?.toDouble(),
      lowerLimit: (json['lower_limit'] as num?)?.toDouble(),
      actualCavity: json['actual_cavity'] ?? 0,
      output: json['output'] ?? 0,
      currentCycle: (json['current_cycle'] as num?)?.toDouble() ?? 0,
      totalLostPcs: (json['total_lost_pcs'] as num?)?.toDouble(),
      lostTime: (json['lost_time'] as num?)?.toDouble(),
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0,
    );
  }
}
//

class DetailMachineResponse {
  final Summary summary;
  final SummaryAll summaryAll;
  final List<DetailMachine> details;

  DetailMachineResponse({
    required this.summary,
    required this.summaryAll,
    required this.details,
  });

  factory DetailMachineResponse.fromJson(Map<String, dynamic> json) {
    return DetailMachineResponse(
      summary: Summary.fromJson(json['summary'] ?? {}),
      summaryAll: SummaryAll.fromJson(json['summary_all'] ?? {}),
      details:
          (json['details'] as List<dynamic>?)
              ?.map((item) => DetailMachine.fromJson(item))
              .toList() ??
          [],
    );
  }
}

///////
class DetailMachineOutput {
  final SummaryOutput summary;
  final List<MachineDetailOutput> details;
  final Map<String, int> familyCounts;

  DetailMachineOutput({
    required this.summary,
    required this.details,
    required this.familyCounts,
  });

  factory DetailMachineOutput.fromJson(Map<String, dynamic> json) {
    return DetailMachineOutput(
      summary: SummaryOutput.fromJson(json['summary']),
      details: (json['details'] as List)
          .map((e) => MachineDetailOutput.fromJson(e))
          .toList(),
      familyCounts: Map<String, int>.from(json['family_counts']),
    );
  }
}

class SummaryOutput {
  final double dayOutput;
  final double nightOutput;
  final double totalOutput;
  final double dayLost;
  final double nightLost;
  final double totalLost;
  final double dayLossPercent;
  final double nightLossPercent;
  final double totalLossPercent;

  SummaryOutput({
    required this.dayOutput,
    required this.nightOutput,
    required this.totalOutput,
    required this.dayLost,
    required this.nightLost,
    required this.totalLost,
    required this.dayLossPercent,
    required this.nightLossPercent,
    required this.totalLossPercent,
  });

  factory SummaryOutput.fromJson(Map<String, dynamic> json) {
    return SummaryOutput(
      dayOutput: (json['day_output'] ?? 0).toDouble(),
      nightOutput: (json['night_output'] ?? 0).toDouble(),
      totalOutput: (json['total_output'] ?? 0).toDouble(),
      dayLost: (json['day_lost'] ?? 0).toDouble(),
      nightLost: (json['night_lost'] ?? 0).toDouble(),
      totalLost: (json['total_lost'] ?? 0).toDouble(),
      dayLossPercent: (json['day_loss_percent'] ?? 0).toDouble(),
      nightLossPercent: (json['night_loss_percent'] ?? 0).toDouble(),
      totalLossPercent: (json['total_loss_percent'] ?? 0).toDouble(),
    );
  }
}

class MachineDetailOutput {
  final String machineId;
  final String family;
  final String process;
  final int moldCavity;
  final int capacity;
  final int target;
  final int upperLimit;
  final int lowerLimit;
  final double output;
  final double efficiency;
  final double totalLostPcs;
  final double lostTime;
  final double currentCycle;
  final double? subtotal;

  MachineDetailOutput({
    required this.machineId,
    required this.family,
    required this.process,
    required this.moldCavity,
    required this.capacity,
    required this.target,
    required this.upperLimit,
    required this.lowerLimit,
    required this.output,
    required this.efficiency,
    required this.totalLostPcs,
    required this.lostTime,
    required this.currentCycle,
    this.subtotal,
  });

  factory MachineDetailOutput.fromJson(Map<String, dynamic> json) {
    return MachineDetailOutput(
      machineId: json['machine_id'] ?? '',
      family: json['family'] ?? '',
      process: json['process'] ?? '',
      moldCavity: json['mold_cavity'] ?? 0,
      capacity: json['capacity'] ?? 0,
      target: json['target'] ?? 0,
      upperLimit: json['upper_limit'] ?? 0,
      lowerLimit: json['lower_limit'] ?? 0,
      output: (json['output'] ?? 0).toDouble(),
      efficiency: (json['efficiency'] ?? 0).toDouble(),
      totalLostPcs: (json['total_lost_pcs'] ?? 0).toDouble(),
      lostTime: (json['lost_time'] ?? 0).toDouble(),
      currentCycle: (json['current_cycle'] ?? 0).toDouble(),
      subtotal: json['subtotal'] != null
          ? (json['subtotal'] as num).toDouble()
          : null,
    );
  }
}

////
class FamilyListResponse {
  final List<String> families;

  FamilyListResponse({required this.families});

  factory FamilyListResponse.fromJson(List<dynamic> json) {
    return FamilyListResponse(
      families: json.map((item) => item.toString()).toList(),
    );
  }
}

class Device {
  final int id;
  final String deviceId;
  final String displayType;
  final String dataSource;
  final String? product;
  final String? model;
  final String? manufacturer;
  final String? manufacturingDate;
  final int? cavities;
  final int? holePerBrush;
  final String? process;
  final String? metricName;
  final String? lowerLimit;
  final String? targetLimit;
  final String? upperLimit;
  final int frequency;
  final int freqCheckLimit;
  final int? capacity;
  final String? moldType;
  final String? efficiencyUpperLimit;
  final String? efficiencyLowerLimit;
  final int flex;
  final int? brushesPerCycle;
  final int totalCount;
  final String unit;
  final String? totalCountUpdatedAt;
  final int cavityCount;
  final String? cavityCountUpdatedAt;
  final int totalRpm;
  final String? totalRpmUpdatedAt;
  final int totalCycle;
  final String? totalCycleUpdatedAt;
  final int historyCount;
  final String? historyCountUpdatedAt;

  Device({
    required this.id,
    required this.deviceId,
    required this.displayType,
    required this.dataSource,
    this.product,
    this.model,
    this.manufacturer,
    this.manufacturingDate,
    this.cavities,
    this.holePerBrush,
    this.process,
    this.metricName,
    this.lowerLimit,
    this.targetLimit,
    this.upperLimit,
    required this.frequency,
    required this.freqCheckLimit,
    this.capacity,
    this.moldType,
    this.efficiencyUpperLimit,
    this.efficiencyLowerLimit,
    required this.flex,
    this.brushesPerCycle,
    required this.totalCount,
    required this.unit,
    this.totalCountUpdatedAt,
    required this.cavityCount,
    this.cavityCountUpdatedAt,
    required this.totalRpm,
    this.totalRpmUpdatedAt,
    required this.totalCycle,
    this.totalCycleUpdatedAt,
    required this.historyCount,
    this.historyCountUpdatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceId: json['device_id'] ?? '',
      displayType: json['display_type'] ?? '',
      dataSource: json['data_source'] ?? '',
      product: json['product'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      manufacturingDate: json['manufacturing_date'],
      cavities: json['cavities'],
      holePerBrush: json['hole_per_brush'],
      process: json['process'],
      metricName: json['metric_name'],
      lowerLimit: json['lower_limit'],
      targetLimit: json['target_limit'],
      upperLimit: json['upper_limit'],
      frequency: json['frequency'] ?? 0,
      freqCheckLimit: json['freq_check_limit'] ?? 0,
      capacity: json['capacity'],
      moldType: json['mold_type'],
      efficiencyUpperLimit: json['efficiency_upper_limit'],
      efficiencyLowerLimit: json['efficiency_lower_limit'],
      flex: json['flex'] ?? 0,
      brushesPerCycle: json['brushes_per_cycle'],
      totalCount: json['total_count'] ?? 0,
      unit: json['unit'] ?? '',
      totalCountUpdatedAt: json['total_count_updated_at'],
      cavityCount: json['cavity_count'] ?? 0,
      cavityCountUpdatedAt: json['cavity_count_updated_at'],
      totalRpm: json['total_rpm'] ?? 0,
      totalRpmUpdatedAt: json['total_rpm_updated_at'],
      totalCycle: json['total_cycle'] ?? 0,
      totalCycleUpdatedAt: json['total_cycle_updated_at'],
      historyCount: json['history_count'] ?? 0,
      historyCountUpdatedAt: json['history_count_updated_at'],
    );
  }
}

class DeviceResponse {
  final String status;
  final Map<String, List<Device>> devices;

  DeviceResponse({required this.status, required this.devices});

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    final deviceData = <String, List<Device>>{};

    if (json['devices'] != null) {
      json['devices'].forEach((key, value) {
        deviceData[key] = List<Device>.from(
          value.map((item) => Device.fromJson(item)),
        );
      });
    }

    return DeviceResponse(status: json['status'] ?? '', devices: deviceData);
  }
}

///
// Models for API response
class ProductionResponse {
  final String status;
  final int hours;
  final Map<String, FamilyData> matrix;
  final TotalsData totals;

  ProductionResponse({
    required this.status,
    required this.hours,
    required this.matrix,
    required this.totals,
  });

  factory ProductionResponse.fromJson(Map<String, dynamic> json) {
    Map<String, FamilyData> matrixMap = {};

    if (json['matrix'] != null) {
      (json['matrix'] as Map<String, dynamic>).forEach((key, value) {
        matrixMap[key] = FamilyData.fromJson(value as Map<String, dynamic>);
      });
    }

    return ProductionResponse(
      status: json['status'] ?? '',
      hours: json['hours'] ?? 0,
      matrix: matrixMap,
      totals: TotalsData.fromJson(json['totals'] ?? {}),
    );
  }
}

class FamilyData {
  final ProcessData mold;
  final ProcessData tuft;
  final ProcessData blister;

  FamilyData({required this.mold, required this.tuft, required this.blister});

  factory FamilyData.fromJson(Map<String, dynamic> json) {
    return FamilyData(
      mold: ProcessData.fromJson(json['mold'] ?? {}),
      tuft: ProcessData.fromJson(json['tuft'] ?? {}),
      blister: ProcessData.fromJson(json['blister'] ?? {}),
    );
  }
}

class ProcessData {
  final int output;
  final int cap;
  final double efficiency;

  ProcessData({
    required this.output,
    required this.cap,
    required this.efficiency,
  });

  factory ProcessData.fromJson(Map<String, dynamic> json) {
    return ProcessData(
      output: json['output'] ?? 0,
      cap: json['cap'] ?? 0,
      efficiency: (json['efficiency'] ?? 0).toDouble(),
    );
  }
}

class TotalsData {
  final OutputTotals out;
  final CapacityTotals cap;
  final EfficiencyTotals effWeighted;
  final EfficiencyTotals effAvg;

  TotalsData({
    required this.out,
    required this.cap,
    required this.effWeighted,
    required this.effAvg,
  });

  factory TotalsData.fromJson(Map<String, dynamic> json) {
    return TotalsData(
      out: OutputTotals.fromJson(json['out'] ?? {}),
      cap: CapacityTotals.fromJson(json['cap'] ?? {}),
      effWeighted: EfficiencyTotals.fromJson(json['eff_weighted'] ?? {}),
      effAvg: EfficiencyTotals.fromJson(json['eff_avg'] ?? {}),
    );
  }
}

class OutputTotals {
  final int mold;
  final int tuft;
  final int blister;

  OutputTotals({required this.mold, required this.tuft, required this.blister});

  factory OutputTotals.fromJson(Map<String, dynamic> json) {
    return OutputTotals(
      mold: json['mold'] ?? 0,
      tuft: json['tuft'] ?? 0,
      blister: json['blister'] ?? 0,
    );
  }
}

class CapacityTotals {
  final int mold;
  final int tuft;
  final int blister;

  CapacityTotals({
    required this.mold,
    required this.tuft,
    required this.blister,
  });

  factory CapacityTotals.fromJson(Map<String, dynamic> json) {
    return CapacityTotals(
      mold: json['mold'] ?? 0,
      tuft: json['tuft'] ?? 0,
      blister: json['blister'] ?? 0,
    );
  }
}

class EfficiencyTotals {
  final double mold;
  final double tuft;
  final double blister;

  EfficiencyTotals({
    required this.mold,
    required this.tuft,
    required this.blister,
  });

  factory EfficiencyTotals.fromJson(Map<String, dynamic> json) {
    return EfficiencyTotals(
      mold: (json['mold'] ?? 0).toDouble(),
      tuft: (json['tuft'] ?? 0).toDouble(),
      blister: (json['blister'] ?? 0).toDouble(),
    );
  }
}

// View models for UI
class ProductionData {
  final String family;
  final int? molding;
  final int? tufting;
  final int? blistering;

  ProductionData({
    required this.family,
    this.molding,
    this.tufting,
    this.blistering,
  });

  factory ProductionData.fromFamilyData(String familyName, FamilyData data) {
    return ProductionData(
      family: familyName,
      molding: data.mold.output > 0 ? data.mold.output : null,
      tufting: data.tuft.output > 0 ? data.tuft.output : null,
      blistering: data.blister.output > 0 ? data.blister.output : null,
    );
  }
}

class EfficiencyDataa {
  final String family;
  final double? moldingEfficiency;
  final double? tuftingEfficiency;
  final double? blisteringEfficiency;

  EfficiencyDataa({
    required this.family,
    this.moldingEfficiency,
    this.tuftingEfficiency,
    this.blisteringEfficiency,
  });

  factory EfficiencyDataa.fromFamilyData(String familyName, FamilyData data) {
    return EfficiencyDataa(
      family: familyName,
      moldingEfficiency: data.mold.efficiency > 0 ? data.mold.efficiency : null,
      tuftingEfficiency: data.tuft.efficiency > 0 ? data.tuft.efficiency : null,
      blisteringEfficiency: data.blister.efficiency > 0
          ? data.blister.efficiency
          : null,
    );
  }
}

class ActionPlann {
  final int id;
  final String planCode;
  final String planText;
  final String? estDate;
  final String? ownerName;
  final String status;

  ActionPlann({
    required this.id,
    required this.planCode,
    required this.planText,
    this.estDate,
    this.ownerName,
    required this.status,
  });

  factory ActionPlann.fromJson(Map<String, dynamic> json) {
    return ActionPlann(
      id: json['id'] ?? 0,
      planCode: json['plan_code'] ?? '',
      planText: json['plan_text'] ?? '',
      estDate: json['est_date'],
      ownerName: json['owner_name'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_code': planCode,
      'plan_text': planText,
      'est_date': estDate,
      'owner_name': ownerName,
      'status': status,
    };
  }

  ActionPlann copyWith({
    int? id,
    String? planCode,
    String? planText,
    String? estDate,
    String? ownerName,
    String? status,
  }) {
    return ActionPlann(
      id: id ?? this.id,
      planCode: planCode ?? this.planCode,
      planText: planText ?? this.planText,
      estDate: estDate ?? this.estDate,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
    );
  }
}

class ActionItemEms {
  final int actionPk;
  final String type;
  final String device;
  final String issueType;
  final String issueId;
  final String descriptionOfIssue;
  final String createdAt;
  final String plannedCompletionDate;
  final String createdBy;
  final String actionStatus;
  final String approvalStatus;
  final String statusDisplay;
  final String plansDone;
  final int plansTotal;
  final String product;
  final String process;
  final List<ActionPlann>? plans;

  ActionItemEms({
    required this.actionPk,
    required this.type,
    required this.device,
    required this.issueType,
    required this.issueId,
    required this.descriptionOfIssue,
    required this.createdAt,
    required this.plannedCompletionDate,
    required this.createdBy,
    required this.actionStatus,
    required this.approvalStatus,
    required this.statusDisplay,
    required this.plansDone,
    required this.plansTotal,
    required this.product,
    required this.process,
    this.plans,
  });

  factory ActionItemEms.fromJson(Map<String, dynamic> json) {
    return ActionItemEms(
      actionPk: json['action_pk'] ?? 0,
      type: json['type'] ?? '',
      device: json['device'] ?? '',
      issueType: json['issue_type'] ?? '',
      issueId: json['issue_id'] ?? '',
      descriptionOfIssue: json['description_of_issue'] ?? '',
      createdAt: json['created_at'] ?? '',
      plannedCompletionDate: json['planned_completion_date'] ?? '',
      createdBy: json['created_by'] ?? '-',
      actionStatus: json['action_status'] ?? '',
      approvalStatus: json['approval_status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      plansDone: json['plans_done'] ?? '0',
      plansTotal: json['plans_total'] ?? 0,
      product: json['product'] ?? '',
      process: json['process'] ?? '',
      plans: (json['plans'] as List<dynamic>?)
          ?.map((e) => ActionPlann.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_pk': actionPk,
      'type': type,
      'device': device,
      'issue_type': issueType,
      'issue_id': issueId,
      'description_of_issue': descriptionOfIssue,
      'created_at': createdAt,
      'planned_completion_date': plannedCompletionDate,
      'created_by': createdBy,
      'action_status': actionStatus,
      'approval_status': approvalStatus,
      'status_display': statusDisplay,
      'plans_done': plansDone,
      'plans_total': plansTotal,
      'product': product,
      'process': process,
      'plans': plans?.map((e) => e.toJson()).toList(),
    };
  }

  ActionItemEms copyWith({
    int? actionPk,
    String? type,
    String? device,
    String? issueType,
    String? issueId,
    String? descriptionOfIssue,
    String? createdAt,
    String? plannedCompletionDate,
    String? createdBy,
    String? actionStatus,
    String? approvalStatus,
    String? statusDisplay,
    String? plansDone,
    int? plansTotal,
    String? product,
    String? process,
    List<ActionPlann>? plans,
  }) {
    return ActionItemEms(
      actionPk: actionPk ?? this.actionPk,
      type: type ?? this.type,
      device: device ?? this.device,
      issueType: issueType ?? this.issueType,
      issueId: issueId ?? this.issueId,
      descriptionOfIssue: descriptionOfIssue ?? this.descriptionOfIssue,
      createdAt: createdAt ?? this.createdAt,
      plannedCompletionDate:
          plannedCompletionDate ?? this.plannedCompletionDate,
      createdBy: createdBy ?? this.createdBy,
      actionStatus: actionStatus ?? this.actionStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      plansDone: plansDone ?? this.plansDone,
      plansTotal: plansTotal ?? this.plansTotal,
      product: product ?? this.product,
      process: process ?? this.process,
      plans: plans ?? this.plans,
    );
  }
}
