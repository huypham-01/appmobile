// models/category.dart
import 'dart:convert';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}
// models/equipment.dart

class Equipment {
  final String id;
  final String machineId;
  final String family;
  final String model;
  final String cavity;
  final int historyCount;
  final Category category;

  Equipment({
    required this.id,
    required this.machineId,
    required this.family,
    required this.model,
    required this.cavity,
    required this.historyCount,
    required this.category,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      machineId: json['machine_id'],
      family: json['family'],
      model: json['model'],
      cavity: json['cavity'],
      historyCount: json['history_count'],
      category: Category.fromJson(json['category']),
    );
  }
}
// models/inspection.dart

class Inspection {
  final String uuid;
  final String status;
  // final String dateOfInspected;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String updatedAt;
  final Equipment equipment;

  Inspection({
    required this.uuid,
    required this.status,
    // required this.dateOfInspected,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.equipment,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      uuid: json['uuid'],
      status: json['status'],
      // dateOfInspected: json['date_of_inspected'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedBy: json['updated_by'],
      updatedAt: json['updated_at'],
      equipment: Equipment.fromJson(json['equipment']),
    );
  }
}

class DetailTaskEquipment {
  final String uuid;
  final String code;
  final String inspectionDate;
  final String dateStart;
  final String content;
  final String status;
  final String result;
  final String inspectoId;
  final String inspectoName;
  DetailTaskEquipment({
    required this.uuid,
    required this.code,
    required this.inspectionDate,
    required this.dateStart,
    required this.content,
    required this.status,
    required this.result,
    required this.inspectoId,
    required this.inspectoName,
  });
  factory DetailTaskEquipment.fromJson(Map<String, dynamic> json) {
    return DetailTaskEquipment(
      uuid: json['wi_id'],
      inspectionDate: json['inspected_date'] ?? '---',
      content: json['content'],
      status: json['status'] ?? "null",
      code: json['code'],
      dateStart: json['date_start'] ?? '-',
      result: json['result'] ?? "--",
      inspectoId: json['inspector_id'] ?? '----',
      inspectoName: json['inspector_name'] ?? '--',
    );
  }
}

class DetailTaskMaintenance {
  final String uuid;
  final String wiId;
  final String equipmentId;
  final String code;
  final String name;
  final String type;
  final String? schema; // lưu chuỗi JSON gốc
  final List<dynamic>? schemaData; // parse thành list object
  final String categoryId;
  final String frequency;
  final String unitValue;
  final String unitType;
  final String status;
  final String? result;
  final String times;
  final String countTarget;
  final String dateStart;
  final String? inspectedDate;
  final String? inspectorId;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? username;

  DetailTaskMaintenance({
    required this.uuid,
    required this.wiId,
    required this.equipmentId,
    required this.code,
    required this.name,
    required this.type,
    this.schema,
    this.schemaData,
    required this.categoryId,
    required this.frequency,
    required this.unitValue,
    required this.unitType,
    required this.status,
    this.result,
    required this.times,
    required this.countTarget,
    required this.dateStart,
    this.inspectedDate,
    this.inspectorId,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.username,
  });

