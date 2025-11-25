import 'package:flutter/foundation.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/data/models/machine_model.dart';

class IssueActionProvider with ChangeNotifier {
  List<ActionItemEms> _actions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool get loading => _isLoading;
  bool _isDeleting = false; // (1) khóa thao tác

  List<ActionItemEms> get actions => _actions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchActions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _actions = await EmsApiService.fetchActionItemEmss();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPlans(int actionId) async {
    try {
      final plans = await EmsApiService.fetchPlans(actionId);

      final index = _actions.indexWhere((a) => a.actionPk == actionId);
      if (index == -1) return;

      _actions[index] = _actions[index].copyWith(plans: plans);

      notifyListeners();
    } catch (e) {
      print("Error fetchPlans: $e");
    }
  }

  Future<void> approveAction(int actionId, {String reason = "Approved Action"}) async {
    try {
      final success = await EmsApiService.approveAction(
        actionId: actionId,
        reason: reason,
      );

      if (!success) return;

      final index = _actions.indexWhere((a) => a.actionPk == actionId);
      if (index == -1) return;

      _actions[index] = _actions[index].copyWith(
        approvalStatus: "approved", // cập nhật UI ngay
        actionStatus: "approved",
      );

      notifyListeners();
    } catch (e) {
      print("Approve error: $e");
    }
  }
  Future<void> rejectedAction(int actionId, {String reason = "Rejected Action"}) async {
    try {
      final success = await EmsApiService.rejectedAction(
        actionId: actionId,
        reason: reason,
      );

      if (!success) return;

      final index = _actions.indexWhere((a) => a.actionPk == actionId);
      if (index == -1) return;

      _actions[index] = _actions[index].copyWith(
        approvalStatus: "rejected", // cập nhật UI ngay
        actionStatus: "rejected",
      );

      notifyListeners();
    } catch (e) {
      print("Rejectederror: $e");
    }
  }

  Future<void> deleteAction(int actionId, {String reason = "No reason"}) async {
    // (1) Nếu đang xóa, bỏ qua thao tác tiếp theo
    if (_isDeleting) return;
    _isDeleting = true;
    notifyListeners();

    try {
      final success = await EmsApiService.deleteAction(
        actionId: actionId,
        reason: reason,
      );

      if (success) {
        // (4) kiểm tra item còn tồn tại trước khi xóa
        if (_actions.any((a) => a.actionPk == actionId)) {
          _actions.removeWhere((item) => item.actionPk == actionId);

          // (2) delay nhẹ tránh lỗi concurrent modification
          await Future.delayed(const Duration(milliseconds: 60));

          notifyListeners();
        }
      }
    } catch (e) {
      print("Delete error: $e");
    } finally {
      _isDeleting = false; // mở khóa để thao tác tiếp
      notifyListeners();
    }
  }
}
