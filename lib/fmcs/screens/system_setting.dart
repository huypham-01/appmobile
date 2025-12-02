import 'package:flutter/material.dart';
import 'package:mobile/fmcs/data/models/device_response_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import '../../utils/routes/fmcs_routes.dart';
import '../data/fmcs_api_service.dart';

class SystemSetting extends StatefulWidget {
  final List<DeviceItem> devices;
  final VoidCallback onDataChanged; // Kiểu hàm callback (không tham số)

  const SystemSetting({
    super.key,
    required this.devices,
    required this.onDataChanged,
  });

  @override
  State<SystemSetting> createState() => _SystemSettingState();
}

class _SystemSettingState extends State<SystemSetting> {
  late List<SystemCategory> systemCategories;
  late Future<List<LocationItem>> futureLocations;
  String selectedCategory = 'Air Conditioner';
  bool isCategoryExpanded = false;
  bool hasChanges = false;
  bool canCreateDevice = false;
  bool canEditeDevice = false;
  bool canDeletedDevice = false;

  final List<String> systemOrder = [
    "Air Conditioner",
    "Air Dryer",
    "Air Tank",
    "Chiller",
    "Compressor",
    "Cooling Tower",
    "End Air Pressure",
    "Factory Temperature",
    "Vacuum Tank",
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadLocations();
    loadPermissions();
  }

  void _loadLocations() {
    setState(() {
      futureLocations = FmcsApiService.fetchLocations();
    });
  }

  void loadPermissions() async {
    canCreateDevice = await PermissionHelper.has("devices.create");
    canEditeDevice = await PermissionHelper.has("device.update");
    canDeletedDevice = await PermissionHelper.has("device.delete");
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SystemSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra nếu devices thay đổi (so sánh reference hoặc nội dung nếu cần)
    if (oldWidget.devices != widget.devices) {
      _loadCategories(); // Reload categories từ devices mới
    }
  }

  List<SystemCategory> _buildSystemCategories(List<DeviceItem> devices) {
    final Map<String, int> counts = {};
    for (var d in devices) {
      counts[d.system] = (counts[d.system] ?? 0) + 1;
    }

    // Sắp xếp theo thứ tự định nghĩa trong systemOrder
    List<SystemCategory> orderedCategories = [];
    for (var sys in systemOrder) {
      if (counts.containsKey(sys)) {
        orderedCategories.add(SystemCategory(name: sys, count: counts[sys]!));
      }
    }

    // Nếu có system nào ngoài danh sách systemOrder thì thêm cuối
    counts.forEach((key, value) {
      if (!systemOrder.contains(key)) {
        orderedCategories.add(SystemCategory(name: key, count: value));
      }
    });

    return orderedCategories;
  }

  void _loadCategories() {
    // Tạo danh sách categories từ devices
    systemCategories = _buildSystemCategories(widget.devices);
  }

  List<DeviceItem> get filteredDevices {
    List<DeviceItem> devices;

    devices = widget.devices
        .where((device) => device.system == selectedCategory)
        .toList();

    // Sắp xếp theo String deviceId
    devices.sort((a, b) => a.deviceId.compareTo(b.deviceId));
    return devices;
  }

