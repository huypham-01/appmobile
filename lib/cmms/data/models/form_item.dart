// form_models.dart

import 'package:mobile/utils/constants.dart';

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
        rawUrl = rawUrl.replaceAll(r'\/', '/');
        rawUrl = rawUrl.replaceAll("[::1]", ipconfig); // Replace with actual ipconfig if needed
        return rawUrl;
      }).toList();
    }
    return StaticImageModel(imageUrls: urls, id: json['id'] ?? '');
  }
}

// class StaticVideoModel extends FormItemModel {
//   final List<String> videoUrls;

//   StaticVideoModel({required super.id, required this.videoUrls})
//     : super(type: 'staticVideo');

//   factory StaticVideoModel.fromJson(Map<String, dynamic> json) {
//     List<String> urls = [];
//     if (json['videoUrls'] != null) {
//       urls = (json['videoUrls'] as List).map((e) {
//         String rawUrl = e.toString();
//         rawUrl = rawUrl.replaceAll(r'\/', '/');
//         rawUrl = rawUrl.replaceAll("[::1]", ipconfig); // Replace with actual ipconfig if needed
//         return rawUrl;
//       }).toList();
//     }
//     return StaticVideoModel(videoUrls: urls, id: json['id'] ?? '');
//   }
// }
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
  String? imageUrl;

  UserImageModel({required super.id, this.imageUrl})
    : super(type: 'userImage');

  factory UserImageModel.fromJson(Map<String, dynamic> json) =>
      UserImageModel(id: json['id'] ?? '', imageUrl: json['answer']);

  bool get isAnswered => imageUrl != null;
}

class FormStepModel {
  final int stepIndex;
  final List<FormItemModel> items;

  FormStepModel({required this.stepIndex, required this.items});

  factory FormStepModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? json['formItems'] ?? [];
    final items = (itemsJson as List)
        .map((item) => FormItemModel.fromJson(item))
        .toList();

    return FormStepModel(stepIndex: json['stepIndex'] ?? 1, items: items);
  }
}

class IncompleteItem {
  final String itemId;
  final String question;
  final int stepIndex;

  IncompleteItem({
    required this.itemId,
    required this.question,
    required this.stepIndex,
  });
}