import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/fmcs/data/models/device_response_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import '../../data/models/machine_model.dart';

class SystemMachine extends StatefulWidget {
  const SystemMachine({super.key});

  @override
  State<SystemMachine> createState() => _SystemMachineState();
}

class _SystemMachineState extends State<SystemMachine> {
  late List<SystemCategory> systemCategories;
  late Future<List<LocationItem>> futureLocations;

  List<Device> devices = [];
  String selectedCategory = 'Mold';
  bool isCategoryExpanded = false;
  bool hasChanges = false;
  bool isLoading = true;
  String? errorMessage;
  bool canCreareDevie = false;
  bool canEditDevie = false;
  bool canDeletedDevie = false;

  final List<String> systemOrder = [
    "Mold",
    "Injection",
    "Tufting",
    "End-rounding",
    "Blister",
  ];

  final List<String> process = ["1st", "2nd", "3rd"];
  final List<String> moldType = ["Shift Insert", "Manual", "Auto"];

  @override
  void initState() {
    super.initState();
    _loadDevicesFromApi();
    _loadPermissions();
  }

  void _loadPermissions() async {
    canCreareDevie = await PermissionHelper.has("device.add.ems");
    canEditDevie = await PermissionHelper.has("device.update.ems");
    canDeletedDevie = await PermissionHelper.has("device.delete.ems");
    setState(() {});
  }

  Future<void> _loadDevicesFromApi() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await EmsApiService.fetchDevices();