  Widget _buildLoadingDropdown(String label) {
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
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.loadingLocations,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(String label) {
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
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            AppLocalizations.of(context)!.errorLoadingLocations,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _showAddNewDeviceDialog() {
    // Controllers và variables cho form create
    final TextEditingController deviceIdController = TextEditingController();
    final TextEditingController frequencyController = TextEditingController();
    final TextEditingController freqCheckLimitController =
        TextEditingController();
    final TextEditingController tempLowerController = TextEditingController();
    final TextEditingController tempTargetController = TextEditingController();
    final TextEditingController tempUpperController = TextEditingController();
    final TextEditingController humidityLowerController =
        TextEditingController();
    final TextEditingController humidityTargetController =
        TextEditingController();
    final TextEditingController humidityUpperController =
        TextEditingController();
    final TextEditingController pressureLowerController =
        TextEditingController();
    final TextEditingController pressureTargetController =
        TextEditingController();
    final TextEditingController pressureUpperController =
        TextEditingController();

    String selectedSystem = '';
    LocationItem? selectedLocationItem;

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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(
                context,
              ).unfocus(); // Ẩn bàn phím khi tap ra ngoài ô input
            },
            child: StatefulBuilder(
              // Sử dụng StatefulBuilder để rebuild khi dropdown thay đổi
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
                              AppLocalizations.of(context)!.addDevice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.pop(context, hasChanges),
                              icon: const Icon(Icons.close),
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDropdownField(
                                      AppLocalizations.of(context)!.machineType,
                                      systemOrder,
                                      selectedSystem,
                                      onChanged: (v) {
                                        setDialogState(() {
                                          selectedSystem = v ?? '';
                                        });
                                      },
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.systemTypeHint,
                                    ),

                                    const SizedBox(height: 12),

                                    FutureBuilder<List<LocationItem>>(
                                      future: futureLocations,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return _buildLoadingDropdown(
                                            AppLocalizations.of(
                                              context,
                                            )!.locationLabel,
                                          );
                                        } else if (snapshot.hasError) {
                                          return _buildErrorDropdown(
                                            AppLocalizations.of(
                                              context,
                                            )!.locationLabel,
                                          );
                                        } else if (snapshot.hasData &&
                                            snapshot.data!.isNotEmpty) {
                                          final locationNames = snapshot.data!
                                              .map((l) => l.locationName)
                                              .toList();

                                          return _buildDropdownField(
                                            AppLocalizations.of(
                                              context,
                                            )!.locationLabel,
                                            locationNames,
                                            selectedLocationItem
                                                    ?.locationName ??
                                                '',
                                            onChanged: (v) {
                                              setDialogState(() {
                                                selectedLocationItem = snapshot
                                                    .data!
                                                    .firstWhere(
                                                      (l) =>
                                                          l.locationName == v,
                                                      orElse: () =>
                                                          throw Exception(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.noLocationsFound,
                                                          ),
                                                    );
                                              });
                                            },
                                            hintText: AppLocalizations.of(
                                              context,
                                            )!.selectLocationHint,
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.locationLabel,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                height: 32,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.noLocationsFound,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        AppLocalizations.of(context)!.machineid,
                                        deviceIdController,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTextField(
                                        AppLocalizations.of(
                                          context,
                                        )!.frequencySeconds,
                                        frequencyController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  AppLocalizations.of(
                                    context,
                                  )!.frequencyCheckLimit,
                                  freqCheckLimitController,
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.temperatureLabel} (°C)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        tempLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        tempTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        tempUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.humidityLabel} (%)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        humidityLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        humidityTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        humidityUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.pressureLabel} (KG/CM²)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        pressureLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        pressureTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        pressureUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                if (selectedSystem.isEmpty ||
                                    selectedLocationItem == null ||
                                    deviceIdController.text.isEmpty ||
                                    frequencyController.text.isEmpty ||
                                    freqCheckLimitController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.requiredFieldsError,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final newData = {
                                  "system": selectedSystem,
                                  "location": selectedLocationItem!.id
                                      .toString(), // Sử dụng ID
                                  "device_id": deviceIdController.text,
                                  "frequency": frequencyController.text,
                                  "freq_check_limit":
                                      freqCheckLimitController.text,
                                  "temp_lower": tempLowerController.text,
                                  "temp_target": tempTargetController.text,
                                  "temp_upper": tempUpperController.text,
                                  "humidity_lower":
                                      humidityLowerController.text,
                                  "humidity_target":
                                      humidityTargetController.text,
                                  "humidity_upper":
                                      humidityUpperController.text,
                                  "pressure_lower":
                                      pressureLowerController.text,
                                  "pressure_target":
                                      pressureTargetController.text,
                                  "pressure_upper":
                                      pressureUpperController.text,
                                };
                                //gọi api
                                final result = await FmcsApiService.addDevice(
                                  newData,
                                );
                                if (result["status"] == "success") {
                                  setState(() {
                                    hasChanges = true;
                                  });
                                  widget.onDataChanged();
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.deviceAddedSuccess,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result["message"] ??
                                              AppLocalizations.of(
                                                context,
                                              )!.addDeviceFailed,
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                                Navigator.pop(context);
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
                                elevation: 1,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.addD,
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
          ),
        );
      },
    );
  }

