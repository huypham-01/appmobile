// File: lib/presentation/pages/issues_dialog.dart (fixed with better logic)
import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../data/models/machine_model.dart';

class IssuesDialog extends StatefulWidget {
  final String deviceId;
  const IssuesDialog({super.key, required this.deviceId});

  @override
  State<IssuesDialog> createState() => _IssuesDialogState();
}

class _IssuesDialogState extends State<IssuesDialog> {
  final Map<int, bool> _expandedStates = {}; // Dùng issueId (int) thay vì index
  List<IssueModel> _issues = [];
  bool _isLoading = true;
  bool _isUpdating = false; // Prevent multiple simultaneous updates
  bool canActionUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadIssues();
    loadPermissions();
  }

  void loadPermissions() async {
    canActionUpdate = await PermissionHelper.has("update.status.action.plan");
    setState(() {});
  }

  Future<void> _loadIssues() async {
    try {
      final issues = await EmsApiService.fetchIssues(widget.deviceId);
      if (mounted) {
        setState(() {
          _issues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("Error loading issues");
    }
  }

  Future<void> _toggleExpanded(int issueId) async {
    final issue = _issues.firstWhere((i) => i.id == issueId);
    final isExpanded = _expandedStates[issueId] ?? false;

    // Nếu đang expand và chưa có action plans, thì fetch
    if (!isExpanded && issue.plans.isEmpty) {
      try {
        final planss = await EmsApiService.fetchActionPlans(issueId);
        if (mounted) {
          setState(() {
            issue.plans = planss;
            _expandedStates[issueId] = true;
          });
        }
      } catch (e) {
        debugPrint("Error loading action plans");
      }
    } else {
      // Toggle expand/collapse
      if (mounted) {
        setState(() {
          _expandedStates[issueId] = !isExpanded;
        });
      }
    }
  }

  // Future<void> _completeAction(ActionPlan actionPlan, int issueId) async {
  //   if (_isUpdating) return; // Prevent multiple simultaneous updates

  //   setState(() => _isUpdating = true);

  //   try {
  //     await FmcsApiService.updateActionPlanStatus(planId: actionPlan.id);

  //     // Reload lại issue cụ thể thay vì reload toàn bộ
  //     await _reloadSingleIssue(issueId);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: const [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(child: Text('Complete Action Successfully')),
  //             ],
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("Error completing action: $e");
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: const [
  //               Icon(Icons.error, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(child: Text('Failed to complete action')),
  //             ],
  //           ),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isUpdating = false);
  //     }
  //   }
  // }

  Future<void> _reloadSingleIssue(int issueId) async {
    try {
      final index = _issues.indexWhere((i) => i.id == issueId);
      if (index == -1) return;

      final issue = _issues[index];
      final isExpanded = _expandedStates[issueId] ?? false;

      // Fetch lại issues để cập nhật doneCount/planCount
      final updatedIssues = await EmsApiService.fetchIssues(widget.deviceId);
      final updatedIssue = updatedIssues.firstWhere(
        (i) => i.id == issueId,
        orElse: () => issue,
      );

      // Nếu đang expanded, fetch lại action plans
      if (isExpanded) {
        final plans = await EmsApiService.fetchActionPlans(issueId);
        updatedIssue.plans = plans;
      }

      if (mounted) {
        setState(() {
          _issues[index] = updatedIssue;
        });
      }
    } catch (e) {
      debugPrint("Error reloading issue: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(5),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 230, 234, 238),
                    const Color.fromARGB(255, 228, 236, 241),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        88,
                        86,
                        86,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.report_problem,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.issueid} - ${widget.deviceId}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _issues.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noIssuesFound,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _issues.length,
                      itemBuilder: (context, index) {
                        final issue = _issues[index];
                        return _buildIssueCard(issue);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    final isExpanded = _expandedStates[issue.id] ?? false;
    final statusColor = _getIssueStatusColor(issue.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(182, 230, 230, 228),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    issue.deviceId,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    issue.status,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.category,
                        AppLocalizations.of(context)!.issueType,
                        issue.issueType,
                        Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person,
                        AppLocalizations.of(context)!.creator,
                        issue.createdByName,
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.schedule,
                        AppLocalizations.of(context)!.createdDate,
                        issue.createdAt,
                        Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.event,
                        AppLocalizations.of(context)!.dueDate,
                        "${issue.plannedCompletionDate}",
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.check_circle,
                        AppLocalizations.of(context)!.approvalStatus,
                        issue.approvalStatus,
                        Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleExpanded(issue.id),
                        child: _buildInfoItem(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          AppLocalizations.of(context)!.actionPlan,
                          "${issue.plansDone}/${issue.plansTotal}",
                          Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action Plans Table
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  _buildActionPlansTable(issue),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlansTable(IssueModel issue) {
    if (issue.plans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noActionPlansAvailable,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: issue.plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        return buildActionPlanCard(plan, index, issue.id);
      }).toList(),
    );
  }

  Widget buildActionPlanCard(ActionPlann plan, int index, int issueId) {
    final statusColor = _getStatusColor(plan.status);
    final isTodo = plan.status.toLowerCase() == "open";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            /// ---------------------- HEADER ----------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Text + Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.planText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${AppLocalizations.of(context)!.actionid}: ${plan.planCode}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// ---------------------- STATUS or COMPLETE BUTTON ----------------------
                (isTodo && canActionUpdate)
                    ? GestureDetector(
                        onTap: _isUpdating
                            ? null
                            : () => _showCompleteActionDialog(
                                context,
                                plan,
                                issueId,
                              ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.green.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.complete,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    /// ❌ Không có quyền → chỉ hiển thị trạng thái TODO, KHÔNG phải nút Complete
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isTodo ? Icons.schedule : Icons.check_circle,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plan.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),

            /// ---------------------- FOOTER ----------------------
            Row(
              children: [
                if (plan.estDate != null) ...[
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    plan.estDate!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const Spacer(),
                if (plan.ownerName != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    plan.ownerName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildActionPlanRow(ActionPlann actionPlan, int index, int issueId) {
  //   final actionStatusColor = _getActionStatusColor(actionPlan.status);

  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
  //       border: Border(
  //         bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           flex: 2,
  //           child: Text(
  //             actionPlan.planText,
  //             style: const TextStyle(fontSize: 12, color: Colors.black87),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 2,
  //           child: Text(
  //             actionPlan.estDate ?? "-",
  //             style: const TextStyle(fontSize: 12, color: Colors.black87),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Text(
  //             actionPlan.ownerName ?? "-",
  //             style: const TextStyle(fontSize: 12, color: Colors.black87),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Text(
  //             actionPlan.status,
  //             style: TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.bold,
  //               color: actionStatusColor,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),

  //         // Action button
  //         SizedBox(
  //           width: 40,
  //           child: actionPlan.status.toLowerCase() == "open"
  //               ? GestureDetector(
  //                   onTap: _isUpdating
  //                       ? null
  //                       : () => _showCompleteActionDialog(
  //                           context,
  //                           actionPlan,
  //                           issueId,
  //                         ),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(4),
  //                     decoration: BoxDecoration(
  //                       color: _isUpdating
  //                           ? Colors.grey.withOpacity(0.1)
  //                           : Colors.green.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: Icon(
  //                       Icons.check,
  //                       size: 16,
  //                       color: _isUpdating ? Colors.grey : Colors.green,
  //                     ),
  //                   ),
  //                 )
  //               : const SizedBox(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF10B981);
      case 'open':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFEF4444);
    }
  }

  Color _getIssueStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return Colors.lightBlue;
      case "complete":
        return Colors.green;
      default:
        return Colors.amberAccent;
    }
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCompleteActionDialog(
    BuildContext context,
    ActionPlann actionPlan,
    int issueId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during update
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.completeActionTitle),
        content: Text("Mark '${actionPlan.planText}' as completed?"),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: _isUpdating
                ? null
                : () async {
                    Navigator.pop(dialogContext);
                    await _completeAction(actionPlan, issueId);
                  },
            child: _isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)!.complete),
          ),
        ],
      ),
    );
  }

  // Color _getActionStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case "done":
  //     case "close":
  //       return Colors.green;
  //     case "in progress":
  //       return Colors.blue;
  //     case "pending":
  //       return Colors.orange;
  //     case "approved":
  //       return Colors.purple;
  //     case "open":
  //       return Colors.orange;
  //     case "todo":
  //       return Colors.grey;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  Future<void> _completeAction(ActionPlann actionPlan, int issueId) async {
    if (_isUpdating) return; // Prevent multiple simultaneous updates

    setState(() => _isUpdating = true);

    try {
      await EmsApiService.updateActionPlanStatus(planId: actionPlan.id);

      // Reload lại issue cụ thể thay vì reload toàn bộ
      await _reloadSingleIssue(issueId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.completeActionSuccess,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error completing action: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(AppLocalizations.of(context)!.completeActionFailed)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}
