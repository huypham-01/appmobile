import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../../data/services/equipment_service.dart';
import 'equipment_detail_bottomsheet.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  // Data variables
  List<Map<String, String>> equipments = [];
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 0;
  bool hasMoreData = true;

  // Filter & Search variables
  String searchQuery = "";
  String selectedFamilys = "All";
  String selectedCategory = "All";

  List<String> categories = ["All"];
  List<String> familys = ["All"];

  // Controllers
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Khởi tạo màn hình
  void _initializeScreen() {
    fetchEquipments();
    _scrollController.addListener(_scrollListener);
  }

  /// Lắng nghe sự kiện scroll để load more
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (hasMoreData && !isLoading) {
        loadMoreEquipments();
      }
    }
  }

  /// Lấy dữ liệu equipment từ API
  Future<void> fetchEquipments({
    int page = 1,
    bool isRefresh = false,
    bool showLoading = true,
  }) async {
    // print(
    //   '🚀 [EquipmentScreen] fetchEquipments called - page: $page, isRefresh: $isRefresh',
    // );

    if (isRefresh) {
      setState(() {
        currentPage = 1;
        hasMoreData = true;
        errorMessage = '';
      });
    }

    if (showLoading) {
      setState(() {
        isLoading = true;
        if (isRefresh) equipments.clear();
      });
    }

    try {
      // print('🔄 [EquipmentScreen] Calling EquipmentService.getEquipments...');
      final response = await EquipmentService.getEquipments(
        page: page,
        limit: 1000000, // Tăng limit để có nhiều data hơn
        search: searchQuery.isNotEmpty ? searchQuery : null,
        category: selectedCategory != "All" ? selectedCategory : null,
        status: selectedFamilys != "All" ? selectedFamilys : null,
      );

      // print('✅ [EquipmentScreen] API call successful. Response data:');
      // print('   - Status: ${response.status}');
      // print('   - Message: ${response.message}');
      // print('   - Data length: ${response.data.length}');
      // print('   - Total items: ${response.totalItems}');
      // print('   - Total pages: ${response.totalPages}');

      if (mounted) {
        final newEquipments = response.data
            .map((e) => e.toDisplayMap())
            .toList();
        // print(
        //   '🔄 [EquipmentScreen] Converting ${newEquipments.length} equipment(s) to display format',
        // );

        setState(() {
          if (page == 1 || isRefresh) {
            equipments = newEquipments;
            // print(
            //   '🔄 [EquipmentScreen] Replaced equipments list with ${equipments.length} items',
            // );
          } else {
            equipments.addAll(newEquipments);
            // print(
            //   '🔄 [EquipmentScreen] Added ${newEquipments.length} items, total: ${equipments.length}',
            // );
          }
          // ✅ Cập nhật categories luôn sau khi có equipments
          final categorySet = equipments
              .map((e) => e["category"] ?? "")
              .toSet();
          categories = ["All", ...categorySet.where((c) => c.isNotEmpty)];
          // Cập nhật family luôn
          final familySet = equipments.map((e) => e["family"] ?? "").toSet();
          familys = ["All", ...familySet.where((f) => f.isNotEmpty)];

          currentPage = page;
          totalPages = response.totalPages;
          hasMoreData = currentPage < totalPages;
          isLoading = false;
          errorMessage = '';
        });

        // print('✅ [EquipmentScreen] State updated successfully');
      }
    } on EquipmentException catch (e) {
      // print('🔴 [EquipmentScreen] EquipmentException: ${e.message}');
      if (mounted) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      // print('🔴 [EquipmentScreen] Unexpected error: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Lỗi không xác định: ${e.toString()}';
          isLoading = false;
        });
        _showErrorSnackBar('Lỗi không xác định');
      }
    }
  }

  /// Load thêm equipment (pagination)
  Future<void> loadMoreEquipments() async {
    if (!hasMoreData || isLoading) return;
    await fetchEquipments(page: currentPage + 1, showLoading: false);
  }

  /// Refresh danh sách equipment
  Future<void> refreshEquipments() async {
    await fetchEquipments(page: 1, isRefresh: true);
  }

  /// Tìm kiếm equipment
  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });

    // Debounce search để tránh gọi API quá nhiều
    _debounceSearch();
  }

  /// Debounce search
  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        fetchEquipments(page: 1, isRefresh: true);
      }
    });
  }

  /// Xóa text search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
    fetchEquipments(page: 1, isRefresh: true);
  }

  /// Thay đổi filter
  void _onFilterChanged() {
    fetchEquipments(page: 1, isRefresh: true);
  }

  /// Hiển thị error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'reload',
          textColor: Colors.white,
          onPressed: refreshEquipments,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Lọc equipment theo search và filter
  List<Map<String, String>> get filteredEquipments {
    return equipments.where((equipment) {
      final matchesSearch =
          searchQuery.isEmpty ||
          equipment["name"]!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          equipment["model"]!.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus =
          selectedFamilys == "All" || equipment["family"] == selectedFamilys;

      final matchesCategory =
          selectedCategory == "All" ||
          equipment["category"] == selectedCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildErrorBanner(),
            // _buildSearchField(),
            _buildFilterRow(),
            _buildEquipmentList(),
          ],
        ),
      ),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cusBlue,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.listEquipment,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.bug_report, color: Colors.white),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => EquipmentDebugScreen()),
        //     );
        //   },
        //   tooltip: 'Debug',
        // ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: refreshEquipments,
          tooltip: 'reload...',
        ),
      ],
    );
  }

  /// Build Error Banner
  Widget _buildErrorBanner() {
    if (errorMessage.isEmpty || equipments.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade100,
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          TextButton(
            onPressed: refreshEquipments,
            child: const Text('reload....'),
          ),
        ],
      ),
    );
  }

  /// Build Search Field
  // Widget _buildSearchField() {
  //   return Padding(
  //     padding: const EdgeInsets.all(12),
  //     child: TextField(
  //       controller: _searchController,
  //       onChanged: _onSearchChanged,
  //       focusNode: _searchFocusNode,
  //       decoration: InputDecoration(
  //         hintText: "Search equipment...",
  //         prefixIcon: const Icon(Icons.search, color: Colors.grey),
  //         suffixIcon: searchQuery.isNotEmpty
  //             ? IconButton(
  //                 icon: const Icon(Icons.clear, color: Colors.grey),
  //                 onPressed: _clearSearch,
  //               )
  //             : null,
  //         filled: true,
  //         fillColor: Colors.white,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide.none,
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: const BorderSide(
  //             color: Color.fromARGB(179, 186, 191, 196),
  //             width: 1.5,
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: const BorderSide(color: Colors.blue, width: 1.5),
  //         ),
  //         contentPadding: const EdgeInsets.symmetric(
  //           vertical: 0,
  //           horizontal: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Build Filter Row
  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchHint,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(179, 186, 191, 196),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Header with Clear All button
          // Row(
          //   children: [
          //     Icon(Icons.filter_list, color: cusBlue, size: 18),
          //     const SizedBox(width: 8),
          //     Text(
          //       'Filters',
          //       style: TextStyle(
          //         fontSize: 15,
          //         fontWeight: FontWeight.bold,
          //         color: cusBlue,
          //       ),
          //     ),
          //     const Spacer(),
          //     if (selectedFamilys != "All" || selectedCategory != "All")
          //       TextButton(
          //         onPressed: _clearAllFilters,
          //         child: const Text(
          //           'Clear All',
          //           style: TextStyle(color: Colors.red, fontSize: 14),
          //         ),
          //       ),
          //   ],
          // ),
          // const SizedBox(height: 8),
          // Dropdowns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Family',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w500,
                    //     color: cusBlue,
                    //   ),
                    // ),
                    const SizedBox(height: 4),
                    _buildDropdown(
                      value: selectedFamilys,
                      items: familys.where((item) => item != "All").toList(),
                      onChanged: (value) {
                        setState(() => selectedFamilys = value ?? "All");
                        _onFilterChanged();
                      },
                      hint: AppLocalizations.of(context)!.selectfamily,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Category',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w500,
                    //     color: cusBlue,
                    //   ),
                    // ),
                    const SizedBox(height: 4),
                    _buildDropdown(
                      value: selectedCategory,
                      items: categories.where((item) => item != "All").toList(),
                      onChanged: (value) {
                        setState(() => selectedCategory = value ?? "All");
                        _onFilterChanged();
                      },
                      hint: AppLocalizations.of(context)!.selectCategory,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filter info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.show} ${filteredEquipments.length}/${equipments.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (selectedFamilys != "All" || selectedCategory != "All")
                TextButton(
                  onPressed: _clearAllFilters,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ), // 👈 giảm khoảng đệm
                    minimumSize: Size.zero, // 👈 bỏ kích thước tối thiểu
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // 👈 làm nút gọn sát nội dung
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.clearFilters,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clear all filters
  void _clearAllFilters() {
    setState(() {
      selectedFamilys = "All";
      selectedCategory = "All";
    });
    _onFilterChanged();
  }

  /// Build Dropdown
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value == "All" ? null : value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          icon: Icon(Icons.arrow_drop_down, color: cusBlue),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Build Equipment List
  Widget _buildEquipmentList() {
    return Expanded(child: _buildListContent());
  }

  /// Build List Content
  Widget _buildListContent() {
    if (equipments.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (equipments.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: refreshEquipments,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: filteredEquipments.length + _getLoadMoreItemCount(),
        itemBuilder: (context, index) {
          if (index < filteredEquipments.length) {
            return _buildEquipmentItem(filteredEquipments[index]);
          }
          return _buildLoadMoreItem();
        },
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage.isNotEmpty
                ? 'Failed to load data'
                : 'No equipment available',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: refreshEquipments,
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  /// Get Load More Item Count
  int _getLoadMoreItemCount() {
    if (isLoading && equipments.isNotEmpty) return 1;
    if (hasMoreData && !isLoading) return 1;
    return 0;
  }

  /// Build Load More Item
  Widget _buildLoadMoreItem() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: loadMoreEquipments,
                child: const Text('Load more'),
              ),
      ),
    );
  }

  /// Build Equipment Item
  Widget _buildEquipmentItem(Map<String, String> equipment) {
    final statusColor = _getStatusColor(equipment["status"]);

    return InkWell(
      onTap: () => _onEquipmentTap(equipment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // _buildEquipmentImage(),
            // const SizedBox(width: 12),
            _buildEquipmentInfo(equipment, statusColor),
          ],
        ),
      ),
    );
  }

  /// Build Equipment Image
  // Widget _buildEquipmentImage() {
  //   return Container(
  //     width: 90,
  //     height: 130,
  //     decoration: const BoxDecoration(
  //       image: DecorationImage(
  //         image: AssetImage("assets/images/he.jpg"),
  //         fit: BoxFit.cover,
  //       ),
  //       borderRadius: BorderRadius.all(Radius.circular(8)),
  //     ),
  //   );
  // }

  /// Build Equipment Info
  Widget _buildEquipmentInfo(Map<String, String> equipment, Color statusColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEquipmentHeader(equipment, statusColor),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  AppLocalizations.of(context)!.categoryLabel,
                  "${equipment["category"]}",
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  AppLocalizations.of(context)!.manufacturer,
                  "${equipment["manufacturer"]}",
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  AppLocalizations.of(context)!.family,
                  "${equipment["family"]}",
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  AppLocalizations.of(context)!.cavityLavel,
                  "${equipment["cavity"]}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Equipment Header
  Widget _buildEquipmentHeader(
    Map<String, String> equipment,
    Color statusColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            equipment["name"]!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(31, 155, 148, 148),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            equipment["unit"]!,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Build Info Row
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Get Status Color
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Maintenance":
        return Colors.orange;
      case "Inactive":
      default:
        return Colors.red;
    }
  }

  /// Handle Equipment Tap
  Future<void> _onEquipmentTap(Map<String, String> equipment) async {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      return;
    }

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        builder: (_) => EquipmentDetailBottomSheet(equipment: equipment),
      );

      // Unfocus sau khi đóng bottom sheet
      Future.delayed(const Duration(milliseconds: 10), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      });
    } catch (e) {
      _showErrorSnackBar('Không thể mở chi tiết equipment');
    }
  }
}
