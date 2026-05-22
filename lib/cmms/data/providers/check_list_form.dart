// form_notifier.dart

import 'package:flutter/material.dart';

import '../models/form_item.dart';
import '../services/form_service.dart';

class ChecklistFormNotifier extends ChangeNotifier {
  List<FormStepModel> _steps = [];
  int _currentStepIndex = 0;
  bool _isLoading = false;
  String _wiCode = '';
  String _uuid = '';

  List<FormStepModel> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  bool get isLoading => _isLoading;
  String get wiCode => _wiCode;
  String get uuid => _uuid;

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

  // Get incomplete items with their step information
  List<IncompleteItem> get incompleteItems {
    List<IncompleteItem> incomplete = [];

    for (int stepIdx = 0; stepIdx < _steps.length; stepIdx++) {
      final step = _steps[stepIdx];
      for (final item in step.items) {
        if (_isAnswerable(item) && !_isCompleted(item)) {
          String question = '';
          if (item is YesNoModel) question = item.question;
          if (item is SingleChoiceModel) question = item.question;
          if (item is MultipleChoiceModel) question = item.question;
          if (item is UserImageModel) question = 'Upload Image';

          incomplete.add(
            IncompleteItem(
              itemId: item.id,
              question: question,
              stepIndex: stepIdx + 1,
            ),
          );
        }
      }
    }

    return incomplete;
  }

  // Get incomplete items for current step only
  List<IncompleteItem> get currentStepIncompleteItems {
    if (currentStep == null) return [];

    List<IncompleteItem> incomplete = [];
    for (final item in currentStep!.items) {
      if (_isAnswerable(item) && !_isCompleted(item)) {
        String question = '';
        if (item is YesNoModel) question = item.question;
        if (item is SingleChoiceModel) question = item.question;
        if (item is MultipleChoiceModel) question = item.question;
        if (item is UserImageModel) question = 'Upload Image';

        incomplete.add(
          IncompleteItem(
            itemId: item.id,
            question: question,
            stepIndex: _currentStepIndex + 1,
          ),
        );
      }
    }

    return incomplete;
  }

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

  Future<void> loadForm(String keyW, String uuid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await FormService.loadFormById(keyW, uuid);

      if (response.isSuccess) {
        _steps = response.steps!;
        _wiCode = response.wiCode!;
        _uuid = response.uuid!;
        _currentStepIndex = 0;
      } else if (response.isEmpty) {
        _steps = [];
      } else {
        _steps = [];
        // Handle error case if needed
      }
    } catch (e) {
      debugPrint("Error in loadForm: $e");
      _steps = [];
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
      item.imageUrl = imagePath;
      notifyListeners();
    }
  }

  void removeUserImage(String itemId) {
    final item = _findItem(itemId) as UserImageModel?;
    if (item != null) {
      item.imageUrl = null;
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

  void goToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < _steps.length) {
      _currentStepIndex = stepIndex;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildFormData() {
    final schema = _steps.map((step) {
      return {
        "stepIndex": step.stepIndex,
        "items": step.items.map((item) {
          if (item is LabelModel) {
            return {
              "id": item.id,
              "type": "label",
              "text": item.text,
              "heading": item.heading,
              "bold": item.bold,
              "italic": item.italic,
              "underline": item.underline,
            };
          } else if (item is StaticImageModel) {
            return {
              "id": item.id,
              "type": "staticImage",
              "imageUrls": item.imageUrls,
            };
          } else if (item is StaticVideoModel) {
            return {
              "id": item.id,
              "type": "staticVideo",
              "videoUrls": item.videoUrls,
            };
          } else if (item is YesNoModel) {
            return {
              "id": item.id,
              "type": "yesno",
              "question": item.question,
              "answer": item.answer,
            };
          } else if (item is SingleChoiceModel) {
            return {
              "id": item.id,
              "type": "single",
              "question": item.question,
              "options": item.options,
              "answer": item.answer,
            };
          } else if (item is MultipleChoiceModel) {
            return {
              "id": item.id,
              "type": "multiple",
              "question": item.question,
              "options": item.options,
              "answer": item.selectedAnswers,
            };
          } else if (item is UserImageModel) {
            return {
              "id": item.id,
              "type": "userImage",
              "answer": item.imageUrl,
            };
          }

          return {};
        }).toList(),
      };
    }).toList();

    return {"uuid": _uuid, "wiCode": _wiCode, "schema": schema};
  }

  Future<bool> submitForm(String keyW) async {
    if (!isFormValid) {
      debugPrint("Form chưa hoàn thành!");
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final formData = _buildFormData();
      final success = await FormService.submitForm(keyW, formData);
      return success;
    } catch (e, stack) {
      debugPrint("ChecklistFormNotifier submitForm error: $e");
      debugPrint(stack.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoading(bool bool) {}
}