  factory DetailTaskMaintenance.fromJson(Map<String, dynamic> json) {
    List<dynamic>? parsedSchema;
    try {
      // parse "schema" từ chuỗi JSON (nếu có)
      if (json['schema'] != null && json['schema'].isNotEmpty) {
        parsedSchema = jsonDecode(json['schema']);
      }
    } catch (e) {
      parsedSchema = [];
    }

    return DetailTaskMaintenance(
      uuid: json['uuid'] ?? '',
      wiId: json['wi_id'] ?? '',
      equipmentId: json['equipment_id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      schema: json['schema'],
      schemaData: parsedSchema,
      categoryId: json['category_id'] ?? '',
      frequency: json['frequency'] ?? '',
      unitValue: json['unit_value']?.toString() ?? '',
      unitType: json['unit_type'] ?? '',
      status: json['status'] ?? '',
      result: json['result'],
      times: json['times']?.toString() ?? '',
      countTarget: json['count_target']?.toString() ?? '',
      dateStart: json['date_start'] ?? '',
      inspectedDate: json['inspected_date'],
      inspectorId: json['inspector_id'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deletedBy: json['deleted_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      username: json['username'],
    );
  }
}

class QuestionTask {
  final String uuid;
  final String name;
  final String description;
  final List<Question> questions;

  QuestionTask({
    required this.uuid,
    required this.name,
    required this.description,
    required this.questions,
  });

  factory QuestionTask.fromJson(Map<String, dynamic> json) {
    return QuestionTask(
      uuid: json['uuid'],
      name: json['name'],
      description: json['description'],
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }
}

class Question {
  final String uuid;
  final String content;
  int? answer;

  Question({required this.uuid, required this.content, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      uuid: json['uuid'],
      content: json['content'],
      answer: json['answer'] ?? null,
    );
  }
}

////////////
class TaskEquipmentToday {
  final String uuid;
  final String machineId;
  final String name;
  final String model;
  final String cavity;
  final String family;
  final int countDone;
  final int countPending;
  final String category;
  final String status;
  final String manufacturingDate;
  final String historyCount;
  final String manufacturer;
  final int unit;
  final String inspectors;
  final String inspectedDate;

  TaskEquipmentToday({
    required this.uuid,
    required this.name,
    required this.machineId,
    required this.model,
    required this.cavity,
    required this.family,
    required this.countDone,
    required this.countPending,
    required this.unit,
    required this.manufacturer,
    required this.historyCount,
    required this.manufacturingDate,
    required this.category,
    required this.status,
    required this.inspectors,
    required this.inspectedDate,
  });
  factory TaskEquipmentToday.fromJson(Map<String, dynamic> json) {
    return TaskEquipmentToday(
      uuid: json['equipment_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      model: json['model'] ?? '',
      cavity: json['cavity'] ?? '',
      family: json['family'] ?? '',
      name: "${json['machine_id'] ?? ''} - ${json['family'] ?? ''}",
      countDone: int.tryParse(json['count_done']?.toString() ?? '0') ?? 0,
      countPending: int.tryParse(json['count_pending']?.toString() ?? '0') ?? 0,
      category: json['category_name'] ?? '',
      status: json['status'] ?? '',
      inspectors: json['inspectors'] ?? '',
      inspectedDate: json['inspected_date'] ?? '',
      unit: int.tryParse(json['unit']?.toString() ?? '0') ?? 0,
      manufacturer: json['manufacturer'] ?? '',
      historyCount: json['history_count'] ?? '',
      manufacturingDate: json['manufacturing_date'] ?? '',
    );
  }
}

///// taskMaintenance
class TaskMaintenance {
  final String uuid;
  final String machineId;
  final String model;
  final String cavity;
  final int total;
  final int done;
  final String category;
  final String historyCount;
  final String manufacturingDate;
  final int unit;
  final int daylyRate;
  final String manufacturer;
  final String status;
  final String inspectors;
  final String inspectedDate;

  TaskMaintenance({
    required this.uuid,
    required this.machineId,
    required this.model,
    required this.cavity,
    required this.manufacturer,
    required this.manufacturingDate,
    required this.historyCount,
    required this.unit,
    required this.daylyRate,
    required this.total,
    required this.done,

    required this.category,
    required this.status,
    required this.inspectors,
    required this.inspectedDate,
  });
  factory TaskMaintenance.fromJson(Map<String, dynamic> json) {
    return TaskMaintenance(
      uuid: json['uuid'] ?? '',
      machineId: json['machine_id'] ?? '',
      model: json['model'] ?? '-',
      cavity: json['cavity'] ?? '-',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      done: int.tryParse(json['done']?.toString() ?? '0') ?? 0,
      category: json['category_name'] ?? '-',
      status: json['status'] ?? '',
      inspectors: json['inspectors'] ?? '',
      inspectedDate: json['inspected_date'] ?? '',
      unit: int.tryParse(json['unit']?.toString() ?? '0') ?? 0,
      daylyRate: int.tryParse(json['daily_rate']?.toString() ?? '0') ?? 0,
      manufacturer: json['manufacturer'] ?? '',
      historyCount: json['history_count'] ?? '',
      manufacturingDate: json['manufacturing_date'] ?? '',
    );
  }
}

// ✅ Model cho Equipment
class EquipmentData {
  final String uuid;
  final String machineId;
  final int historyCount;
  final String unit;
  final int dailyRate;

  EquipmentData({
    required this.uuid,
    required this.machineId,
    required this.historyCount,
    required this.unit,
    required this.dailyRate,
  });

  factory EquipmentData.fromJson(Map<String, dynamic> json) {
    return EquipmentData(
      uuid: json['uuid'] ?? '',
      machineId: json['machine_id'] ?? 'Unknown',
      historyCount: int.tryParse(json['history_count']?.toString() ?? '0') ?? 0,
      unit: json['unit'] ?? 'shot',
      dailyRate: int.tryParse(json['daily_rate']?.toString() ?? '0') ?? 0,
    );
  }
}

// ✅ Model cho Task
class MaintenanceTask {
  final String name;
  final String type;
  final int countTarget;
  final String dateStart;

  MaintenanceTask({
    required this.name,
    required this.type,
    required this.countTarget,
    required this.dateStart,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      name: json['name'] ?? 'Unknown Task',
      type: json['type'] ?? '',
      countTarget: int.tryParse(json['count_target']?.toString() ?? '0') ?? 0,
      dateStart: json['date_start'] ?? '',
    );
  }
}

class TaskOverDue {
  final String uuid;
  final String machineId;
  final String model;
  final String cavity;
  final int total;

  TaskOverDue({
    required this.uuid,
    required this.machineId,
    required this.model,
    required this.cavity,
    required this.total,
  });
  factory TaskOverDue.fromJson(Map<String, dynamic> json) {
    return TaskOverDue(
      uuid: json['uuid'] ?? '',
      machineId: json['machine_id'] ?? '',
      model: json['model'] ?? '-',
      cavity: json['cavity'] ?? '-',
      total: int.tryParse(json['total_overdue']?.toString() ?? '0') ?? 0,
    );
  }
}

class TaskOverDueDetail {
  final String uuid;
  final String code;
  final String description;
  final String type;
  final String dateStart;
  final String schema;

  TaskOverDueDetail({
    required this.uuid,
    required this.code,
    required this.description,
    required this.type,
    required this.dateStart,
    required this.schema,
  });
  factory TaskOverDueDetail.fromJson(Map<String, dynamic> json) {
    return TaskOverDueDetail(
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '-',
      dateStart: json['date_start'] ?? '-',
      schema: json['schema'],
    );
  }
}
