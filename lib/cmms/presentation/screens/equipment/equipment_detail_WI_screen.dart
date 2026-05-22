// checklist_detail_popup.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ============ MODELS ============
abstract class FormItemModel {
  final String id;
  final String type;

  FormItemModel({required this.id, required this.type});

  factory FormItemModel.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'label':
        return LabelModel.fromJson(json);
      case 'yesno':
        return YesNoModel.fromJson(json);
      case 'single':
        return SingleChoiceModel.fromJson(json);
      case 'multiple':
        return MultipleChoiceModel.fromJson(json);
      case 'staticImage':
        return StaticImageModel.fromJson(json);
      case 'staticVideo':
        return StaticVideoModel.fromJson(json);
      case 'userImage':
        return UserImageModel.fromJson(json);
      default:
        throw UnimplementedError('Form type ${json['type']} not implemented');
    }
  }
}

class LabelModel extends FormItemModel {
  final String text;
  final String heading;
  final bool bold;
  final bool italic;
  final bool underline;

  LabelModel({
    required super.id,
    required this.text,
    this.heading = 'h3',
    this.bold = false,
    this.italic = false,
    this.underline = false,
  }) : super(type: 'label');

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    heading: json['heading'] ?? 'h3',
    bold: json['bold'] ?? false,
    italic: json['italic'] ?? false,
    underline: json['underline'] ?? false,
  );
}

class YesNoModel extends FormItemModel {
  final String question;
  String? answer;

  YesNoModel({required super.id, required this.question, this.answer})
    : super(type: 'yesno');

  factory YesNoModel.fromJson(Map<String, dynamic> json) => YesNoModel(
    id: json['id'] ?? '',
    question: json['question'] ?? '',
    answer: json['answer'],
  );

  bool get isAnswered => answer != null;
}

class SingleChoiceModel extends FormItemModel {
  final String question;
  final List<String> options;
  String? answer;

  SingleChoiceModel({
    required super.id,
    required this.question,
    required this.options,
    this.answer,
  }) : super(type: 'single');

  factory SingleChoiceModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    List<String> options = [];

    if (optionsRaw is List) {
      options = optionsRaw.cast<String>();
    } else if (optionsRaw is String) {
      options = optionsRaw.split(',').map((e) => e.trim()).toList();
    }

    return SingleChoiceModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: options,
      answer: json['answer'],
    );
  }

  bool get isAnswered => answer != null;
}

class MultipleChoiceModel extends FormItemModel {
  final String question;
  final List<String> options;
  List<String> selectedAnswers;

  MultipleChoiceModel({
    required super.id,
    required this.question,
    required this.options,
    List<String>? selectedAnswers,
  }) : selectedAnswers = selectedAnswers ?? [],
       super(type: 'multiple');

  factory MultipleChoiceModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    List<String> options = [];

    if (optionsRaw is List) {
      options = optionsRaw.cast<String>();
    } else if (optionsRaw is String) {
      options = optionsRaw.split(',').map((e) => e.trim()).toList();
    }

    List<String> selectedAnswers = [];
    if (json['answer'] is List) {
      selectedAnswers = (json['answer'] as List).cast<String>();
    }

    return MultipleChoiceModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: options,
      selectedAnswers: selectedAnswers,
    );
  }

  bool get isAnswered => selectedAnswers.isNotEmpty;
}

class StaticImageModel extends FormItemModel {
  final List<String> imageUrls;

  StaticImageModel({required super.id, required this.imageUrls})
    : super(type: 'staticImage');

  factory StaticImageModel.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json['imageUrls'] != null) {
      urls = (json['imageUrls'] as List).map((e) {
        String rawUrl = e.toString();

        // Bỏ escape "\/"
        rawUrl = rawUrl.replaceAll(r'\/', '/');

        // Thay [::1] -> 10.0.2.2 cho emulator
        rawUrl = rawUrl.replaceAll("[::1]", ipconfig);

        return rawUrl;
      }).toList();
    }
    return StaticImageModel(imageUrls: urls, id: json['id'] ?? '');
  }
}

