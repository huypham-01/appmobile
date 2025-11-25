import 'package:flutter/foundation.dart';
import 'package:mobile/fmcs/data/fmcs_api_service.dart';

import 'models/device_response_model.dart';

class ActionProvider with ChangeNotifier {
  List<ActionItem> _actions = [];
  bool _loading = false;

  List<ActionItem> get actions => _actions;
  bool get loading => _loading;

  /// Fetch toàn bộ actions
  Future<void> fetchActions() async {
    _loading = true;
    notifyListeners();

    try {
      _actions = await FmcsApiService.fetchActions();
    } catch (e, stackTrace) {
      // In lỗi ra console (phục vụ debug)
      debugPrint("Error fetching actions: $e");
      debugPrintStack(stackTrace: stackTrace);

      // Giữ cho ứng dụng không crash
      _actions = []; // Có thể đặt danh sách trống hoặc giữ dữ liệu cũ

      // Tuỳ chọn: thông báo lỗi cho UI
      // Bạn có thể tạo biến _errorMessage để hiển thị lỗi nếu muốn
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetch danh sách ActionPlan cho 1 ActionItem
  Future<void> fetchPlans(int actionId) async {
    try {
      final plans = await FmcsApiService.fetchPlans(actionId);

      // Tìm action tương ứng và cập nhật plans
      final index = _actions.indexWhere((a) => a.id == actionId);
      if (index != -1) {
        _actions[index] = _actions[index].copyWith(plans: plans);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetchPlans: $e");
      }
    }
  }

  /// Approve 1 action
  Future<void> approveAction(int actionId, String value) async {
    try {
      // Tìm action và lưu lại trạng thái cũ
      final index = _actions.indexWhere((a) => a.id == actionId);
      if (index == -1) return;

      final oldStatus = _actions[index].approvalStatus;

      // Update ngay UI
      _actions[index] = _actions[index].copyWith(approvalStatus: value);
      notifyListeners();

      // Gọi API
      final result = await FmcsApiService.setActionApproval(
        actionId: actionId,
        value: value,
      );

      // Nếu API thất bại thì rollback
      if (result["status"] != "success") {
        _actions[index] = _actions[index].copyWith(approvalStatus: oldStatus);
        notifyListeners();
        if (kDebugMode) {
          print("Approve action failed on server, rolled back.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error approveAction: $e");
      }
      // Rollback trong trường hợp lỗi exception
      final index = _actions.indexWhere((a) => a.id == actionId);
      if (index != -1) {
        _actions[index] = _actions[index].copyWith(
          approvalStatus: "pending", // hoặc trạng thái cũ
        );
        notifyListeners();
      }
    }
  }

  /// Delete action - Xóa item khỏi danh sách local ngay lập tức
  Future<void> deleteAction(int actionId, String textReason) async {
    // Lưu lại item trước khi xóa để rollback nếu cần
    final deletedItem = _actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => null as ActionItem, // tránh crash nếu không tìm thấy
    );

    if (deletedItem == null) return;

    try {
      // Xóa khỏi danh sách local TRƯỚC để UI cập nhật ngay
      _actions.removeWhere((a) => a.id == actionId);
      notifyListeners();

      // Sau đó gọi API
      final result = await FmcsApiService.deleteAction(actionId: actionId, reason: textReason);

      // Nếu API thất bại, rollback
      if (result["status"] != "success") {
        if (kDebugMode) {
          print("Delete action failed on server → rollback");
        }
        _actions.add(deletedItem);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleteAction: $e → rollback");
      }
      // Rollback trong trường hợp exception
      _actions.add(deletedItem);
      notifyListeners();
    }
  }
}
