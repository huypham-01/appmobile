// form_widgets.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/utils/constants.dart';

import '../../../../main.dart';
import '../../../data/models/form_item.dart';
import '../../../data/providers/check_list_form.dart';

class ChecklistDetailPopup extends StatefulWidget {
  final String formId;
  final VoidCallback? onSubmitted;
  final String keyW;

  const ChecklistDetailPopup({
    super.key,
    required this.formId,
    this.onSubmitted,
    required this.keyW,
  });

  @override
  State<ChecklistDetailPopup> createState() => _ChecklistDetailPopupState();
}

class _ChecklistDetailPopupState extends State<ChecklistDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ChecklistFormNotifier()..loadForm(widget.keyW, widget.formId),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Consumer<ChecklistFormNotifier>(
            builder: (context, notifier, _) => Text(
              notifier.wiCode.isNotEmpty
                  ? notifier.wiCode
                  : AppLocalizations.of(context)!.checklistForm,
            ),
          ),
          backgroundColor: cusBlue,
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
                _ProgressIndicator(),
                Expanded(child: _FormContent()),
                _NavigationFooter(
                  onSubmitted: widget.onSubmitted,
                  keyW: widget.keyW,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Progress indicator widget
class _ProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistFormNotifier>(
      builder: (context, notifier, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.step} ${notifier.currentStepIndex + 1} / ${notifier.steps.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${notifier.completedItems} / ${notifier.totalItems} ${AppLocalizations.of(context)!.complete}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Form content widget
class _FormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistFormNotifier>(
      builder: (context, notifier, _) {
        final currentStep = notifier.currentStep;

        if (currentStep == null || currentStep.items.isEmpty) {
          return const Center(child: Text('No items in this step'));
        }

        return ListView.builder(
          key: ValueKey('step_${notifier.currentStepIndex}'),
          padding: const EdgeInsets.symmetric(horizontal: 8),
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

// Form item wrapper widget
class _FormItemWidget extends StatelessWidget {
  final FormItemModel item;

  const _FormItemWidget({required this.item, required ValueKey<String> key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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

// Individual form item widgets
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
                    Text(option),
                  ],
                ),
              ),
            ),
          ),
        ),
        // .toList(),
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
                    Text(option),
                  ],
                ),
              ),
            ),
          ),
        ),
        // .toList(),
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

// class _StaticVideoWidget extends StatelessWidget {
//   final StaticVideoModel item;

//   const _StaticVideoWidget({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     if (item.videoUrls.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (item.videoUrls.length > 1)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(
//               'Videos (${item.videoUrls.length})',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ...item.videoUrls.map(
//           (videoUrl) => Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: _VideoPlayerWidget(videoUrl: videoUrl),
//           ),
//         ),
//         // .toList(),
//       ],
//     );
//   }
// }
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

// class _VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const _VideoPlayerWidget({required this.videoUrl});

//   @override
//   State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _hasError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   void _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoUrl),
//       );

//       await _controller.initialize();

//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error initializing video: $e");
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _errorMessage = e.toString();
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_hasError) {
//       return Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 40, color: Colors.red),
//             const SizedBox(height: 8),
//             const Text(
//               'Failed to load video',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _errorMessage ?? 'Unknown error',
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   _hasError = false;
//                   _errorMessage = null;
//                 });
//                 _initializeVideo();
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 12),
//               Text('Loading video...', style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       );
//     }

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           ),
//           _VideoControls(controller: _controller),
//         ],
//       ),
//     );
//   }
// }

// class _VideoControls extends StatefulWidget {
//   final VideoPlayerController controller;

//   const _VideoControls({required this.controller});

//   @override
//   State<_VideoControls> createState() => _VideoControlsState();
// }

// class _VideoControlsState extends State<_VideoControls> {
//   bool _showControls = true;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(() {
//       if (mounted) setState(() {});
//     });

//     _hideControlsTimer();
//   }

//   void _hideControlsTimer() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted && _showControls) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _toggleControlsVisibility() {
//     setState(() {
//       _showControls = !_showControls;
//     });

