class UpcomingMaintenance {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final String priority;

  UpcomingMaintenance({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.priority,
  });
}

// Demo data
List<UpcomingMaintenance> demoMaintenances = [
  UpcomingMaintenance(
    id: '1',
    title: 'Replace Filter on Machine #7',
    scheduledDate: DateTime.now().add(const Duration(days: 1)),
    priority: 'ML03',
  ),
  UpcomingMaintenance(
    id: '2',
    title: 'Lubrication for Conveyor #3',
    scheduledDate: DateTime.now().add(const Duration(days: 3)),
    priority: 'ML02',
  ),
  UpcomingMaintenance(
    id: '3',
    title: 'Inspect Cooling Tower',
    scheduledDate: DateTime.now().add(const Duration(days: 5)),
    priority: 'ML01',
  ),
  UpcomingMaintenance(
    id: '1',
    title: 'Replace Filter on Machine #7',
    scheduledDate: DateTime.now().add(const Duration(days: 1)),
    priority: 'ML03',
  ),
  UpcomingMaintenance(
    id: '2',
    title: 'Lubrication for Conveyor #3',
    scheduledDate: DateTime.now().add(const Duration(days: 3)),
    priority: 'ML02',
  ),
  UpcomingMaintenance(
    id: '3',
    title: 'Inspect Cooling Tower',
    scheduledDate: DateTime.now().add(const Duration(days: 5)),
    priority: 'ML01',
  ),
];
