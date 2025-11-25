import 'package:flutter/material.dart';
import 'package:mobile/ems/data/action_provider_ems.dart';
import 'package:mobile/ems/data/models/machine_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/routes/ems_routes.dart';
import 'package:provider/provider.dart';

class ApproveActionEms extends StatefulWidget {
  const ApproveActionEms({super.key});

  @override
  State<ApproveActionEms> createState() => _ApproveActionEmsState();
}

class _ApproveActionEmsState extends State<ApproveActionEms>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'All';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => Provider.of<IssueActionProvider>(
        context,
        listen: false,
      ).fetchActions(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<ActionItemEms> getFilteredActions(
    List<ActionItemEms> actions,
    bool isComplete,
  ) {
    // Lọc theo tab (In progress hoặc Complete)
    List<ActionItemEms> filtered = actions.where((item) {
      if (isComplete) {
        return item.statusDisplay.toLowerCase().contains('complete');
      } else {
        return !item.statusDisplay.toLowerCase().contains('complete');
      }
    }).toList();

    // Lọc theo approval status
    if (selectedFilter != 'All') {
      filtered = filtered.where((item) {
        return item.approvalStatus.toLowerCase() ==
            selectedFilter.toLowerCase();
      }).toList();
    }

    // Lọc theo search
    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((item) {
        return item.device.toLowerCase().contains(searchText) ||
            item.issueType.toLowerCase().contains(searchText) ||
            (item.createdBy.toLowerCase().contains(searchText) ?? false) ||
            item.issueType.toLowerCase().contains(searchText);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IssueActionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("assets/images/acumenIcon.png", height: 26),
            const SizedBox(width: 10),
            const Text(
              "EMS",
              style: TextStyle(
                color: Color.fromARGB(221, 35, 34, 34),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: "NotoSansSC",
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<String>(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: const Icon(
                Icons.menu_sharp,
                color: Colors.black87,
                size: 30,
              ),
              itemBuilder: (context) => [
                _buildMenuItem(
                  context: context,
                  value: 'menu1',
                  icon: Icons.dashboard_outlined,
                  text: AppLocalizations.of(context)!.monitoring,
                  onTap: () {
                    Navigator.pushNamed(context, EmsRoutes.home);
                  },
                ),
                const PopupMenuDivider(),

                // _buildMenuItem(
                //   context: context,
                //   value: 'menu2',
                //   icon: Icons.add_box,
                //   text: "System Settings",
                //   onTap: () {
                //     Navigator.pushNamed(context, FmcsRoutes.systemSetting);
                //   },
                // ),
                _buildMenuItem(
                  context: context,
                  value: 'menu4',
                  icon: Icons.arrow_back,
                  text: AppLocalizations.of(context)!.back,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, EmsRoutes.home);
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.inProgress),
                Tab(text: AppLocalizations.of(context)!.complete),
              ],
            ),
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter and Search Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 12,
                    right: 12,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchHintt,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                provider.fetchActions();
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.approvalStatus,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip(
                                    'Pending',
                                    selectedFilter == 'Pending',
                                  ),
                                  const SizedBox(width: 4),
                                  _buildFilterChip(
                                    'Approved',
                                    selectedFilter == 'Approved',
                                  ),
                                  const SizedBox(width: 4),
                                  _buildFilterChip(
                                    'Rejected',
                                    selectedFilter == 'Rejected',
                                  ),
                                  const SizedBox(width: 4),
                                  _buildFilterChip(
                                    AppLocalizations.of(context)!.all,
                                    selectedFilter == 'All',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // In Progress Tab
                      _buildCardList(
                        getFilteredActions(provider.actions, false),
                        false,
                      ),
                      // Complete Tab
                      _buildCardList(
                        getFilteredActions(provider.actions, true),
                        true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCardList(List<ActionItemEms> items, bool isComplete) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildActionCard(items[index], isComplete);
      },
    );
  }

  Widget _buildActionCard(ActionItemEms item, bool isComplete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // group bên trái
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.device,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.issueType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // badge bên phải
                          _buildStatusBadge(item.statusDisplay),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.descriptionOfIssue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Details Grid
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildInfoItem(
            //         icon: Icons.tag,
            //         label: 'Issue ID',
            //         value: item.actionCode,
            //       ),
            //     ),
            //     Expanded(
            //       child: _buildInfoItem(
            //         icon: Icons.person_outline,
            //         label: 'Creator',
            //         value: item.createdByName ?? '-',
            //       ),
            //     ),
            //     Expanded(
            //       child: _buildInfoItem(
            //         icon: Icons.check_circle_outline,
            //         label: 'Action Plans',
            //         value: '${item.doneCount ?? '0'}/${item.planCount}',
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildInfoItem(
            //         icon: Icons.calendar_today_outlined,
            //         label: 'Created Date',
            //         value: item.createdAt,
            //       ),
            //     ),
            //     Expanded(
            //       child: _buildInfoItem(
            //         icon: Icons.event_outlined,
            //         label: 'Planned Date',
            //         value: item.plannedMaxDate ?? '-',
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 4),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    final provider = Provider.of<IssueActionProvider>(
                      context,
                      listen: false,
                    );
                    provider.fetchPlans(
                      item.actionPk,
                    ); // load kế hoạch mới nhất
                    showDetailDialog(context, item.actionPk, item.issueId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, // nền xám nhẹ
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_sharp,
                          size: 24,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.detail,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isComplete)
                  GestureDetector(
                    onTap: () async {
                      final provider = Provider.of<IssueActionProvider>(
                        context,
                        listen: false,
                      );
                      // TODO
                      await provider.approveAction(item.actionPk);

                      // Nếu muốn có thông báo Snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Action approved successfully"),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8), // khoảng cách trong
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(8), // bo góc
                      ),
                      child: Icon(
                        Icons.check_box_outlined,
                        color: Colors.grey.shade100,
                        size: 24,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (isComplete)
                  GestureDetector(
                    onTap: () async {
                      final provider = Provider.of<IssueActionProvider>(
                        context,
                        listen: false,
                      );

                      await provider.rejectedAction(item.actionPk);

                      // Nếu muốn có thông báo Snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Action Rejected successfully"),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8), // khoảng cách trong
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8), // bo góc
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey.shade100,
                        size: 24,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this action?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      // await provider.delete(item.id);
                      final provider = Provider.of<IssueActionProvider>(
                        context,
                        listen: false,
                      );
                      await provider.deleteAction(item.actionPk);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Action deleted successfully"),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8), // khoảng cách trong
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, // nền xám nhẹ
                      borderRadius: BorderRadius.circular(8), // bo góc
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
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

  void showDetailDialog(BuildContext context, int actionId, String deviceId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(8),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Consumer<IssueActionProvider>(
              builder: (context, provider, child) {
                final action = provider.actions
                    .where((a) => a.actionPk == actionId)
                    .firstOrNull;

                if (action == null) {
                  return const Center(child: Text("Action not found"));
                }

                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with modern styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.issue} - $deviceId",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade700,
                            size: 30,
                          ),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // màu của đường kẻ
                      thickness: 1, // độ dày
                      indent: 5, // khoảng cách từ trái
                      endIndent: 5, // khoảng cách từ phải
                    ),
                    const SizedBox(height: 2),

                    // Modern Action Info Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2563EB).withOpacity(0.08),
                            const Color(0xFF1E40AF).withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            action.descriptionOfIssue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                            softWrap: true, // Cho phép xuống hàng
                            overflow: TextOverflow.visible,
                          ),
                          // Dòng 2: 3 cột nằm ngang
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildModernInfoRow(
                                  label: AppLocalizations.of(context)!.issueid,
                                  value: action.issueId,
                                  isBold: true,
                                ),
                              ),
                              Expanded(
                                child: _buildModernInfoRow(
                                  label: AppLocalizations.of(context)!.creator,
                                  value: action.createdBy,
                                ),
                              ),
                              Expanded(
                                child: _buildModernInfoRow(
                                  label: AppLocalizations.of(context)!.status,
                                  value: action.actionStatus,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Plans Section Header
                    Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 20,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${AppLocalizations.of(context)!.actionplans} (${action.plans?.length ?? 0})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Plans List with modern design
                    Expanded(
                      child: action.plans == null || action.plans!.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.inbox_outlined,
                                      size: 56,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.noActionPlansAvailable,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: action.plans!.length,
                              itemBuilder: (context, index) {
                                final plan = action.plans![index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 12,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 12,
                                      children: [
                                        // Plan header with ID and status
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    plan.planText,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.actionid}: ${plan.planCode}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  plan.status,
                                                ).withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _getStatusColor(
                                                    plan.status,
                                                  ).withOpacity(0.3),

                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    plan.status == "done"
                                                        ? Icons.check_circle
                                                        : Icons.schedule,
                                                    size: 14,
                                                    color: _getStatusColor(
                                                      plan.status,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    plan.status,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _getStatusColor(
                                                        plan.status,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 1),
                                        // Plan metadata
                                        Row(
                                          children: [
                                            if (plan.estDate != null) ...[
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                plan.estDate ?? '',
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
                                              const SizedBox(width: 8),
                                              Text(
                                                plan.ownerName ?? '',
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
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernInfoRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280), // màu xám nhạt
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4), // khoảng cách giữa label và value
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1F2937), // màu chữ chính
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF10B981);
      case 'todo':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFEF4444);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (status.toLowerCase().contains('progress')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      icon = Icons.pending_outlined;
    } else if (status.toLowerCase().contains('open')) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
      icon = Icons.radio_button_unchecked;
    } else if (status.toLowerCase().contains('complete')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String text,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 36,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) onTap();
        },
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