//     if (_showControls) {
//       _hideControlsTimer();
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.controller.value.isInitialized) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//       onTap: _toggleControlsVisibility,
//       child: AspectRatio(
//         aspectRatio: widget.controller.value.aspectRatio,
//         child: AnimatedOpacity(
//           opacity: _showControls ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 300),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.black, Colors.transparent, Colors.black],
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       IconButton(
//                         onPressed: () => _showVideoDialog(context),
//                         icon: const Icon(
//                           Icons.fullscreen,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           widget.controller.value.isPlaying
//                               ? widget.controller.pause()
//                               : widget.controller.play();
//                         });
//                       },
//                       icon: Icon(
//                         widget.controller.value.isPlaying
//                             ? Icons.pause
//                             : Icons.play_arrow,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     children: [
//                       VideoProgressIndicator(
//                         widget.controller,
//                         allowScrubbing: true,
//                         colors: const VideoProgressColors(
//                           playedColor: Colors.blue,
//                           bufferedColor: Colors.grey,
//                           backgroundColor: Colors.white24,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _formatDuration(widget.controller.value.position),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                           Text(
//                             _formatDuration(widget.controller.value.duration),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showVideoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         insetPadding: const EdgeInsets.all(0),
//         child: Stack(
//           children: [
//             Center(
//               child: AspectRatio(
//                 aspectRatio: widget.controller.value.aspectRatio,
//                 child: VideoPlayer(widget.controller),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 20,
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               ),
//             ),
//             _VideoControls(controller: widget.controller),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Map<String, String>? subtitles; // key = lang, value = url

  const _VideoPlayerWidget({required this.videoUrl, this.subtitles, super.key});

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();

      // Khởi tạo custom subtitle controller
      if (widget.subtitles != null && widget.subtitles!.isNotEmpty) {
        _subs = widget.subtitles!;
        _selectedLang = _subs!.containsKey('en') ? 'en' : _subs!.keys.first;

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
            availableSubtitleLangs: _subs?.keys.toList(),
            selectedLang: _selectedLang,
            onSubtitleSelected: _changeSubtitleLang,
          ),
        ],
      ),
    );
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
  final List<String>? availableSubtitleLangs;
  final String? selectedLang;
  final ValueChanged<String>? onSubtitleSelected;

  const _VideoControls({
    required this.controller,
    this.availableSubtitleLangs,
    this.selectedLang,
    this.onSubtitleSelected,
    // ignore: unused_element_parameter
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
    const languageMap = {'en': 'English', 'vi': 'Tiếng Việt'};

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

  const _FullscreenVideoPlayer({
    required this.controller,
    this.availableSubtitleLangs,
    this.selectedLang,
    this.onSubtitleSelected,
    Key? key,
  }) : super(key: key);

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
                            // Subtitle menu here if needed
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
        if (item.imageUrl != null) ...[
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => notifier.removeUserImage(item.id),
                // onPressed: () async {
                //   await _deleteImage(context, notifier, item);
                // },
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
            onPressed: () => _openCamera(context, notifier, item),
            icon: const Icon(Icons.add_a_photo),
            label: Text(AppLocalizations.of(context)!.takePhoto),
          ),
        ],
      ],
    );
  }

  // Future<void> _deleteImage(
  //   BuildContext context,
  //   ChecklistFormNotifier notifier,
  //   UserImageModel item,
  // ) async {
  //   try {
  //     final url = Uri.parse(
  //       '$baseUrl/cmms/cip3/index.php?c=WorkingInstructionController&m=delete_image&path=${Uri.encodeComponent(item.imageUrl!)}',
  //     );

  //     final response = await http.get(url);

  //     debugPrint("📩 Delete response raw: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['status'] == 'deleted') {
  //         debugPrint("✅ Xóa ảnh thành công");
  //         notifier.removeUserImage(item.id);
  //       } else {
  //         debugPrint("❌ Server báo lỗi khi xóa: ${data['error']}");
  //       }
  //     } else {
  //       debugPrint("❌ Delete failed: ${response.statusCode}");
  //     }
  //   } catch (e, st) {
  //     debugPrint("❌ Exception khi xóa ảnh: $e");
  //     debugPrint("Stacktrace: $st");
  //   }
  // }

  Future<void> _openCamera(
    BuildContext context,
    ChecklistFormNotifier notifier,
    UserImageModel item,
  ) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) {
        debugPrint("❌ Người dùng đã huỷ chụp ảnh");
        return;
      }

      debugPrint("📸 Ảnh chụp: ${pickedFile.path}");

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/cmms/cip3/index.php?c=WorkingInstructionController&m=upload',
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint("📩 Upload response raw: $respStr");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(respStr);
          final uploadedUrl = data['url'];
          debugPrint("✅ Upload thành công, URL: $uploadedUrl");

          // Lưu url (server) thay vì local path
          notifier.setUserImage(item.id, uploadedUrl);
        } catch (e) {
          debugPrint("❌ Lỗi parse JSON: $e");
        }
      } else {
        debugPrint("❌ Upload failed: ${response.statusCode}");
      }
    } catch (e, st) {
      debugPrint("❌ Exception khi chụp/ upload ảnh: $e");
      debugPrint("Stacktrace: $st");
    }
  }
}

// Navigation footer with enhanced popup notifications
class _NavigationFooter extends StatelessWidget {
  final VoidCallback? onSubmitted;
  final String keyW;

  const _NavigationFooter({this.onSubmitted, required this.keyW});

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