      if (response != null && response.devices.isNotEmpty) {
        // Flatten tất cả devices từ tất cả systems
        List<Device> loadedDevices = [];
        response.devices.forEach((system, deviceList) {
          loadedDevices.addAll(deviceList);
        });

        setState(() {
          devices = loadedDevices;
          _loadCategories();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'error load data: $e';
        isLoading = false;
      });
      print('Error loading devices: $e');
    }
  }

  List<SystemCategory> _buildSystemCategories(List<Device> deviceList) {
    final Map<String, int> counts = {};
    for (var d in deviceList) {
      counts[d.displayType] = (counts[d.displayType] ?? 0) + 1;
    }

    List<SystemCategory> orderedCategories = [];
    for (var sys in systemOrder) {
      if (counts.containsKey(sys)) {
        orderedCategories.add(SystemCategory(name: sys, count: counts[sys]!));
      }
    }

    counts.forEach((key, value) {
      if (!systemOrder.contains(key)) {
        orderedCategories.add(SystemCategory(name: key, count: value));
      }
    });

    return orderedCategories;
  }

  void _loadCategories() {
    systemCategories = _buildSystemCategories(devices);
    if (!systemCategories.any((c) => c.name == selectedCategory)) {
      selectedCategory = systemCategories.isNotEmpty
          ? systemCategories.first.name
          : 'Mold';
    }
  }

  List<Device> get filteredDevices {
    List<Device> filtered = devices
        .where((device) => device.displayType == selectedCategory)
        .toList();

    filtered.sort((a, b) => a.deviceId.compareTo(b.deviceId));
    return filtered;
  }

  void _refreshData() {
    _loadDevicesFromApi();
  }

  void _showDeviceDialog({bool isEdit = false, Device? device}) {
    // 🔹 1. Khai báo controller cho từng ô
    final deviceIdController = TextEditingController();
    final familyController = TextEditingController();
    final cavitiesController = TextEditingController();
    final efficiencyController = TextEditingController();
    final historyCountController = TextEditingController();
    final modelController = TextEditingController();
    final manufacturerController = TextEditingController();
    final mftDateController = TextEditingController();
    final lowerLimitController = TextEditingController();
    final targetLimitController = TextEditingController();
    final upperLimitController = TextEditingController();
    final freqConnController = TextEditingController(text: "300");
    final freqLimitController = TextEditingController(text: "60");

    String selectedSystem = '';
    String selectedProcess = '';
    String selectedMoldType = '';

    // Populate data if editing
    if (isEdit && device != null) {
      deviceIdController.text = device.deviceId;
      familyController.text = device.product ?? '';
      cavitiesController.text = device.cavities?.toString() ?? '';
      efficiencyController.text = device.efficiencyLowerLimit ?? '';
      historyCountController.text = device.historyCount.toString();
      modelController.text = device.model ?? '';
      manufacturerController.text = device.manufacturer ?? '';
      mftDateController.text = device.manufacturingDate ?? '';
      lowerLimitController.text = device.lowerLimit ?? '';
      targetLimitController.text = device.targetLimit ?? '';
      upperLimitController.text = device.upperLimit ?? '';
      freqConnController.text = device.frequency.toString();
      freqLimitController.text = device.freqCheckLimit.toString();

      selectedSystem = device.displayType ?? '';
      selectedProcess = device.process ?? '';
      selectedMoldType = device.moldType ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                width: 900,
                constraints: const BoxConstraints(maxHeight: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Tiêu đề
                    Container(
                      padding: const EdgeInsets.only(left: 17, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit
                                ? AppLocalizations.of(context)!.editDevice
                                : AppLocalizations.of(context)!.addDevice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.close),
                            color: Colors.grey,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Nội dung form
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      AppLocalizations.of(
                                        context,
                                      )!.machineIDuniq,
                                      deviceIdController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDropdownField(
                                      AppLocalizations.of(context)!.machineType,
                                      systemOrder,
                                      selectedSystem,
                                      onChanged: (v) => setDialogState(() {
                                        selectedSystem = v ?? '';
                                      }),
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.systemTypeHint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      AppLocalizations.of(context)!.family,
                                      familyController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDropdownField(
                                      AppLocalizations.of(context)!.process,
                                      process,
                                      selectedProcess,
                                      onChanged: (v) => setDialogState(() {
                                        selectedProcess = v ?? '';
                                      }),
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.selectProcessHint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(context)!.numberofca,
                                      cavitiesController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDropdownField(
                                      AppLocalizations.of(context)!.moldtype,
                                      moldType,
                                      selectedMoldType,
                                      onChanged: (v) => setDialogState(() {
                                        selectedMoldType = v ?? '';
                                      }),
                                      hintText:
                                          '--${AppLocalizations.of(context)!.moldtype}--',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      AppLocalizations.of(
                                        context,
                                      )!.efficiencylimit,
                                      efficiencyController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(
                                        context,
                                      )!.historycount,
                                      historyCountController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      AppLocalizations.of(context)!.model,
                                      modelController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTextField(
                                      AppLocalizations.of(
                                        context,
                                      )!.manufacturer,
                                      manufacturerController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildDateField(
                                      AppLocalizations.of(context)!.mgfdate,
                                      mftDateController,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(context)!.lowerLimits,
                                      lowerLimitController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(
                                        context,
                                      )!.targetLimits,
                                      targetLimitController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(context)!.upperLimits,
                                      upperLimitController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(
                                        context,
                                      )!.freqChkConns,
                                      freqConnController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildNumberField(
                                      AppLocalizations.of(context)!.freqChkLims,
                                      freqLimitController,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 🔹 Nút hành động
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              //TODO
                              final data = {
                                'action': isEdit ? 'update' : 'add',
                                if (isEdit) 'id': device?.id.toString(),
                                'device_id': deviceIdController.text,
                                'display_type': selectedSystem.toLowerCase(),
                                'product': familyController.text,
                                'model': modelController.text,
                                'manufacturer': manufacturerController.text,
                                'manufacturing_date': mftDateController.text,
                                'cavities': cavitiesController.text,
                                'hole_per_brush': '',
                                'brushes_per_cycle': '',
                                'process': selectedProcess,
                                'mold_type': selectedMoldType,
                                'efficiency_lower_limit':
                                    efficiencyController.text,
                                'lower_limit': lowerLimitController.text,
                                'target_limit': targetLimitController.text,
                                'upper_limit': upperLimitController.text,
                                'frequency': freqConnController.text,
                                'freq_check_limit': freqLimitController.text,
                                'flex': "",
                                'history_count': historyCountController.text,
                              };

                              dynamic res;
                              if (isEdit) {
                                res = await EmsApiService.updateDevice(data);
                              } else {
                                res = await EmsApiService.addDevice(data);
                              }

                              if (res['status'] == 'success') {
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEdit
                                            ? AppLocalizations.of(
                                                context,
                                              )!.deviceUpdatedSuccess
                                            : AppLocalizations.of(
                                                context,
                                              )!.deviceAddedSuccess,
                                      ),
                                    ),
                                  );
                                  _refreshData();
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed: ${res['message'] ?? 'Unknown error'}',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isEdit
                                  ? AppLocalizations.of(context)!.updateDevice
                                  : AppLocalizations.of(context)!.addD,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String selectedValue, {
    ValueChanged<String?>? onChanged,
    String? hintText,
  }) {
    final List<String> fixedItems = List.from(items);
    String? displayValue = selectedValue.isNotEmpty ? selectedValue : null;
    if (displayValue != null && !fixedItems.contains(displayValue)) {
      fixedItems.insert(0, displayValue);
    }

    return Column(
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
        const SizedBox(height: 6),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  hintText ?? AppLocalizations.of(context)!.selectOption,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
              isExpanded: true,
              icon: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                width: 22,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              items: fixedItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Column(
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
        const SizedBox(height: 6),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true, // Không cho nhập tay
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    isDense: true,
                    hintText: 'yyyy-MM-dd',
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus(); // Ẩn bàn phím

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      final formattedDate =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      controller.text = formattedDate;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
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
        const SizedBox(height: 6),
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Container(
                width: 29,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          double current =
                              double.tryParse(controller.text) ?? 0;
                          controller.text = (current + 1).toStringAsFixed(0);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          double current =
                              double.tryParse(controller.text) ?? 0;
                          controller.text = (current - 1).toStringAsFixed(0);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
                    Navigator.pop(context);
                  },
                ),
                if (canCreareDevie) ...[
                  const PopupMenuDivider(),
                  _buildMenuItem(
                    context: context,
                    value: 'menu2',
                    icon: Icons.add_box,
                    text: AppLocalizations.of(context)!.addDevice,
                    onTap: () {
                      _showDeviceDialog();
                    },
                  ),
                ],

                const PopupMenuDivider(),
                _buildMenuItem(
                  context: context,
                  value: 'menu3',
                  icon: Icons.refresh,
                  text: AppLocalizations.of(context)!.reset,
                  onTap: () {
                    _refreshData();
                  },
                ),
                const PopupMenuDivider(),
                _buildMenuItem(
                  context: context,
                  value: 'menu4',
                  icon: Icons.arrow_back,
                  text: AppLocalizations.of(context)!.back,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.loadingDevices),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: Text(AppLocalizations.of(context)!.reset),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: isCategoryExpanded
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: systemCategories
                                          .map(
                                            (category) => _buildTab(
                                              category.name,
                                              isSelected:
                                                  selectedCategory ==
                                                  category.name,
                                              onTap: () {
                                                setState(() {
                                                  selectedCategory =
                                                      category.name;
                                                  isCategoryExpanded = false;
                                                });
                                              },
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: systemCategories
                                            .map(
                                              (category) => _buildTab(
                                                category.name,
                                                isSelected:
                                                    selectedCategory ==
                                                    category.name,
                                                onTap: () {
                                                  setState(() {
                                                    selectedCategory =
                                                        category.name;
                                                  });
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isCategoryExpanded = !isCategoryExpanded;
                                  });
                                },
                                icon: Icon(
                                  isCategoryExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                style: IconButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredDevices.isEmpty
                      ? Center(
                          child: Text(
                            'No devices found in $selectedCategory',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredDevices.length,
                          itemBuilder: (context, index) {
                            return _buildDeviceCard(filteredDevices[index]);
                          },
                        ),
                ),
              ],
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
      height: 28,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) onTap();
        },
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.machineid,
                    device.deviceId,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.family,
                    device.product!,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.model,
                    device.model == null ? "-" : device.model!,
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.mgf,
                    device.manufacturer == null ? "-" : device.manufacturer!,
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.mgfdate,
                    device.manufacturingDate == null
                        ? "-"
                        : device.manufacturingDate!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.cavities,
                    device.cavities == null ? "-" : device.cavities!.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.cap1h,
                    device.capacity == null ? "-" : device.capacity!.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.totalcount,
                    device.totalCount.toString(),
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.unit,
                    device.unit,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.hiscount,
                    device.historyCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.process,
                    device.process == null ? "-" : device.process!,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.efflimit,
                    device.efficiencyLowerLimit!,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.frecheckconnected,
                    device.frequency.toString(),
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.frechecklimit,
                    device.freqCheckLimit.toString(),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.of(context)!.moldtype,
                    device.moldType == null ? "-" : device.moldType!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSensorInfo(
                    AppLocalizations.of(context)!.limit,
                    device.lowerLimit,
                    device.targetLimit,
                    device.upperLimit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (canEditDevie) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeviceDialog(isEdit: true, device: device);
                      },
                      icon: const Icon(Icons.edit, size: 17),
                      label: Text(
                        AppLocalizations.of(context)!.edit,
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                ],

                if (canDeletedDevie) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade400,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.confirmDelete,
                                ),
                              ],
                            ),
                            content: Text(
                              "${AppLocalizations.of(context)!.deleteConfirmMsg} ${device.deviceId}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final result =
                                      await EmsApiService.deleteDevice(
                                        device.deviceId,
                                      );

                                  if (result["status"] == "success") {
                                    setState(() {
                                      hasChanges = true;
                                    });

                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );
                                    _refreshData();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Text('${device.deviceId} deleted'),
                                          ],
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result["message"] ??
                                              AppLocalizations.of(
                                                context,
                                              )!.deleteFailedMsg,
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: Text(AppLocalizations.of(context)!.delete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 2,
                      ),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorInfo(
    String label,
    String? lower,
    String? target,
    String? upper,
  ) {
    bool hasData =
        (lower != null && lower.isNotEmpty) ||
        (target != null && target.isNotEmpty) ||
        (upper != null && upper.isNotEmpty);

    if (!hasData) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                AppLocalizations.of(context)!.lower,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.target,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.upper,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'N/A',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              AppLocalizations.of(context)!.lower,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.target,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.upper,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              (lower != null && lower.isNotEmpty) ? lower : '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              (target != null && target.isNotEmpty) ? target : '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              (upper != null && upper.isNotEmpty) ? upper : '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