  void _showEditDialog(DeviceItem device) {
    // Variables và controllers cho form edit
    String selectedSystem = device.system;
    LocationItem? selectedLocationItem;
    String initialLocationName =
        device.location; // Giả sử device.location là name

    final TextEditingController deviceIdController = TextEditingController(
      text: device.deviceId,
    );
    final TextEditingController frequencyController = TextEditingController(
      text: device.frequency,
    );
    final TextEditingController freqCheckLimitController =
        TextEditingController(text: device.freqCheckLimit);

    final TextEditingController tempLowerController = TextEditingController(
      text: device.tempLower ?? '',
    );
    final TextEditingController tempTargetController = TextEditingController(
      text: device.tempTarget ?? '',
    );
    final TextEditingController tempUpperController = TextEditingController(
      text: device.tempUpper ?? '',
    );

    final TextEditingController humidityLowerController = TextEditingController(
      text: device.humidityLower ?? '',
    );
    final TextEditingController humidityTargetController =
        TextEditingController(text: device.humidityTarget ?? '');
    final TextEditingController humidityUpperController = TextEditingController(
      text: device.humidityUpper ?? '',
    );

    final TextEditingController pressureLowerController = TextEditingController(
      text: device.pressureLower ?? '',
    );
    final TextEditingController pressureTargetController =
        TextEditingController(text: device.pressureTarget ?? '');
    final TextEditingController pressureUpperController = TextEditingController(
      text: device.pressureUpper ?? '',
    );

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
          child: GestureDetector(
            behavior:
                HitTestBehavior.translucent, // 👈 Bắt được tap ở vùng trống
            onTap: () {
              FocusScope.of(
                context,
              ).unfocus(); // Ẩn bàn phím khi tap ra ngoài ô input
            },
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                // Set initial selectedLocationItem nếu có
                if (selectedLocationItem == null &&
                    initialLocationName.isNotEmpty) {
                  // Tìm trong futureLocations, nhưng vì là StatefulBuilder, cần handle trong FutureBuilder
                }
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
                              AppLocalizations.of(context)!.updateDevice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdownField(
                                  AppLocalizations.of(context)!.machineType,
                                  systemOrder,
                                  selectedSystem,
                                  onChanged: (v) {
                                    setDialogState(() {
                                      selectedSystem = v ?? '';
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<List<LocationItem>>(
                                  future: futureLocations,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingDropdown(
                                        AppLocalizations.of(
                                          context,
                                        )!.locationLabel,
                                      );
                                    } else if (snapshot.hasError) {
                                      return _buildErrorDropdown(
                                        AppLocalizations.of(
                                          context,
                                        )!.locationLabel,
                                      );
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
                                      final locationNames = snapshot.data!
                                          .map((l) => l.locationName)
                                          .toList();
                                      // Đảm bảo initialLocationName tồn tại trong list nếu không thì thêm vào đầu
                                      final fixedLocations = List<String>.from(
                                        locationNames,
                                      );
                                      if (initialLocationName.isNotEmpty &&
                                          !fixedLocations.contains(
                                            initialLocationName,
                                          )) {
                                        fixedLocations.insert(
                                          0,
                                          initialLocationName,
                                        );
                                      }
                                      // Set initial selected nếu chưa set
                                      if (selectedLocationItem == null &&
                                          initialLocationName.isNotEmpty) {
                                        try {
                                          selectedLocationItem = snapshot.data!
                                              .firstWhere(
                                                (l) =>
                                                    l.locationName ==
                                                    initialLocationName,
                                              );
                                        } catch (_) {
                                          // Nếu không tìm thấy, giữ null hoặc handle
                                        }
                                      }
                                      return _buildDropdownField(
                                        AppLocalizations.of(
                                          context,
                                        )!.locationLabel,
                                        fixedLocations,
                                        selectedLocationItem?.locationName ??
                                            initialLocationName,
                                        onChanged: (v) {
                                          setDialogState(() {
                                            if (v == initialLocationName &&
                                                selectedLocationItem == null) {
                                              // Giữ nguyên nếu là initial không match
                                            } else {
                                              selectedLocationItem = snapshot
                                                  .data!
                                                  .firstWhere(
                                                    (l) => l.locationName == v,
                                                    orElse: () =>
                                                        throw Exception(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.noLocationsFound,
                                                        ),
                                                  );
                                            }
                                          });
                                        },
                                      );
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.locationLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            height: 32,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              initialLocationName.isEmpty
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.noLocationsFound
                                                  : initialLocationName,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        AppLocalizations.of(context)!.machineid,
                                        deviceIdController,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTextField(
                                        AppLocalizations.of(
                                          context,
                                        )!.frequencySeconds,
                                        frequencyController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  AppLocalizations.of(
                                    context,
                                  )!.frequencyCheckLimit,
                                  freqCheckLimitController,
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.temperatureLabel} (°C)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        tempLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        tempTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        tempUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.humidityLabel} (%)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        humidityLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        humidityTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        humidityUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildSectionTitle(
                                  '${AppLocalizations.of(context)!.pressureLabel} (KG/CM²)',
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.lower,
                                        pressureLowerController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.target,
                                        pressureTargetController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberField(
                                        AppLocalizations.of(context)!.upper,
                                        pressureUpperController,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {

                                if (selectedSystem.isEmpty ||
                                    deviceIdController.text.isEmpty ||
                                    frequencyController.text.isEmpty ||
                                    freqCheckLimitController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.requiredFieldsError,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final updatedData = {
                                  "system": selectedSystem,
                                  "location": selectedLocationItem?.id
                                      .toString(), // Sử dụng ID
                                  "device_id": deviceIdController.text,
                                  "frequency": frequencyController.text,
                                  "freq_check_limit":
                                      freqCheckLimitController.text,
                                  "temp_lower": tempLowerController.text,
                                  "temp_target": tempTargetController.text,
                                  "temp_upper": tempUpperController.text,
                                  "humidity_lower":
                                      humidityLowerController.text,
                                  "humidity_target":
                                      humidityTargetController.text,
                                  "humidity_upper":
                                      humidityUpperController.text,
                                  "pressure_lower":
                                      pressureLowerController.text,
                                  "pressure_target":
                                      pressureTargetController.text,
                                  "pressure_upper":
                                      pressureUpperController.text,
                                };
                                //gọi api
                                final result =
                                    await FmcsApiService.updateDevice(
                                      updatedData,
                                    );
                                if (result["status"] == "success") {
                                  setState(() {
                                    hasChanges = true;
                                  });
                                  widget.onDataChanged();

                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.deviceUpdatedSuccess,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.deviceUpdatedError,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result["message"] ??
                                            AppLocalizations.of(
                                              context,
                                            )!.updateDeviceFailed,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }

                                Navigator.pop(context);
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
                                elevation: 1,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.updateDevice,
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
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String initialValue, {
    ValueChanged<String?>? onChanged,
    String? hintText,
  }) {
    final List<String> fixedItems = List.from(items);
    String? displayValue = initialValue.isNotEmpty ? initialValue : null;
    Widget? hintWidget;
    if (displayValue == null && hintText != null) {
      hintWidget = Text(hintText, style: const TextStyle(color: Colors.grey));
    }
    if (initialValue.isNotEmpty && !fixedItems.contains(initialValue)) {
      fixedItems.insert(0, initialValue);
    }

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
          child: DropdownButtonFormField<String>(
            value: displayValue,
            hint: hintWidget,
            dropdownColor: Colors.white,
            style: const TextStyle(fontSize: 13, color: Colors.black),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            items: fixedItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: onChanged,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
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
              "FMCS",
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
                    Navigator.pushNamed(context, FmcsRoutes.home);
                  },
                ),

                if (canCreateDevice) ...[
                  const PopupMenuDivider(),
                  _buildMenuItem(
                    context: context,
                    value: 'menu2',
                    icon: Icons.add_box,
                    text: AppLocalizations.of(context)!.addDevice,
                    onTap: () {
                      _showAddNewDeviceDialog();
                    },
                  ),
                ],
                const PopupMenuDivider(),
                _buildMenuItem(
                  context: context,
                  value: 'menu3',
                  icon: Icons.location_pin,
                  text: AppLocalizations.of(context)!.locationMa,
                  onTap: () {
                    Navigator.pushNamed(context, FmcsRoutes.locationSetting);
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
                    Navigator.pushNamed(context, FmcsRoutes.home);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
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
                                        _getSystemLabel(category.name),
                                        isSelected:
                                            selectedCategory == category.name,
                                        onTap: () {
                                          setState(() {
                                            selectedCategory = category.name;
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
                                          _getSystemLabel(category.name),
                                          isSelected:
                                              selectedCategory == category.name,
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = category.name;
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
                              side: BorderSide(color: Colors.grey.shade300),
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
            child: ListView.builder(
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

  Widget _buildDeviceCard(DeviceItem device) {
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.deviceIdLabel,
                        device.deviceId,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.locationLabel,
                        device.location,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.dataFrequency,
                        '${device.frequency}s',
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.checkLimit,
                        '${device.freqCheckLimit}s',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.totalcount,
                        device.totalCount.toString(),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: _buildInfoItem(
                        AppLocalizations.of(context)!.unit,
                        device.unit.toString(),
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
                    if (device.temperatureRaw != null)
                      Expanded(
                        child: _buildSensorInfo(
                          AppLocalizations.of(context)!.temperatureLabel,
                          '(°C)',
                          device.tempLower,
                          device.tempTarget,
                          device.tempUpper,
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (device.humidityRaw != null)
                      Expanded(
                        child: _buildSensorInfo(
                          AppLocalizations.of(context)!.humidityLabel,
                          '(%)',
                          device.humidityLower,
                          device.humidityTarget,
                          device.humidityUpper,
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (device.pressureRaw != null)
                      Expanded(
                        child: _buildSensorInfo(
                          AppLocalizations.of(context)!.pressureLabel,
                          '(KG/CM²)',
                          device.pressureLower,
                          device.pressureTarget,
                          device.pressureUpper,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    if (canEditeDevice) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditDialog(device),
                          icon: const Icon(Icons.edit, size: 17),
                          label: Text(
                            AppLocalizations.of(context)!.edit,
                            style: const TextStyle(fontSize: 13),
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
                    if (canDeletedDevice) ...[
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
                                      AppLocalizations.of(
                                        context,
                                      )!.confirmDelete,
                                    ),
                                  ],
                                ),
                                content: Text(
                                  '${AppLocalizations.of(context)!.deleteConfirmMsg} "${device.deviceId}"?',
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
                                      final data = {
                                        "device_id": device.deviceId,
                                      };
                                      final result =
                                          await FmcsApiService.deteteDevice(
                                            data,
                                          );

                                      if (result["status"] == "success") {
                                        setState(() {
                                          hasChanges = true;
                                        });
                                        widget.onDataChanged();
                                        await Future.delayed(
                                          const Duration(milliseconds: 300),
                                        );
                                        widget.onDataChanged();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  '${device.deviceId} deleted',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              result["message"] ??
                                                  "Delete device failed",
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
        ],
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
    String description,
    String? lower,
    String? target,
    String? upper,
  ) {
    // Kiểm tra nếu tất cả giá trị đều null hoặc rỗng
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
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 9,
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
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 9,
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
        const SizedBox(height: 8),
      ],
    );
  }

  String _getSystemLabel(String system) {
    final l10n = AppLocalizations.of(context)!;

    switch (system) {
      case 'Cooling Tower':
        return l10n.systemCoolingTower;
      case 'Chiller':
        return l10n.systemChiller;
      case 'Vacuum Tank':
        return l10n.systemVacuumTank;
      case 'Air Dryer':
        return l10n.systemAirDryer;
      case 'Compressor':
        return l10n.systemCompressor;
      case 'End Air Pressure':
        return l10n.systemEndAirPressure;
      case 'Air Tank':
        return l10n.systemAirTank;
      case 'Air Conditioner':
        return l10n.systemAirConditioner;
      case 'Factory Temperature':
        return l10n.systemFactoryTemperature;
      default:
        // Nếu có system mới mà chưa khai báo, tạm hiển thị nguyên bản
        return system;
    }
  }
}