              Text(
                '${AppLocalizations.of(context)!.step} ${notifier.currentStepIndex + 1} / ${notifier.steps.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const Spacer(),

              if (notifier.canGoNext)
                ElevatedButton(
                  onPressed: () => _handleNextStep(context, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.next),
                )
              else
                ElevatedButton(
                  onPressed: () => _handleSubmit(keyW, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: notifier.isFormValid
                        ? Colors.green
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.submit),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleNextStep(BuildContext context, ChecklistFormNotifier notifier) {
    final incompleteItems = notifier.currentStepIncompleteItems;

    if (incompleteItems.isNotEmpty) {
      _showIncompleteItemsDialog(
        context,
        notifier,
        incompleteItems,
        isNextStep: true,
      );
    } else {
      _showNextStepDialog(context, notifier);
    }
  }

  Future<void> _handleSubmit(
    String keyW,
    ChecklistFormNotifier notifier,
  ) async {
    // Nếu form chưa hợp lệ
    if (!notifier.isFormValid) {
      final incompleteItems = notifier.incompleteItems;
      _showIncompleteItemsDialog(
        navigatorKey.currentContext!,
        notifier,
        incompleteItems,
        isNextStep: false,
      );
      return;
    }
    final success = await _submitForm(keyW, notifier);
    if (success) {
      navigatorKey.currentState?.pop(true);
      Future.delayed(const Duration(milliseconds: 100), () {
        showEnhancedCenterToast(
          "Form has been submitted successfully!",
          type: ToastType.success,
        );
        // showCenterToast("Form has been submitted successfully!");
      });
    } else {
      showEnhancedCenterToast(
        "Form submission failed. Please try again.",
        type: ToastType.error,
      );
      // showCenterToast("Form submission failed. Please try again.");
    }
  }

  void _showIncompleteItemsDialog(
    BuildContext context,
    ChecklistFormNotifier notifier,
    List<IncompleteItem> incompleteItems, {
    required bool isNextStep,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[600],
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isNextStep
                    ? AppLocalizations.of(context)!.incompleteItemsCurrentStep
                    : AppLocalizations.of(context)!.formIncomplete,
                style: const TextStyle(fontSize: 18),
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isNextStep
                    ? AppLocalizations.of(context)!.completeItemsBeforeNext
                    : AppLocalizations.of(context)!.completeItemsBeforeSubmit,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: incompleteItems.length,
                  itemBuilder: (context, index) {
                    final item = incompleteItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${item.stepIndex}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.step} ${item.stepIndex}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.question,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isNextStep)
                            IconButton(
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              onPressed: () {
                                Navigator.pop(context);
                                notifier.goToStep(item.stepIndex - 1);
                              },
                              tooltip: 'Go to step',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNextStepDialog(
    BuildContext context,
    ChecklistFormNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmation),
        content: Text(AppLocalizations.of(context)!.confirmCompleteSteps),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.nextStep();
            },
            child: Text(AppLocalizations.of(context)!.yesContinue),
          ),
        ],
      ),
    );
  }

  // void _submitForm(BuildContext context, ChecklistFormNotifier notifier) async {
  //   // Hiển thị loading
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(child: CircularProgressIndicator()),
  //   );
  //   print('Dialog loading shown');

  //   try {
  //     final success = await notifier.submitForm();
  //     print('submitForm() completed with success: $success');

  //     // Luôn đóng dialog NGAY LẬP TỨC, dùng rootNavigator để an toàn
  //     Navigator.of(
  //       context,
  //       rootNavigator: true,
  //     ).pop(); // Không cần canPop nữa, vì showDialog luôn có thể pop
  //     print('Dialog closed');

  //     // Kiểm tra context còn mounted không trước khi dùng cho UI actions
  //     if (!context.mounted) {
  //       // Hoặc if (!(context as Element).mounted) nếu version cũ
  //       print('Context is not mounted - skipping UI feedback');
  //       return;
  //     }

  //     if (success) {
  //       // Success: Show SnackBar và pop, nhưng defer để tránh race
  //       SchedulerBinding.instance.addPostFrameCallback((_) {
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Form submitted successfully!'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //           Navigator.pop(context); // Pop màn hình form
  //         }
  //       });
  //     } else {
  //       // Fail: Tương tự
  //       SchedulerBinding.instance.addPostFrameCallback((_) {
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Failed to submit form. Please try again.'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print('Error in submitForm: $e');
  //     // Đóng dialog ngay nếu lỗi
  //     if (Navigator.of(context, rootNavigator: true).canPop()) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }
  //     // Defer error SnackBar
  //     if (context.mounted) {
  //       SchedulerBinding.instance.addPostFrameCallback((_) {
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
  //           );
  //         }
  //       });
  //     }
  //   }
  // }
  Future<bool> _submitForm(String keyW, ChecklistFormNotifier notifier) async {
    print("=== Start _submitForm ===");
    final success = await notifier.submitForm(keyW);
    print("=== End _submitForm ===");
    return success;
  }

  // void _showSuccessDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Colors.green[100],
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(
  //               Icons.check_circle,
  //               color: Colors.green,
  //               size: 32,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           const Text(
  //             'Success!',
  //             style: TextStyle(
  //               color: Colors.green,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: const Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Your form has been submitted successfully!',
  //             style: TextStyle(fontSize: 16),
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(height: 8),
  //           Text(
  //             'Thank you for completing the checklist.',
  //             style: TextStyle(fontSize: 14, color: Colors.grey),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context); // Close success dialog
  //             onSubmitted?.call();
  //             Navigator.pop(context); // Close main form
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.green,
  //             foregroundColor: Colors.white,
  //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //           ),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Future<void> _showSuccessDialog(BuildContext context) async {
  //   await showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Success"),
  //       content: const Text("Form submitted successfully."),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context, rootNavigator: true).pop();
  //           },
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// Empty state widget
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
