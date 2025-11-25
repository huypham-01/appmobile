import 'package:flutter/material.dart';

import '../models/task_equipment_today.dart';
import '../services/task_equipment_today_service.dart';

class QuestionTaskController extends ChangeNotifier {
  final QuestionTaskService _service = QuestionTaskService();
  QuestionTask? questionTask;
  bool isLoading = false;
  String? errorMessage;
  List<Question> questions = [];

  Future<void> loadQuestionTask(String uuid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      questionTask = await _service.fetchQuestionTask(uuid);
      questions = questionTask?.questions ?? [];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateAnswer(int index, int value) {
    questions[index].answer = value;
    notifyListeners();
  }

  Future<void> submitAnswers({required String dailyTaskItemId}) async {
    try {
      isLoading = true;
      notifyListeners();

      final answers = questions.map((q) {
        return {"uuid": q.uuid, "answer": q.answer};
      }).toList();

      final success = await FormService.submitAnswers(
        dailyTaskItemId: dailyTaskItemId,
        answers: answers,
      );

      if (success) {
        print("Submit thành công!");
      } else {
        print("Submit thất bại!");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