class StaticVideoModel extends FormItemModel {
  final List<String> videoUrls;
  final List<Map<String, String>>? subtitles; // thêm mới

  StaticVideoModel({required super.id, required this.videoUrls, this.subtitles})
    : super(type: 'staticVideo');

  factory StaticVideoModel.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    List<Map<String, String>>? subs;

    if (json['videos'] != null) {
      List<Map<String, String>> subtitlesList = [];

      for (var e in (json['videos'] as List)) {
        // parse video url
        String rawUrl = (e['url'] ?? "").toString();
        rawUrl = rawUrl.replaceAll(r'\/', '/').replaceAll("[::1]", ipconfig);
        urls.add(rawUrl);

        // parse subtitle nếu có
        Map<String, String> videoSubtitles = {};
        if (e['subtitles'] != null && e['subtitles'] is Map) {
          for (var entry in (e['subtitles'] as Map<String, dynamic>).entries) {
            String lang = entry.key;
            String subtitleUrl = entry.value
                .toString()
                .replaceAll(r'\/', '/')
                .replaceAll("[::1]", ipconfig);
            videoSubtitles[lang] = subtitleUrl;
          }
        }
        subtitlesList.add(videoSubtitles);
      }

      // Chỉ gán subtitles nếu có ít nhất 1 video có subtitle
      if (subtitlesList.any((sub) => sub.isNotEmpty)) {
        subs = subtitlesList;
      }
    }

    return StaticVideoModel(
      videoUrls: urls,
      subtitles: subs,
      id: json['id'] ?? '',
    );
  }
}

class UserImageModel extends FormItemModel {
  String? imagePath;

  UserImageModel({required super.id, this.imagePath})
    : super(type: 'userImage');

  factory UserImageModel.fromJson(Map<String, dynamic> json) =>
      UserImageModel(id: json['id'] ?? '', imagePath: json['answer']);

  bool get isAnswered => imagePath != null;
}

class FormStepModel {
  final int stepIndex;
  final bool preparation;
  final List<FormItemModel> items;

  FormStepModel({
    required this.stepIndex,
    required this.preparation,
    required this.items,
  });

  factory FormStepModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? json['formItems'] ?? [];
    final items = (itemsJson as List)
        .map((item) => FormItemModel.fromJson(item))
        .toList();

    return FormStepModel(
      stepIndex: json['stepIndex'] ?? 1,
      preparation: json['preparation'] ?? false,
      items: items,
    );
  }
}

// ============ STATE MANAGEMENT ============
class ChecklistFormNotifier extends ChangeNotifier {
  List<FormStepModel> _steps = [];
  int _currentStepIndex = 0;
  bool _isLoading = false;
  String _wiCode = '';

  List<FormStepModel> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  bool get isLoading => _isLoading;
  String get wiCode => _wiCode;

  FormStepModel? get currentStep {
    if (_steps.isEmpty) return null;

    // Có Preparation
    if (preparationStep != null) {
      if (_currentStepIndex == 0) {
        return preparationStep;
      } else {
        final index = _currentStepIndex - 1;
        if (index < normalSteps.length) {
          return normalSteps[index];
        }
      }
    }

    // Không có Preparation
    if (_currentStepIndex < normalSteps.length) {
      return normalSteps[_currentStepIndex];
    }

    return null;
  }

  List<FormItemModel> get allAnswerableItems {
    return _steps
        .expand((step) => step.items)
        .where((item) => _isAnswerable(item))
        .toList();
  }

  int get totalItems => allAnswerableItems.length;

  int get completedItems {
    return allAnswerableItems.where(_isCompleted).length;
  }

  double get progressPercentage =>
      totalItems > 0 ? (completedItems / totalItems * 100) : 0;

  bool get isFormValid => completedItems == totalItems;

  bool get canGoNext => _currentStepIndex < _steps.length - 1;
  bool get canGoPrevious => _currentStepIndex > 0;

  bool _isAnswerable(FormItemModel item) {
    return item is YesNoModel ||
        item is SingleChoiceModel ||
        item is MultipleChoiceModel ||
        item is UserImageModel;
  }

