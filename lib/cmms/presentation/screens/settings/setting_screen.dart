import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:mobile/utils/constants.dart';

import '../../../data/services/api_service.dart';
import '../equipment/equipment_detail_WI_screen.dart';

class WorkingInstructionsScreen extends StatefulWidget {
  const WorkingInstructionsScreen({super.key});

  @override
  State<WorkingInstructionsScreen> createState() =>
      _WorkingInstructionsScreenState();
}

class _WorkingInstructionsScreenState extends State<WorkingInstructionsScreen> {
  String? selectedCategory;
  String? selectedType;
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  List<WorkingInstruction> allInstructions = [];

  // API endpoint
  final String apiUrl =
      '$baseUrl/cip3/index.php?c=WorkingInstructionController&m=getAllWi&limit=10000';

  @override
  void initState() {
    super.initState();
    selectedCategory = 'All';
    selectedType = 'All';
    _loadWorkingInstructions();
  }

  Future<void> _loadWorkingInstructions() async {
    final token = await ApiService.getToken();
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          final List<dynamic> instructionsJson = jsonData['data'];

          setState(() {
            allInstructions = instructionsJson
                .map((json) => WorkingInstruction.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Failed to load data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadWorkingInstructions();
  }

  List<WorkingInstruction> get filteredInstructions {
    return allInstructions.where((instruction) {
      final matchesCategory =
          selectedCategory == null ||
          selectedCategory == 'All' ||
          instruction.category == selectedCategory;

      final matchesType =
          selectedType == null ||
          selectedType == 'All' ||
          instruction.type == selectedType;

      final matchesSearch =
          searchQuery.isEmpty ||
          instruction.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          instruction.code.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesType && matchesSearch;
    }).toList();
  }

  List<String> get availableCategories {
    final categories = allInstructions.map((e) => e.category).toSet().toList();
    categories.sort();
    categories.insert(0, 'All');
    return categories;
  }

  List<String> get availableTypes {
    final types = allInstructions.map((e) => e.type).toSet().toList();
    types.sort();
    types.insert(0, 'All');
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Modern Search and Filter Section
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Enhanced Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter Row with Dropdowns
                    if (!isLoading && allInstructions.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.categoryLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                  items: availableCategories
                                      .map(
                                        (category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.typeLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: selectedType,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                  items: availableTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedType = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Results Header
              if (!isLoading) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredInstructions.length} ${AppLocalizations.of(context)!.resultsFound}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          if (selectedCategory != 'All' ||
                              selectedType != 'All' ||
                              searchQuery.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'All';
                                  selectedType = 'All';
                                  searchQuery = '';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.clearFilters,
                              ),
                            ),
                          IconButton(
                            onPressed: _refreshData,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const Divider(),
              ],
              // Content Area
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loadingInstructions),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingData,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (allInstructions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noInstructionsAvailable,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(AppLocalizations.of(context)!.refreshButton),
            ),
          ],
        ),
      );
    }

    if (filteredInstructions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noInstructionsFound,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.adjustFiltersHint,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredInstructions.length,
      itemBuilder: (context, index) {
        final instruction = filteredInstructions[index];
        print(instruction.schema);
        return InstructionCard(
          instruction: instruction,
          onTap: () {
            // Handle tap - navigate to detail screen
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) =>
                    EquipmentDetailWiScreen(schemaString: instruction.schema),
              ),
            );
          },
        );
      },
    );
  }
}

class InstructionCard extends StatelessWidget {
  final WorkingInstruction instruction;
  final VoidCallback onTap;

  const InstructionCard({
    Key? key,
    required this.instruction,
    required this.onTap,
  }) : super(key: key);

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      default:
        return const Color.fromARGB(255, 122, 115, 115);
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      // case 'daily inspection':
      //   return Colors.purple;
      // case 'maintenance level 1':
      //   return Colors.amber;
      // case 'maintenance level 2':
      //   return Colors.red;
      default:
        return const Color.fromARGB(255, 102, 96, 96);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        shadowColor: const Color.fromARGB(255, 45, 45, 45).withOpacity(0.5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header Row: code bên trái, category + type bên phải
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Code bên trái
                    Text(
                      instruction.code,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    // Category + Type bên phải
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getCategoryColor(
                              instruction.category,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: getCategoryColor(
                                instruction.category,
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            instruction.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: getCategoryColor(instruction.category),
                            ),
                          ),
                        ),

                        // Type Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getMaintenanceColor(
                              instruction.type,
                            ).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: getTypeColor(
                                instruction.type,
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            instruction.type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: getTypeColor(instruction.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Name (bên dưới)
                Text(
                  instruction.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          instruction.frequency,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.updatedLabel}: ${instruction.updatedAt.split(' ')[0]}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkingInstruction {
  final String id;
  final String code;
  final String name;
  final String type;
  final String category;
  final String frequency;
  final String updatedAt;
  final String unitType;
  final String unitValue;
  final String schema;

  WorkingInstruction({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.category,
    required this.frequency,
    required this.updatedAt,
    this.unitType = '',
    this.unitValue = '',
    this.schema = '',
  });

  factory WorkingInstruction.fromJson(Map<String, dynamic> json) {
    return WorkingInstruction(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      frequency: json['frequency'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      unitType: json['unit_type'] ?? '',
      unitValue: json['unit_value'] ?? '',
      schema: json['schema'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'category': category,
      'frequency': frequency,
      'updated_at': updatedAt,
      'unit_type': unitType,
      'unit_value': unitValue,
      'schema': schema,
    };
  }
}
