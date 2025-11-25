import 'package:flutter/material.dart';
import 'package:mobile/ems/data/ems_api_service.dart';
import 'package:mobile/ems/data/models/machine_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class ActionPlan {
  final String actionId;
  String actionPlan;
  String plannedCompletionDate;
  String owner;

  ActionPlan({
    required this.actionId,
    this.actionPlan = '',
    this.plannedCompletionDate = '',
    this.owner = '',
  });
}

class CreateActionDialog extends StatefulWidget {
  final Machine device;
  const CreateActionDialog({super.key, required this.device});

  @override
  State<CreateActionDialog> createState() => _CreateActionDialogState();
}

class _CreateActionDialogState extends State<CreateActionDialog> {
  final TextEditingController _issueIdController = TextEditingController();
  final TextEditingController _issueDescriptionController =
      TextEditingController();
  String _selectedIssueType = '-- Select issue type --';
  final TextEditingController _actualCycleController = TextEditingController();
  final TextEditingController _efficiencyRequiredController =
      TextEditingController();

  List<ActionPlan> actionPlans = [ActionPlan(actionId: '')];
  int _planCounter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromApi();
  }

  Future<void> _loadDataFromApi() async {
    try {
      final data = await EmsApiService.fetchNextAction();

      if (data == null) {
        print('No data from API');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final planCode = data.nextPlanCode;
      int parsedPlanNumber = data.nextPlanId;
      if (planCode.startsWith('AP')) {
        final numPart = int.tryParse(planCode.substring(2));
        if (numPart != null) parsedPlanNumber = numPart;
      }

      setState(() {
        _issueIdController.text = data.nextActionCode;
        _planCounter = parsedPlanNumber;
        actionPlans = [ActionPlan(actionId: planCode)];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading API data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _issueIdController.dispose();
    _issueDescriptionController.dispose();
    _actualCycleController.dispose();
    _efficiencyRequiredController.dispose();
    super.dispose();
  }

  void _addNewActionPlan() {
    setState(() {
      _planCounter++;
      String newId = 'AP${_planCounter.toString().padLeft(5, '0')}';
      actionPlans.add(ActionPlan(actionId: newId));
    });
  }

  void _removeActionPlan(int index) {
    if (actionPlans.length > 1) {
      setState(() {
        actionPlans.removeAt(index);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, int planIndex) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        actionPlans[planIndex].plannedCompletionDate = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        insetPadding: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: _isLoading
            ? Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[700]!,
                    ),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final height = MediaQuery.of(context).size.height * 0.95;
                  final width = MediaQuery.of(context).size.width * 0.95;

                  return SizedBox(
                    height: height,
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: Container(
                            color: Colors.grey[50],
                            child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: [
                                _buildFormField(
                                  AppLocalizations.of(context)!.issueid,
                                  _issueIdController.text,
                                  enabled: false,
                                ),
                                const SizedBox(height: 10),
                                _buildTextArea(
                                  AppLocalizations.of(
                                    context,
                                  )!.issuedescription,
                                  controller: _issueDescriptionController,
                                ),
                                const SizedBox(height: 10),
                                _buildIssueTypeDropdown(),
                                const SizedBox(height: 10),
                                _buildDialogInfoGrid(),
                                const SizedBox(height: 10),
                                _buildActionPlansSection(),
                              ],
                            ),
                          ),
                        ),
                        _buildFooterButtons(),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[600]!],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${AppLocalizations.of(context)!.createaction} - ${widget.device.moldId}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.issuetype,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedIssueType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          items:
              [
                '-- Select issue type --',
                'Cycle',
                'Efficiency',
                'Cavity',
                'Defect',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value == '-- Select issue type --'
                          ? Colors.grey[600]
                          : Colors.black87,
                      fontWeight: value == '-- Select issue type --'
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedIssueType = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDialogInfoGrid() {
    final value = widget.device;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow([
            _buildReadOnlyField(
              AppLocalizations.of(context)!.actcavity,
              value.actualCavity.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.acteff,
              value.efficiency.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.actcycle,
              value.cycleCount.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.target,
              value.target.toString(),
            ),
          ]),
          const SizedBox(height: 12),
          _buildInfoRow([
            _buildReadOnlyField(
              AppLocalizations.of(context)!.moldcavity,
              value.moldCavity.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.effrequired,
              value.efficiency.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.upperlimit,
              value.upperLimit.toString(),
            ),
            _buildReadOnlyField(
              AppLocalizations.of(context)!.lowerlimit,
              value.lowerLimit.toString(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoRow(List<Widget> fields) {
    return Row(
      children: List.generate(fields.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < fields.length - 1 ? 8 : 0),
            child: fields[index],
          ),
        );
      }),
    );
  }

  String _formatValue(String? value) {
    if (value == null || value.isEmpty || value == "null") return " ";
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    return value;
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            _formatValue(value),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.actionplans,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNewActionPlan,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context)!.addplan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...actionPlans.asMap().entries.map((entry) {
          int index = entry.key;
          ActionPlan plan = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.blue[100]!],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.actionid}: ${plan.actionId}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      if (actionPlans.length > 1)
                        InkWell(
                          onTap: () => _removeActionPlan(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.actionplans,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: plan.actionPlan,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              '${AppLocalizations.of(context)!.actionplans}...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[700]!,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) {
                          plan.actionPlan = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.plannedcompletiondate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _selectDate(context, index),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'YYYY-MM-DD',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue[700]!,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                        suffixIcon: Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.blue[700],
                                        ),
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      controller: TextEditingController(
                                        text: plan.plannedCompletionDate,
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
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
                                  AppLocalizations.of(context)!.owner,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: plan.owner,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.example,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue[700]!,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                  onChanged: (value) {
                                    plan.owner = value;
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
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              try {
                final plansJson = actionPlans.map((plan) {
                  return {
                    "label": AppLocalizations.of(context)!.actionplans,
                    "value": plan.actionPlan,
                    "est": plan.plannedCompletionDate,
                    "owner": plan.owner,
                  };
                }).toList();

                final result = await EmsApiService.createActionWithPlans(
                  deviceId: widget.device.moldId,
                  title: _issueDescriptionController.text,
                  issueType: _selectedIssueType != '-- Select issue type --'
                      ? _selectedIssueType
                      : null,
                  plans: plansJson,
                );

                print("API Response: $result");

                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.actionAddedSuccess,
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                print("Error: $e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.createActionError,
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: Text(
              AppLocalizations.of(context)!.createaction,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    String value, {
    TextEditingController? controller,
    bool enabled = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            controller?.text ?? value,
            style: TextStyle(
              fontSize: 14,
              color: enabled ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(
    String label, {
    TextEditingController? controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          style: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
