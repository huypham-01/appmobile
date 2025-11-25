// import 'package:flutter/material.dart';

// import '../models/task_equipment_today.dart';
// import '../repositories/task_equipment_today_repository.dart';

// class InspectionProvider with ChangeNotifier {
//   final InspectionRepository _repository = InspectionRepository();

//   List<Inspection> _inspections = [];
//   bool _isLoading = false;
//   String? _error;

//   List<Inspection> get inspections => _inspections;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> loadInspections() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _inspections = await _repository.getInspections();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Future<void> createInspection(Map<String, dynamic> body) async {
//   //   _isLoading = true;
//   //   notifyListeners();

//   //   try {
//   //     final success = await _repository.addInspection(body);
//   //     if (success) {
//   //       await loadInspections();
//   //     } else {
//   //       _error = "Failed to create inspection";
//   //     }
//   //   } catch (e) {
//   //     _error = e.toString();
//   //   } finally {
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }
// }