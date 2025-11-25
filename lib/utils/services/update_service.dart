import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  // URL của file version.json trên server của bạn
  // static const String versionUrl = 'https://your-domain.com/version.json';

  /// Hàm chính để kiểm tra update
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Lấy thông tin version hiện tại của App
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // 2. Gọi API lấy thông tin version mới nhất
      var dio = Dio();
      // var response = await dio.get(versionUrl);

      if (2 != 2) {
        // Map<String, dynamic> data = response.data;
        // String newVersion = data['version'];
        // String apkUrl = data['url'];
        // String description = data['description'] ?? "Có bản cập nhật mới.";

        // 3. So sánh version (Logic đơn giản, bạn có thể viết hàm so sánh kỹ hơn)
        if (true) {
          // 4. Hiển thị Popup
          _showUpdateDialog(
            context,
            "http://192.168.110.2/web_develop/landing-page/smart-factory.apk",
            "1.0.1",
            "testttt desc",
          );
        }
      }
    } catch (e) {
      print("Lỗi kiểm tra update: $e");
    }
  }

  // Hàm so sánh version đơn giản (VD: "1.0.0" vs "1.0.1")
  static bool _isNewerVersion(String current, String newVer) {
    // Có thể dùng logic tách chuỗi dấu chấm để so sánh chính xác hơn
    return current != newVer;
  }

  /// Hiển thị Popup xác nhận cập nhật
  static void _showUpdateDialog(
    BuildContext context,
    String url,
    String version,
    String desc,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng chọn
      builder: (context) => AlertDialog(
        title: Text("Cập nhật phiên bản $version"),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog cũ
              _showDownloadProgress(context, url); // Mở dialog download
            },
            child: Text("Cập nhật ngay"),
          ),
        ],
      ),
    );
  }

  /// Màn hình/Dialog hiển thị tiến trình tải và cài đặt
  static void _showDownloadProgress(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        double progress = 0.0;
        String progressText = "Đang chuẩn bị...";

        return StatefulBuilder(
          builder: (context, setState) {
            // Bắt đầu tải ngay khi Dialog mở
            if (progress == 0.0) {
              _downloadAndInstall(
                "http://192.168.110.2/web_develop/landing-page/smart-factory.apk",
                (received, total) {
                  setState(() {
                    progress = received / total;
                    progressText =
                        "Đang tải: ${(progress * 100).toStringAsFixed(0)}%";
                  });

                  // Nếu tải xong (100%)
                  if (progress >= 1.0) {
                    Navigator.pop(context); // Đóng dialog
                  }
                },
              );
            }

            return AlertDialog(
              title: Text("Đang tải xuống..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  SizedBox(height: 10),
                  Text(progressText),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Logic tải file và gọi lệnh cài đặt
  static Future<void> _downloadAndInstall(
    String url,
    Function(int, int) onProgress,
  ) async {
    try {
      // Xin quyền lưu trữ (cho Android < 10, Android 10+ tự động quản lý scoped storage)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // Xác định đường dẫn lưu file tạm
      // Lưu ý: Dùng getExternalStorageDirectory trên Android để file có thể truy cập bởi Installer
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null)
        dir = await getApplicationDocumentsDirectory(); // Fallback

      String savePath = "${dir.path}/new_version.apk";

      // Tải file
      Dio dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: onProgress);

      // Tải xong -> Mở file để cài đặt
      print("Tải xong tại: $savePath");

      // OpenFilex tự động xử lý FileProvider và Intent
      final result = await OpenFilex.open(savePath);
      print("Kết quả mở file: ${result.type} - ${result.message}");
    } catch (e) {
      print("Lỗi tải file: $e");
    }
  }
}
