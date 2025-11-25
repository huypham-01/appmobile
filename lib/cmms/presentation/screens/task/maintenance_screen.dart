// screens/inspection_list_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/cmms/presentation/screens/task/maintenance_detail_screen.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/task_equipment_today.dart';
import '../../../data/services/task_equipment_today_service.dart';
import '../equipment/equipment_detail_bottomsheet.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<MaintenanceScreen>
    with TickerProviderStateMixin {
  late Future<List<TaskMaintenance>> futureInspections;
  late TabController _tabController;

  List<TaskMaintenance> allInspections = [];
  List<TaskMaintenance> incompleteInspections = [];
  List<TaskMaintenance> completedInspections = [];

  List<TaskMaintenance> filteredIncompleteInspections = [];
  List<TaskMaintenance> filteredCompletedInspections = [];

  // Filter variables
  String? selectedCategory;
  String? selectedFamily;
  String searchQuery = '';
  bool isFilterExpanded = false; // Add this line

  // Date range variables
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;

  List<String> categories = [];
  List<String> families = [];
  List<String> filteredFamilies = [];
  final today = DateTime.now();
  // Controllers
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with today's date

    selectedDateFrom = today;
    selectedDateTo = today;

    futureInspections = InspectionService.fetchInspectionsMaintenance();
    _loadInspections();

    // Listen to tab changes to apply filters when switching tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInspections() async {
    if (selectedDateFrom == null || selectedDateTo == null) return;

    try {
      final inspections = await InspectionService.fetchInspectionsMaintenance(
        dateFrom: selectedDateFrom!,
        dateTo: selectedDateTo!,
      );
      setState(() {
        allInspections = inspections;
        _separateInspectionsByStatus();
        _extractFilterOptions();
        _applyFilters();
      });
    } catch (e) {
      print('Error loading inspections: $e');
    }
  }

  void _separateInspectionsByStatus() {
    incompleteInspections = allInspections.where((inspection) {
      return inspection.done < inspection.total;
    }).toList();

    completedInspections = allInspections.where((inspection) {
      return inspection.done >= inspection.total;
    }).toList();
  }

  void _extractFilterOptions() {
    final categorySet = <String>{};
    final familySet = <String>{};

    for (final inspection in allInspections) {
      if (inspection.category.isNotEmpty) {
        categorySet.add(inspection.category);
      }
      // if (inspection.family.isNotEmpty) {
      //   familySet.add(inspection.family);
      // }
    }

    categories = categorySet.toList()..sort();
    families = familySet.toList()..sort();
    filteredFamilies = families;
  }

  void _applyFilters() {
    setState(() {
      // Filter incomplete inspections
      filteredIncompleteInspections = _filterInspections(incompleteInspections);

      // Filter completed inspections
      filteredCompletedInspections = _filterInspections(completedInspections);
    });
  }

  List<TaskMaintenance> _filterInspections(List<TaskMaintenance> inspections) {
    return inspections.where((inspection) {
      // Category filter
      final categoryMatch =
          selectedCategory == null ||
          selectedCategory == 'All' ||
          inspection.category == selectedCategory;

      // Family filter
      // final familyMatch =
      //     selectedFamily == null ||
      //     selectedFamily == 'All' ||
      //     inspection.family == selectedFamily;

      // Search filter
      final searchMatch =
          searchQuery.isEmpty ||
          inspection.machineId.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          inspection.category.toLowerCase().contains(searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  Future<void> _selectDateFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        selectedDateFrom = picked;
        // If date_to is before date_from, update date_to
        if (selectedDateTo != null && selectedDateTo!.isBefore(picked)) {
          selectedDateTo = picked;
        }
      });
      _refreshData();
    }
  }

  Future<void> _selectDateTo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTo ?? DateTime.now(),
      firstDate: selectedDateFrom ?? DateTime(2020),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        selectedDateTo = picked;
      });
      _refreshData();
    }
  }

  void _refreshData() {
    if (selectedDateFrom != null && selectedDateTo != null) {
      setState(() {
        futureInspections = InspectionService.fetchInspectionsMaintenance();
      });
      _loadInspections();
    }
  }

  // void _onCategoryChanged(String? category) {
  //   setState(() {
  //     selectedCategory = category;
  //     selectedFamily = null; // Reset family when category changes

  //     if (category == null || category == 'All') {
  //       filteredFamilies = families;
  //     } else {
  //       // Filter families based on selected category
  //       final familySet = <String>{};
  //       for (final inspection in allInspections) {
  //         if (inspection.category == category && inspection.family.isNotEmpty) {
  //           familySet.add(inspection.family);
  //         }
  //       }
  //       filteredFamilies = familySet.toList()..sort();
  //     }
  //   });
  //   _applyFilters();
  // }

  void _onFamilyChanged(String? family) {
    setState(() {
      selectedFamily = family;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedFamily = null;
      searchQuery = '';
      _searchController.clear();
      filteredFamilies = families;
    });
    _applyFilters();
  }

  bool get _hasActiveFilters {
    return selectedCategory != null ||
        selectedFamily != null ||
        searchQuery.isNotEmpty;
  }

  // Widget _buildDateRangeSection() {
  //   final dateFormat = DateFormat('dd/MM/yyyy');
  //   final isTablet = MediaQuery.of(context).size.width > 600;

  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isTablet ? 16 : 8,
  //       vertical: isTablet ? 12 : 8,
  //     ),
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.date_range, size: isTablet ? 20 : 16, color: cusBlue),
  //         SizedBox(width: isTablet ? 8 : 4),

  //         // From Date
  //         Expanded(
  //           child: InkWell(
  //             onTap: _selectDateFrom,
  //             child: Container(
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: isTablet ? 12 : 8,
  //                 vertical: isTablet ? 10 : 6,
  //               ),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'From: ',
  //                     style: TextStyle(
  //                       fontSize: isTablet ? 12 : 10,
  //                       color: Colors.grey.shade600,
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: Text(
  //                       selectedDateFrom != null
  //                           ? dateFormat.format(selectedDateFrom!)
  //                           : '--/--/----',
  //                       style: TextStyle(
  //                         fontSize: isTablet ? 14 : 12,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),

  //         SizedBox(width: isTablet ? 8 : 4),

  //         // To Date
  //         Expanded(
  //           child: InkWell(
  //             onTap: _selectDateTo,
  //             child: Container(
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: isTablet ? 12 : 8,
  //                 vertical: isTablet ? 10 : 6,
  //               ),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'To: ',
  //                     style: TextStyle(
  //                       fontSize: isTablet ? 12 : 10,
  //                       color: Colors.grey.shade600,
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: Text(
  //                       selectedDateTo != null
  //                           ? dateFormat.format(selectedDateTo!)
  //                           : '--/--/----',
  //                       style: TextStyle(
  //                         fontSize: isTablet ? 14 : 12,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSearchAndFilterSection() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(31, 56, 53, 53),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Always visible filter header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 10 : 8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: isTablet ? 18 : 16,
                  color: cusBlue,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  AppLocalizations.of(context)!.filters,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: cusBlue,
                  ),
                ),

                // Filter indicators
                if (_hasActiveFilters) ...[
                  SizedBox(width: isTablet ? 8 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 6 : 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cusBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getActiveFilterCount(),
                      style: TextStyle(
                        fontSize: isTablet ? 10 : 9,
                        color: cusBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Clear filters button
                if (_hasActiveFilters)
                  InkWell(
                    onTap: _clearFilters,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 6,
                        vertical: isTablet ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                // Expand/Collapse button for mobile
                if (!isTablet)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isFilterExpanded = !isFilterExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 2 : 2),
                      child: Icon(
                        isFilterExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                        color: cusBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Expandable filter content
          // if (isTablet || isFilterExpanded)
          //   Container(
          //     padding: EdgeInsets.fromLTRB(
          //       isTablet ? 12 : 8,
          //       0,
          //       isTablet ? 12 : 8,
          //       isTablet ? 12 : 6,
          //     ),
          //     child: Column(
          //       children: [
          //         // Filter Dropdowns - Stack on mobile, side by side on tablet
          //         // if (isTablet)
          //         Row(
          //           children: [
          //             Expanded(
          //               child: _buildFilterDropdown(
          //                 label: 'Category',
          //                 value: selectedCategory,
          //                 items: ['All', ...categories],
          //                 onChanged: _onCategoryChanged,
          //                 isCompact: false,
          //               ),
          //             ),
          //             const SizedBox(width: 12),
          //             Expanded(
          //               child: _buildFilterDropdown(
          //                 label: 'Family',
          //                 value: selectedFamily,
          //                 items: ['All', ...filteredFamilies],
          //                 onChanged: _onFamilyChanged,
          //                 isCompact: false,
          //               ),
          //             ),
          //           ],
          //         ),

          //         // else
          //         //   Column(
          //         //     children: [
          //         //       _buildFilterDropdown(
          //         //         label: 'Category',
          //         //         value: selectedCategory,
          //         //         items: ['All', ...categories],
          //         //         onChanged: _onCategoryChanged,
          //         //         isCompact: true,
          //         //       ),
          //         //       const SizedBox(height: 6),
          //         //       _buildFilterDropdown(
          //         //         label: 'Family',
          //         //         value: selectedFamily,
          //         //         items: ['All', ...filteredFamilies],
          //         //         onChanged: _onFamilyChanged,
          //         //         isCompact: true,
          //         //       ),
          //         //     ],
          //         //   ),
          //         SizedBox(height: isTablet ? 8 : 6),

          //         // Results Counter
          //         _buildResultsCounter(),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  String _getActiveFilterCount() {
    int count = 0;
    if (selectedCategory != null) count++;
    if (selectedFamily != null) count++;
    return '$count active';
  }

  Widget _buildResultsCounter() {
    final currentTab = _tabController.index;
    final currentFiltered = currentTab == 0
        ? filteredIncompleteInspections
        : filteredCompletedInspections;
    final currentTotal = currentTab == 0
        ? incompleteInspections
        : completedInspections;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total: ${currentFiltered.length} tasks',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        if (_hasActiveFilters)
          Text(
            'Filtered from ${currentTotal.length} tasks',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isCompact = false,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      height: isCompact ? 28 : (isTablet ? 36 : 32), // Giảm chiều cao container
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true, // Giảm chiều cao
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 10,
            vertical: isTablet ? 4 : 2, // Giảm padding dọc
          ),
          labelStyle: TextStyle(
            fontSize: isTablet ? 15 : 13, // Giảm kích thước chữ label
            color: Colors.grey.shade600,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item == 'All' ? null : item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
              ), // Giảm kích thước chữ item
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        isDense: true, // Đảm bảo nhỏ gọn
        icon: Icon(
          Icons.arrow_drop_down,
          color: cusBlue, // Đảm bảo cusBlue đã được định nghĩa
          size: isTablet ? 18 : 16, // Giảm kích thước icon
        ),
        style: TextStyle(fontSize: isTablet ? 12 : 11), // Giảm kích thước chữ
        dropdownColor: Colors.white,
        menuMaxHeight: 200, // Giới hạn chiều cao menu dropdown
      ),
    );
  }

  Widget _buildTasksList(List<TaskMaintenance> inspections) {
    if (inspections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters
                  ? AppLocalizations.of(context)!.noTasksFound
                  : AppLocalizations.of(context)!.noTasksAvailable,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters
                  ? AppLocalizations.of(context)!.adjustFiltersHint
                  : AppLocalizations.of(context)!.noTasksInCategory,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 8, right: 8),
      itemCount: inspections.length,
      itemBuilder: (context, index) {
        final inspection = inspections[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Main content area
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaintenanceDetailScreen(
                                uuid: inspection.uuid,
                                equipmentId: inspection.machineId,
                                dateFrom: selectedDateFrom!,
                                dateTo: selectedDateTo!,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with machine info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cusBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${AppLocalizations.of(context)!.machineid}: ${inspection.machineId}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: cusBlue,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Icon(
                                  //   Icons.precision_manufacturing,
                                  //   size: 20,
                                  //   color: Colors.grey[400],
                                  // ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Machine details
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      // icon: Icons.category_outlined,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.categoryLabel,
                                      value: inspection.category,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Expanded(
                                  //   child: _buildInfoRow(
                                  //     // icon: Icons.account_tree_outlined,
                                  //     label: "Model",
                                  //     value: inspection.model,
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildInfoRow(
                                      // icon: Icons.account_tree_outlined,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.cavities,
                                      value: inspection.cavity,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Progress section
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.progressLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: inspection.total == inspection.done
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${inspection.done}/${inspection.total}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            inspection.done == inspection.total
                                            ? Colors.green[700]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Enhanced progress bar
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: inspection.total > 0
                                          ? inspection.done / inspection.total
                                          : 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green[400]!,
                                              Colors.green[600]!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action button area
                  Container(
                    width: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [cusBlue, cusBlue.withOpacity(0.9)],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                            ),
                            builder: (_) => Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: EquipmentDetailBottomSheet(
                                equipment: inspection,
                              ),
                            ),
                          );

                          FocusScope.of(context).unfocus();
                        },
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.detail,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: cusBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shadowColor: const Color.fromARGB(0, 255, 255, 255),
        title: Text(
          AppLocalizations.of(context)!.maintenanceMachineTitle,
          style: const TextStyle(color: Colors.white, fontSize: 21),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 67, 103, 164),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: const Color.fromARGB(255, 19, 18, 18),
              unselectedLabelColor: const Color.fromARGB(255, 15, 15, 15),
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              indicatorPadding: const EdgeInsets.all(4),
              tabs: [
                _buildTab(
                  Icons.access_time,
                  AppLocalizations.of(context)!.pending,
                ),
                _buildTab(
                  Icons.check_circle,
                  AppLocalizations.of(context)!.complete,
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Incomplete Tab
          Column(
            children: [
              // _buildDateRangeSection(),
              // _buildSearchAndFilterSection(),
              Expanded(
                child: FutureBuilder<List<TaskMaintenance>>(
                  future: futureInspections,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noTasksFound,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildTasksList(filteredIncompleteInspections);
                  },
                ),
              ),
            ],
          ),

          // Completed Tab
          Column(
            children: [
              // _buildDateRangeSection(),
              // _buildSearchAndFilterSection(),
              Expanded(
                child: FutureBuilder<List<TaskMaintenance>>(
                  future: futureInspections,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noInspectionsFound,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildTasksList(filteredCompletedInspections);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Tab _buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 13)),
        ],
      ),
    );
  }
}

Widget _buildInfoRow({required String label, required String value}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        "$label: ",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 1),
      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
