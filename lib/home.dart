import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/utils/routes/fmcs_routes.dart';
import 'package:mobile/utils/routes/Ems_routes.dart';
import 'package:mobile/utils/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../main.dart'; // để gọi changeLanguage()

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _selectedLanguage = "";
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadAppVersion();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString("selectedLanguage") ?? "";
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "${packageInfo.version} (${packageInfo.buildNumber})";
      // Hoặc chỉ hiển thị version: _appVersion = packageInfo.version;
    });
  }

  // ----- SHOW LANGUAGE DIALOG -----
  void _showLanguageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(
                AppLocalizations.of(context)!.vietnamese,
                const Locale('vi'),
              ),
              _languageOption(
                AppLocalizations.of(context)!.english,
                const Locale('en'),
              ),
              _languageOption(
                AppLocalizations.of(context)!.chinese,
                const Locale('zh'),
              ),
              _languageOption(
                AppLocalizations.of(context)!.taiwanese,
                const Locale('zh', 'TW'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(String label, Locale locale) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: _selectedLanguage,
      onChanged: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("selectedLanguage", value!);

        setState(() => _selectedLanguage = value);

        // Apply locale
        MyApp.of(context)?.changeLanguage(locale);

        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> systems = [
      {
        "title": "CMMS",
        "description": AppLocalizations.of(context)!.cmmsDescription,
        "icon": Icons.build_outlined,
        "color": Colors.blue.shade50,
        "onTap": () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            arguments: "cmms",
            (route) => false,
          );
        },
      },
      {
        "title": "EMS",
        "description": AppLocalizations.of(context)!.emsDescription,
        "icon": Icons.factory_outlined,
        "color": Colors.blue.shade50,
        "onTap": () {
          Navigator.pushNamed(context, EmsRoutes.home);
        },
      },
      {
        "title": "FMCS",
        "description": AppLocalizations.of(context)!.fmcsDescription,
        "icon": Icons.devices_other_outlined,
        "color": Colors.blue.shade50,
        "onTap": () {
          Navigator.pushNamed(context, FmcsRoutes.home);
        },
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Grid Systems
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: systems.length,
                  itemBuilder: (context, index) {
                    final item = systems[index];

                    return GestureDetector(
                      onTap: item["onTap"],
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item["color"],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item["icon"],
                                size: 40,
                                color: Colors.blue.shade300,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item["title"],
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                item["description"],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Version Info
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppLocalizations.of(context)!.appVersion(_appVersion),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------- BOTTOM BAR ----------
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomButton(
                  icon: Icons.language_outlined,
                  label: AppLocalizations.of(context)!.language,
                  onTap: () => _showLanguageDialog(context),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _BottomButton(
                  icon: Icons.help_outline,
                  label: AppLocalizations.of(context)!.bottomButtonInstructions,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.onboarding),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----- REUSABLE BOTTOM BUTTON -----
class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.grey.shade700),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
