import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';

class UpdateService {
  static const String apiUrl =
      '$baseUrl/landing-page/app_vcm/backend/?c=File&m=listApps&q=SMART-FACTORY';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      var dio = Dio();
      var response = await dio.get(apiUrl);

      if (response.statusCode != 200) return;

      List data = response.data;
      if (data.isEmpty) return;

      var item = data.first;
      String newVersion = item["version"];
      String apkUrl = item["url"];

      if (_isNewerVersion(currentVersion, newVersion)) {
        _showUpdateDialog(
          context,
          apkUrl,
          newVersion,
          AppLocalizations.of(context)!.updateDescription,
        );
      }
    } catch (e, s) {
      print("❌ Lỗi kiểm tra update: $e");
      print(s);
    }
  }

  static bool _isNewerVersion(String current, String newVer) {
    List<int> c = _parseVer(current);
    List<int> n = _parseVer(newVer);

    for (int i = 0; i < 3; i++) {
      if (n[i] > c[i]) return true;
      if (n[i] < c[i]) return false;
    }
    return false;
  }

  static List<int> _parseVer(String v) {
    List<String> p = v.split(".");
    while (p.length < 3) p.add("0");
    return p.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static void _showUpdateDialog(
    BuildContext context,
    String url,
    String version,
    String desc,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          AppLocalizations.of(context)!.updateDialogTitle(version),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Màu xanh để giống liên kết
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              // Không có backgroundColor để không trông như nút
            ),
            child: Text(AppLocalizations.of(context)!.updateLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDownloadProgress(context, url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(AppLocalizations.of(context)!.updateNow),
          ),
        ],
      ),
    );
  }

  static void _showDownloadProgress(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDownloading = false;
        double progress = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            if (!isDownloading) {
              isDownloading = true;

              _downloadAndInstall(url, (received, total) {
                if (total > 0) {
                  setState(() {
                    progress = received / total;
                  });
                }

                if (progress >= 1) {
                  Navigator.pop(context);
                }
              });
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.downloadingTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  SizedBox(height: 10),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _downloadAndInstall(
    String url,
    Function(int, int) onProgress,
  ) async {
    try {
      Directory dir = Directory('/storage/emulated/0/Download');
      String savePath = "${dir.path}/smart_factory_update.apk";

      Dio dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: onProgress);

      await OpenFilex.open(savePath);
    } catch (e) {
      print("❌ Lỗi tải file: $e");
    }
  }
}
