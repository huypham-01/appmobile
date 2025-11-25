import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

const String ipconfig = "192.168.110.2";
const String baseUrl = "http://192.168.110.2/web_develop/cmms";
// const String baseUrl = "http://192.168.0.103:8080/web_develop/iam";

final white = Colors.grey[50];
final cusBlue = Color.fromARGB(255, 67, 103, 164);

class KeyboardDismissOnTap extends StatefulWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  State<KeyboardDismissOnTap> createState() => _KeyboardDismissOnTapState();
}

class _KeyboardDismissOnTapState extends State<KeyboardDismissOnTap> {
  bool _justUnfocused = false;

  void _handleTap(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      // Nếu đang focus => ẩn bàn phím
      currentFocus.unfocus();
      _justUnfocused = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleTap(context),
      onPointerUp: (_) {
        if (_justUnfocused) {
          // Chặn tap đầu tiên sau khi vừa unfocus
          _justUnfocused = false;
        }
      },
      child: widget.child,
    );
  }
}

enum ToastType { success, error, warning, info }

class EnhancedToast {
  static void show({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    required NavigatorState navigatorState,
  }) {
    final overlayState = navigatorState.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFF44336);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  // Color getMaintenaceColor(String? type) {
  //   switch (type?.toLowerCase()) {
  //     case 'maintenance level 1':
  //       return Colors.green[300]!;
  //     case 'maintenance level 2':
  //       return Colors.orange[300]!;
  //     case 'maintenance level 3':
  //       return Colors.red[300]!;
  //     default:
  //       return Colors.grey[600]!;
  //   }
  // }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      _animationController.reverse().then((_) {
                        widget.onDismiss();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getBackgroundColor(),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getBackgroundColor(),
                            _getBackgroundColor(),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIcon(),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                _animationController.reverse().then((_) {
                                  widget.onDismiss();
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Phiên bản cải tiến của toast đơn giản
void showEnhancedCenterToast(
  String message, {
  ToastType type = ToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final navigatorState = navigatorKey.currentState;
  if (navigatorState == null) return;

  EnhancedToast.show(
    message: message,
    type: type,
    duration: duration,
    navigatorState: navigatorState,
  );
}

// Phiên bản toast tối giản nhưng đẹp hơn
void showMinimalToast(String message) {
  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) return;

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => _MinimalToastWidget(
      message: message,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  overlayState.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _MinimalToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _MinimalToastWidget({required this.message, required this.onDismiss});

  @override
  State<_MinimalToastWidget> createState() => _MinimalToastWidgetState();
}

class _MinimalToastWidgetState extends State<_MinimalToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

////
///

class SubtitleCue {
  final Duration startTime;
  final Duration endTime;
  final String text;

  SubtitleCue({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  @override
  String toString() {
    return 'SubtitleCue(${_formatDuration(startTime)} --> ${_formatDuration(endTime)}: $text)';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(
      3,
      '0',
    );
    return '$minutes:$seconds.$milliseconds';
  }
}

class VttParser {
  static Future<List<SubtitleCue>> parseFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final content = utf8
            .decode(response.bodyBytes)
            .replaceAll('\uFEFF', ''); // loại bỏ BOM nếu có
        return parseVttContent(content);
      } else {
        throw Exception('Failed to load VTT file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching VTT file: $e');
    }
  }

  static List<SubtitleCue> parseVttContent(String vttContent) {
    final List<SubtitleCue> cues = [];

    // Chia content thành các dòng
    final lines = vttContent.split('\n').map((line) => line.trim()).toList();

    // Bỏ qua header "WEBVTT"
    int i = 0;
    while (i < lines.length && !lines[i].contains('-->')) {
      i++;
    }

    // Parse từng cue
    while (i < lines.length) {
      // Tìm dòng có timestamp (format: 00:00.000 --> 00:20.000)
      if (lines[i].contains('-->')) {
        try {
          final timeParts = lines[i].split('-->');
          if (timeParts.length == 2) {
            final startTime = _parseTimestamp(timeParts[0].trim());
            final endTime = _parseTimestamp(timeParts[1].trim());

            // Thu thập tất cả text lines cho cue này
            final List<String> textLines = [];
            i++; // Di chuyển đến dòng text đầu tiên

            // Đọc tất cả text lines cho đến khi gặp dòng trống hoặc timestamp tiếp theo
            while (i < lines.length &&
                lines[i].isNotEmpty &&
                !lines[i].contains('-->')) {
              textLines.add(lines[i]);
              i++;
            }

            // Ghép tất cả text lines thành một cue
            if (textLines.isNotEmpty) {
              final text = textLines.join('\n');
              cues.add(
                SubtitleCue(startTime: startTime, endTime: endTime, text: text),
              );
            }
          }
        } catch (e) {
          print('Error parsing cue at line ${i + 1}: $e');
          i++;
        }
      } else {
        i++;
      }
    }

    return cues;
  }

  static Duration _parseTimestamp(String timestamp) {
    // Format: mm:ss.fff hoặc hh:mm:ss.fff
    final parts = timestamp.split(':');

    if (parts.length == 2) {
      // Format: mm:ss.fff
      final minutes = int.parse(parts[0]);
      final secondsParts = parts[1].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = int.parse(secondsParts[1]);

      return Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } else if (parts.length == 3) {
      // Format: hh:mm:ss.fff
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secondsParts = parts[2].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = int.parse(secondsParts[1]);

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    }

    throw FormatException('Invalid timestamp format: $timestamp');
  }
}

// Custom Subtitle Controller sử dụng VTT parser
class CustomSubtitleController {
  List<SubtitleCue> _cues = [];
  String? _currentText;
  Duration _currentPosition = Duration.zero;

  List<SubtitleCue> get cues => _cues;
  String? get currentText => _currentText;

  Future<void> loadFromUrl(String url) async {
    try {
      _cues = await VttParser.parseFromUrl(url);
      print('✅ Loaded ${_cues.length} subtitle cues');
      for (var cue in _cues) {
        print(cue);
      }
    } catch (e) {
      print('❌ Error loading subtitles: $e');
      _cues = [];
    }
  }

  void updatePosition(Duration position) {
    _currentPosition = position;

    // Tìm cue phù hợp với thời gian hiện tại
    SubtitleCue? activeCue;
    for (var cue in _cues) {
      if (position >= cue.startTime && position <= cue.endTime) {
        activeCue = cue;
        break;
      }
    }

    _currentText = activeCue?.text;
  }

  void dispose() {
    _cues.clear();
    _currentText = null;
  }
}

// Widget hiển thị subtitle
class CustomSubtitleOverlay extends StatelessWidget {
  final String? text;
  final TextStyle? style;

  const CustomSubtitleOverlay({Key? key, this.text, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }
    print(text);
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        // Căn giữa Container trong không gian available
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ), // Thêm padding để có khoảng cách quanh text (tùy chọn)
            decoration: BoxDecoration(
              color: const Color.fromARGB(163, 36, 35, 35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              text!,
              style: const TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 13,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines:
                  null, // Cho phép text wrap xuống dòng nếu dài (tùy chọn)
            ),
          ),
        ),
      ),
    );
  }
}

String formatDate(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) {
    return '--/--/----';
  }

  try {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    return '----/--/--';
  }
}

Color getMaintenanceColor(String? type) {
  switch (type?.toLowerCase()) {
    case 'maintenance level 1':
      return Colors.cyan[700]!;
    case 'maintenance level 2':
      return Colors.orange[400]!;
    case 'maintenance level 3':
      return Colors.red[400]!;
    default:
      return Colors.indigo[200]!;
  }
}

String formatNumber(double value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return formatter.format(value.round());
}

class PermissionHelper {
  static Future<bool> has(String permission) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("permissions") ?? [];
    return list.contains(permission);
  }
}
