import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/utils/routes/fmcs_routes.dart';
import 'package:mobile/utils/routes/Ems_routes.dart';
import 'package:mobile/utils/routes/app_routes.dart';
import '../../main.dart'; // để gọi changeLanguage()

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _selectedLanguage = "";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString("selectedLanguage") ?? "";
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
              _languageOption("Vietnamese", const Locale('vi')),
              _languageOption("English", const Locale('en')),
              _languageOption("Chinese", const Locale('zh')),
              _languageOption("Taiwanese", const Locale('zh', 'TW')),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(String label, Locale locale) {
    return RadioListTile<String>(
      title: Row(
        children: [
          // Image.asset(flagPath, width: 28, height: 18, fit: BoxFit.cover),
          // const SizedBox(width: 10),
          Text(label),
        ],
      ),
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
        "description": "Computerized Maintenance Management System",
        "icon": Icons.settings,
        "color": Colors.blue,
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
        "description": "Equipment Management System",
        "icon": Icons.energy_savings_leaf_outlined,
        "color": Colors.green,
        "onTap": () {
          Navigator.pushNamed(context, EmsRoutes.home);
        },
      },
      {
        "title": "FMCS",
        "description": "Facility Management Control System",
        "icon": Icons.apartment_rounded,
        "color": Colors.orange,
        "onTap": () {
          Navigator.pushNamed(context, FmcsRoutes.home);
        },
      },
      // {
      //   "title": "test",
      //   "description": "test",
      //   "icon": Icons.apartment_rounded,
      //   "color": Colors.orange,
      //   "onTap": () async {
      //     await MaintenanceNotificationService.fetchAndSaveMaintenanceData();

      //     // 2. Hẹn giờ báo 7:00 và 19:00 mỗi ngày
      //     await MaintenanceNotificationService.scheduleDailyAlarms();

      //     await MaintenanceNotificationService.testAfterSeconds(15);
      //   },
      // },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: systems.length,
          itemBuilder: (context, index) {
            final item = systems[index];

            return GestureDetector(
              onTap: item["onTap"],
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                shadowColor: Colors.black26,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item["color"].withOpacity(0.9),
                          item["color"].withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: item["title"],
                          child: Icon(
                            item["icon"],
                            size: 58,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black38,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["description"],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // ---------- BOTTOM BAR ----------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomButton(
                icon: Icons.language,
                label: AppLocalizations.of(context)!.language,
                onTap: () => _showLanguageDialog(context),
              ),
              _BottomButton(
                icon: Icons.help_outline,
                label: AppLocalizations.of(context)!.bottomButtonInstructions,
                onTap: () => Navigator.pushNamed(context, AppRoutes.onboarding),
              ),
            ],
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Colors.blueGrey),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
