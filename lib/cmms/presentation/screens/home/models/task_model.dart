class TaskModel {
  final String code;
  final String? location;
  final String? equipment;
  final String status;

  TaskModel({
    required this.code,
    this.location,
    this.equipment,
    required this.status,
  });
}