  bool _isCompleted(FormItemModel item) {
    if (item is YesNoModel) return item.isAnswered;
    if (item is SingleChoiceModel) return item.isAnswered;
    if (item is MultipleChoiceModel) return item.isAnswered;
    if (item is UserImageModel) return item.isAnswered;
    return false;
  }

  bool get hasPreparation {
    return steps.any((s) => s.preparation == true);
  }

  int get totalSteps => normalSteps.length;
  int get displayStepNumber {
    if (hasPreparation) {
      // preparation = index 0
      return _currentStepIndex;
    } else {
      // step thật bắt đầu từ 1
      return _currentStepIndex + 1;
    }
  }

  FormStepModel? get preparationStep {
    for (final step in _steps) {
      if (step.preparation == true) {
        return step;
      }
    }
    return null;
  }

  List<FormStepModel> get normalSteps {
    return _steps.where((step) => step.preparation != true).toList();
  }

  // ✅ NEW: Load form từ schema data thay vì API
  void loadFormFromSchema(String schemaString, {String? wiCode}) {
    _isLoading = true;
    notifyListeners();

    try {
      // Parse schema JSON string
      final schemaJson = jsonDecode(schemaString);

      // Convert to FormStepModel list
      _steps = (schemaJson as List)
          .map((json) => FormStepModel.fromJson(json))
          .toList();

      _wiCode = wiCode ?? 'Checklist Form';
      _currentStepIndex = 0;
    } catch (e) {
      debugPrint("Error loading form from schema: $e");
      _steps = [];
      _wiCode = 'Error Loading Form';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Load form từ parsed data (List<FormStepModel>)
  void loadFormFromSteps(List<FormStepModel> steps, {String? wiCode}) {
    _isLoading = true;
    notifyListeners();

    try {
      _steps = steps;
      _wiCode = wiCode ?? 'Checklist Form';
      _currentStepIndex = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerYesNo(String itemId, String answer) {
    final item = _findItem(itemId) as YesNoModel?;
    if (item != null) {
      item.answer = answer;
      notifyListeners();
    }
  }

  void answerSingleChoice(String itemId, String answer) {
    final item = _findItem(itemId) as SingleChoiceModel?;
    if (item != null) {
      item.answer = answer;
      notifyListeners();
    }
  }

  void toggleMultipleChoice(String itemId, String option) {
    final item = _findItem(itemId) as MultipleChoiceModel?;
    if (item != null) {
      if (item.selectedAnswers.contains(option)) {
        item.selectedAnswers.remove(option);
      } else {
        item.selectedAnswers.add(option);
      }
      notifyListeners();
    }
  }

  void setUserImage(String itemId, String imagePath) {
    final item = _findItem(itemId) as UserImageModel?;
    if (item != null) {
      item.imagePath = imagePath;
      notifyListeners();
    }
  }

  void removeUserImage(String itemId) {
    final item = _findItem(itemId) as UserImageModel?;
    if (item != null) {
      item.imagePath = null;
      notifyListeners();
    }
  }

  FormItemModel? _findItem(String itemId) {
    for (final step in _steps) {
      for (final item in step.items) {
        if (item.id == itemId) return item;
      }
    }
    return null;
  }

  void nextStep() {
    if (canGoNext) {
      _currentStepIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (canGoPrevious) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  // ✅ NEW: Get form answers for submission
  Map<String, dynamic> getFormAnswers() {
    Map<String, dynamic> answers = {};

    for (final step in _steps) {
      for (final item in step.items) {
        if (item is YesNoModel && item.isAnswered) {
          answers[item.id] = item.answer;
        } else if (item is SingleChoiceModel && item.isAnswered) {
          answers[item.id] = item.answer;
        } else if (item is MultipleChoiceModel && item.isAnswered) {
          answers[item.id] = item.selectedAnswers;
        } else if (item is UserImageModel && item.isAnswered) {
          answers[item.id] = item.imagePath;
        }
      }
    }

    return answers;
  }

  Future<bool> submitForm() async {
    if (!isFormValid) return false;

    try {
      // Get all answers
      final answers = getFormAnswers();

      // You can modify this part to call your API
      debugPrint('Form answers: ${jsonEncode(answers)}');

      // Simulate API submission
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('Form submitted successfully');
      return true;
    } catch (e) {
      debugPrint('Error submitting form: $e');
      return false;
    }
  }
}

// ============ WIDGETS ============
class EquipmentDetailWiScreen extends StatelessWidget {
  // ✅ NEW: Accept schema data instead of formId
  final String? schemaString;
  final List<FormStepModel>? formSteps;
  final String? wiCode;
  final VoidCallback? onSubmitted;
  final Future<bool> Function(Map<String, dynamic>)? onSubmit;

  const EquipmentDetailWiScreen({
    super.key,
    this.schemaString,
    this.formSteps,
    this.wiCode,
    this.onSubmitted,
    this.onSubmit,
  }) : assert(
         schemaString != null || formSteps != null,
         'Either schemaString or formSteps must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final notifier = ChecklistFormNotifier();

        // Load data based on what's provided
        if (formSteps != null) {
          notifier.loadFormFromSteps(formSteps!, wiCode: wiCode);
        } else if (schemaString != null) {
          notifier.loadFormFromSchema(schemaString!, wiCode: wiCode);
        }

        return notifier;
      },
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          title: Consumer<ChecklistFormNotifier>(
            builder: (context, notifier, _) => Text(
              notifier.wiCode.isNotEmpty
                  ? notifier.wiCode
                  : AppLocalizations.of(context)!.checklistForm,
            ),
          ),
          backgroundColor: cusBlue, // cusBlue replacement
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        body: Consumer<ChecklistFormNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifier.steps.isEmpty) {
              return const _EmptyStateWidget();
            }

            return Column(
              children: [
                const Expanded(child: _FormContent()),
                _NavigationFooter(onSubmitted: onSubmitted, onSubmit: onSubmit),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistFormNotifier>(
      builder: (context, notifier, _) {
        final currentStep = notifier.currentStep;

        if (currentStep == null || currentStep.items.isEmpty) {
          return const Center(child: Text('No items in this step'));
        }

        return ListView.builder(
          key: ValueKey('step_${notifier.currentStepIndex}'), // Add this line
          padding: const EdgeInsets.all(8),
          itemCount: currentStep.items.length,
          itemBuilder: (context, index) {
            return _FormItemWidget(
              key: ValueKey(
                '${notifier.currentStepIndex}_item_${currentStep.items[index].id}',
              ),
              item: currentStep.items[index],
            );
          },
        );
      },
    );
  }
}

class _FormItemWidget extends StatelessWidget {
  final FormItemModel item;

  const _FormItemWidget({required this.item, required ValueKey<String> key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _buildItemContent(context),
    );
  }

  Widget _buildItemContent(BuildContext context) {
    switch (item.runtimeType) {
      case const (LabelModel):
        return _LabelWidget(item: item as LabelModel);
      case const (YesNoModel):
        return _YesNoWidget(item: item as YesNoModel);
      case const (SingleChoiceModel):
        return _SingleChoiceWidget(item: item as SingleChoiceModel);
      case const (MultipleChoiceModel):
        return _MultipleChoiceWidget(item: item as MultipleChoiceModel);
      case const (StaticImageModel):
        return _StaticImageWidget(item: item as StaticImageModel);
      case const (StaticVideoModel):
        return _StaticVideoWidget(item: item as StaticVideoModel);
      case const (UserImageModel):
        return _UserImageWidget(item: item as UserImageModel);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _LabelWidget extends StatelessWidget {
  final LabelModel item;

  const _LabelWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Text(
      item.text,
      style: TextStyle(
        fontSize: item.heading == 'h2' ? 20 : 16,
        fontWeight: item.bold ? FontWeight.bold : FontWeight.w600,
        fontStyle: item.italic ? FontStyle.italic : FontStyle.normal,
        decoration: item.underline
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
    );
  }
}

class _YesNoWidget extends StatelessWidget {
  final YesNoModel item;

  const _YesNoWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOption(context, 'Yes')),
            const SizedBox(width: 16),
            Expanded(child: _buildOption(context, 'No')),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String value) {
    final notifier = Provider.of<ChecklistFormNotifier>(context);
    final isSelected = item.answer == value;

    return GestureDetector(
      onTap: () => notifier.answerYesNo(item.id, value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class _SingleChoiceWidget extends StatelessWidget {
  final SingleChoiceModel item;

  const _SingleChoiceWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ChecklistFormNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...item.options.map(
          (option) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => notifier.answerSingleChoice(item.id, option),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: item.answer == option
                        ? Colors.blue
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: item.answer == option
                      ? Colors.blue[50]
                      : Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      item.answer == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: item.answer == option ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultipleChoiceWidget extends StatelessWidget {
  final MultipleChoiceModel item;

  const _MultipleChoiceWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ChecklistFormNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...item.options.map(
          (option) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => notifier.toggleMultipleChoice(item.id, option),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: item.selectedAnswers.contains(option)
                        ? Colors.blue
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: item.selectedAnswers.contains(option)
                      ? Colors.blue[50]
                      : Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      item.selectedAnswers.contains(option)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: item.selectedAnswers.contains(option)
                          ? Colors.blue
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaticImageWidget extends StatelessWidget {
  final StaticImageModel item;

  const _StaticImageWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: item.imageUrls.length == 1 ? 1 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: item.imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showImageDialog(context, item.imageUrls[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }
}

class _StaticVideoWidget extends StatelessWidget {
  final StaticVideoModel item;

  const _StaticVideoWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    // Debug video URLs
    for (var url in item.videoUrls) {
      debugPrint("✅ Video URL parsed: $url");
    }

    // Debug subtitles
    if (item.subtitles != null) {
      for (int i = 0; i < item.subtitles!.length; i++) {
        debugPrint("✅ Subtitles for video $i: ${item.subtitles![i]}");
      }
    }

    if (item.videoUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.videoUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Videos (${item.videoUrls.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        ...List.generate(item.videoUrls.length, (index) {
          final videoUrl = item.videoUrls[index];

          // Lấy subtitles cho video này
          Map<String, String>? videoSubtitles;
          if (item.subtitles != null && index < item.subtitles!.length) {
            final subs = item.subtitles![index];
            // Chỉ truyền subtitles nếu không rỗng
            if (subs.isNotEmpty) {
              videoSubtitles = subs;
              debugPrint("✅ Using subtitles for video $index: $subs");
            } else {
              debugPrint("⚠️ Empty subtitles for video $index");
            }
          } else {
            debugPrint("⚠️ No subtitles available for video $index");
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _VideoPlayerWidget(
              key: ValueKey('${item.id}_video_$index'),
              videoUrl: videoUrl,
              subtitles: videoSubtitles, // Map<String, String>? hoặc null
            ),
          );
        }),
      ],
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Map<String, String>? subtitles; // key = lang, value = url

  const _VideoPlayerWidget({
    required this.videoUrl,
    this.subtitles,
    required ValueKey<String> key,
  });

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  CustomSubtitleController? _customSubtitleController;
  Timer? _positionTimer;
  Map<String, String>? _subs;
  String? _selectedLang;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  double _volume = 1.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<String?> _getSavedSubtitleLanguage(
    Map<String, String> subtitles,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selectedLanguage');

    switch (savedLang) {
      case 'English':
        return subtitles.containsKey('en') ? 'en' : null;
      case 'Vietnamese':
        return subtitles.containsKey('vi') ? 'vi' : null;
      case 'Chinese':
        return subtitles.containsKey('zh') ? 'zh' : null;
      case 'Taiwanese':
        return subtitles.containsKey('zh') ? 'zh' : null;
      default:
        return null;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      _isMuted = true;
      await _controller.setVolume(0.0);

      // Khởi tạo custom subtitle controller
      if (widget.subtitles != null && widget.subtitles!.isNotEmpty) {
        _subs = widget.subtitles!;
        final savedLang = await _getSavedSubtitleLanguage(_subs!);
        _selectedLang =
            savedLang ?? (_subs!.containsKey('en') ? 'en' : _subs!.keys.first);

        // _selectedLang = _subs!.containsKey('en') ? 'en' : _subs!.keys.first;

        _customSubtitleController = CustomSubtitleController();
        await _customSubtitleController!.loadFromUrl(_subs![_selectedLang]!);

        // Bắt đầu timer để cập nhật subtitle position
        _startPositionTimer();

        debugPrint(
          "✅ Custom subtitle controller created with URL: ${_subs![_selectedLang]}",
        );
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_controller.value.isInitialized &&
          _customSubtitleController != null) {
        _customSubtitleController!.updatePosition(_controller.value.position);
        if (mounted) setState(() {});
      }
    });
  }

  // đổi ngôn ngữ phụ đề khi user chọn
  Future<void> _changeSubtitleLang(String lang) async {
    if (_subs == null) return;
    final url = _subs![lang];
    if (url == null) return;

    try {
      if (_customSubtitleController != null) {
        await _customSubtitleController!.loadFromUrl(url);
      } else {
        _customSubtitleController = CustomSubtitleController();
        await _customSubtitleController!.loadFromUrl(url);
        _startPositionTimer();
      }

      setState(() {
        _selectedLang = lang;
      });

      debugPrint("✅ Changed subtitle language to: $lang, URL: $url");
    } catch (e) {
      debugPrint("❌ Error changing subtitle language: $e");
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller.dispose();
    _customSubtitleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _errorWidget();
    if (!_isInitialized) return _loadingWidget();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // Custom subtitle overlay
          if (_customSubtitleController != null)
            CustomSubtitleOverlay(text: _customSubtitleController!.currentText),

          // Video controls
          _VideoControls(
            controller: _controller,
            isMuted: _isMuted,
            onToggleMute: _toggleMute,
            availableSubtitleLangs: _subs?.keys.toList(),
            selectedLang: _selectedLang,
            onSubtitleSelected: _changeSubtitleLang,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMute() async {
    if (_isMuted) {
      await _unmute();
    } else {
      await _mute();
    }
  }

  Future<void> _mute() async {
    _isMuted = true;
    await _controller.setVolume(0.0);
    if (mounted) setState(() {});
  }

  Future<void> _unmute() async {
    _isMuted = false;
    await _controller.setVolume(_volume);
    if (mounted) setState(() {});
  }

  Widget _loadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.loading,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.failedloadvideo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

/////
////// Controls với menu chọn subtitle
class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final List<String>? availableSubtitleLangs;
  final String? selectedLang;
  final ValueChanged<String>? onSubtitleSelected;
  final String? currentSubtitleText; // Thêm param để truyền subtitle text

  const _VideoControls({
    required this.controller,
    required this.isMuted,
    required this.onToggleMute,
    this.availableSubtitleLangs,
    this.selectedLang,
    this.onSubtitleSelected,
    this.currentSubtitleText, // Thêm param
    super.key,
  });

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _playPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
      _startHideTimer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Widget _buildSubtitleMenu() {
    if (widget.availableSubtitleLangs == null ||
        widget.availableSubtitleLangs!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      initialValue: widget.selectedLang,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.subtitles, color: Colors.white, size: 20),
      ),
      color: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (lang) {
        widget.onSubtitleSelected?.call(lang);
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        // Option "Off" để tắt subtitle
        items.add(
          PopupMenuItem(
            value: 'off',
            child: Row(
              children: [
                Icon(
                  widget.selectedLang == null ? Icons.check : null,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('Off', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        // Các ngôn ngữ có sẵn
        for (final lang in widget.availableSubtitleLangs!) {
          items.add(
            PopupMenuItem(
              value: lang,
              child: Row(
                children: [
                  Icon(
                    lang == widget.selectedLang ? Icons.check : null,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLanguageName(lang),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: lang == widget.selectedLang
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  String _getLanguageName(String langCode) {
    // Map các mã ngôn ngữ thành tên hiển thị
    const languageMap = {'en': 'English', 'vi': 'Tiếng Việt', 'zh': '中文'};

    return languageMap[langCode.toLowerCase()] ?? langCode.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Container(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Spacer
                      Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onToggleMute,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                widget.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),
                          _buildSubtitleMenu(),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _showFullscreenDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Center play/pause button
                Center(
                  child: GestureDetector(
                    onTap: _playPause,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress bar
                      Row(
                        children: [
                          Text(
                            _formatDuration(widget.controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.blue,
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.3,
                                ),
                                thumbColor: Colors.blue,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: widget
                                    .controller
                                    .value
                                    .position
                                    .inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      widget
                                          .controller
                                          .value
                                          .duration
                                          .inMilliseconds
                                          .toDouble(),
                                    ),
                                min: 0.0,
                                max: widget
                                    .controller
                                    .value
                                    .duration
                                    .inMilliseconds
                                    .toDouble(),
                                onChanged: (value) {
                                  widget.controller.seekTo(
                                    Duration(milliseconds: value.round()),
                                  );
                                },
                                onChangeStart: (value) {
                                  _hideTimer?.cancel();
                                },
                                onChangeEnd: (value) {
                                  _startHideTimer();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(widget.controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullscreenDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _FullscreenVideoPlayer(
          controller: widget.controller,
          availableSubtitleLangs: widget.availableSubtitleLangs,
          selectedLang: widget.selectedLang,
          onSubtitleSelected: widget.onSubtitleSelected,
          currentSubtitleText:
              widget.currentSubtitleText, // Truyền subtitle text
        ),
      ),
    );
  }
}

class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final List<String>? availableSubtitleLangs;
  final String? selectedLang;
  final ValueChanged<String>? onSubtitleSelected;
  final String? currentSubtitleText; // Thêm param để hiển thị subtitle

  const _FullscreenVideoPlayer({
    required this.controller,
    this.availableSubtitleLangs,
    this.selectedLang,
    this.onSubtitleSelected,
    this.currentSubtitleText, // Thêm param
    super.key,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Widget _buildSubtitleMenu() {
    if (widget.availableSubtitleLangs == null ||
        widget.availableSubtitleLangs!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      initialValue: widget.selectedLang,
      offset: const Offset(0, 50), // Thêm offset để menu hiển thị đúng vị trí
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.subtitles, color: Colors.white, size: 24),
      ),
      color: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8, // Thêm shadow để menu nổi bật hơn
      onSelected: (lang) {
        if (lang == 'off') {
          widget.onSubtitleSelected?.call('');
        } else {
          widget.onSubtitleSelected?.call(lang);
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        // Option "Off" để tắt subtitle
        items.add(
          PopupMenuItem(
            value: 'off',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    (widget.selectedLang == null || widget.selectedLang == '')
                        ? Icons.check
                        : null,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Off',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        // Các ngôn ngữ có sẵn
        for (final lang in widget.availableSubtitleLangs!) {
          items.add(
            PopupMenuItem(
              value: lang,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      lang == widget.selectedLang ? Icons.check : null,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getLanguageName(lang),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: lang == widget.selectedLang
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  String _getLanguageName(String langCode) {
    // Map các mã ngôn ngữ thành tên hiển thị
    const languageMap = {'en': 'English', 'vi': 'Tiếng Việt', 'zh': '中文'};

    return languageMap[langCode.toLowerCase()] ?? langCode.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // Subtitle overlay - Thêm phần này
            if (widget.currentSubtitleText != null &&
                widget.currentSubtitleText!.isNotEmpty)
              Positioned(
                bottom: 100, // Đặt cao hơn controls một chút
                left: 20,
                right: 20,
                child: Center(
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          180,
                          36,
                          35,
                          35,
                        ), // Slightly more opaque for fullscreen
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.currentSubtitleText!,
                        style: const TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 16, // Larger font for fullscreen
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
              ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    // Top bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),

                            // Subtitle menu - đã thêm vào đây
                            _buildSubtitleMenu(),
                          ],
                        ),
                      ),
                    ),

                    // Center play button
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (widget.controller.value.isPlaying) {
                              widget.controller.pause();
                            } else {
                              widget.controller.play();
                              _startHideTimer();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom controls
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(widget.controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.blue,
                                  inactiveTrackColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  thumbColor: Colors.blue,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: widget
                                      .controller
                                      .value
                                      .position
                                      .inMilliseconds
                                      .toDouble()
                                      .clamp(
                                        0.0,
                                        widget
                                            .controller
                                            .value
                                            .duration
                                            .inMilliseconds
                                            .toDouble(),
                                      ),
                                  min: 0.0,
                                  max: widget
                                      .controller
                                      .value
                                      .duration
                                      .inMilliseconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    widget.controller.seekTo(
                                      Duration(milliseconds: value.round()),
                                    );
                                  },
                                  onChangeStart: (value) {
                                    _hideTimer?.cancel();
                                  },
                                  onChangeEnd: (value) {
                                    _startHideTimer();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _formatDuration(widget.controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserImageWidget extends StatelessWidget {
  final UserImageModel item;

  const _UserImageWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ChecklistFormNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.uploadImage,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (item.imagePath != null) ...[
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.imagePath!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => notifier.removeUserImage(item.id),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.add_a_photo),
            label: Text(AppLocalizations.of(context)!.takePhoto),
          ),
        ],
      ],
    );
  }
}

class _NavigationFooter extends StatelessWidget {
  final VoidCallback? onSubmitted;
  final Future<bool> Function(Map<String, dynamic>)? onSubmit;

  const _NavigationFooter({this.onSubmitted, this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistFormNotifier>(
      builder: (context, notifier, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              if (notifier.canGoPrevious)
                ElevatedButton(
                  onPressed: notifier.previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  child: Text(AppLocalizations.of(context)!.previous),
                )
              else
                const SizedBox(width: 80),

              const Spacer(),
              //TODO

              // Text(
              //   '${AppLocalizations.of(context)!.step} ${notifier.currentStepIndex + 1} / ${notifier.steps.length}',
              //   style: const TextStyle(fontWeight: FontWeight.w600),
              // ),
              Text(
                notifier.hasPreparation && notifier.currentStepIndex == 0
                    ? 'Preparation'
                    : '${AppLocalizations.of(context)!.step} '
                          '${notifier.displayStepNumber} / ${notifier.totalSteps}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const Spacer(),

              if (notifier.canGoNext)
                ElevatedButton(
                  onPressed: () {
                    notifier.nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cusBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.next),
                )
              else
                ElevatedButton(
                  onPressed: null,
                  child: Text(AppLocalizations.of(context)!.next),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noFormAvailable,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noSavedForms,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============ UTILITY FUNCTIONS ============
/// Helper function to parse schema string and create FormStepModel list
List<FormStepModel> parseSchemaToSteps(String schemaString) {
  try {
    final schemaJson = jsonDecode(schemaString);
    return (schemaJson as List)
        .map((json) => FormStepModel.fromJson(json))
        .toList();
  } catch (e) {
    debugPrint("Error parsing schema: $e");
    return [];
  }
}

/// Helper function to create EquipmentDetailWiScreen with schema string
Widget createChecklistFromSchema({
  required String schemaString,
  String? wiCode,
  VoidCallback? onSubmitted,
  Future<bool> Function(Map<String, dynamic>)? onSubmit,
}) {
  return EquipmentDetailWiScreen(
    schemaString: schemaString,
    wiCode: wiCode,
    onSubmitted: onSubmitted,
    onSubmit: onSubmit,
  );
}

/// Helper function to create EquipmentDetailWiScreen with pre-parsed steps
Widget createChecklistFromSteps({
  required List<FormStepModel> formSteps,
  String? wiCode,
  VoidCallback? onSubmitted,
  Future<bool> Function(Map<String, dynamic>)? onSubmit,
}) {
  return EquipmentDetailWiScreen(
    formSteps: formSteps,
    wiCode: wiCode,
    onSubmitted: onSubmitted,
    onSubmit: onSubmit,
  );
}
