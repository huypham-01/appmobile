import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/routes/app_routes.dart';
import '../../../data/services/api_service.dart';
import '../../../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = '';
  bool _pushNotifications = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await ApiService.getUserInfo();
    if (info != null) {
      setState(() {
        _username = info["username"] ?? "";
      });
    }
  }

  /// Đọc ngôn ngữ đã lưu
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selectedLanguage');
    if (savedLang != null) {
      setState(() => _selectedLanguage = savedLang);
      _applySavedLocale(savedLang);
    }
  }

  /// Áp dụng locale dựa vào tên ngôn ngữ
  void _applySavedLocale(String language) {
    Locale locale;
    switch (language) {
      case 'English':
        locale = const Locale('en');
        break;
      case 'Chinese':
        locale = const Locale('zh');
        break;
      case 'Taiwanese':
        locale = const Locale('zh', 'TW');
        break;
      default:
        locale = const Locale('vi');
    }
    MyApp.of(context)?.changeLanguage(locale);
  }

  /// Lưu ngôn ngữ khi chọn
  Future<void> _saveLanguagePreference(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', lang);
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 14 : 9),
        child: isTablet
            ? _buildTabletLayout(localizations)
            : _buildMobileLayout(localizations),
      ),
    );
  }

  Widget _buildMobileLayout(AppLocalizations localizations) {
    return Column(
      children: [
        _buildUserCard(localizations),
        const SizedBox(height: 12),
        _buildLanguageSection(localizations),
        const SizedBox(height: 12),
        // _buildNotificationSection(localizations),
        const SizedBox(height: 12),
        _buildActionButtons(localizations),
      ],
    );
  }

  Widget _buildTabletLayout(AppLocalizations localizations) {
    return Column(
      children: [
        _buildUserCard(localizations),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildLanguageSection(localizations),
                  // const SizedBox(height: 16),
                  // _buildAppearanceSection(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  // _buildNotificationSection(localizations),
                  // const SizedBox(height: 16),
                  // _buildAdditionalFeaturesSection(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildActionButtons(localizations),
      ],
    );
  }

  // ---------------- USER CARD ----------------

  Widget _buildUserCard(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cusBlue, cusBlue.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cusBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              'A',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username.isNotEmpty ? _username : "Unknown User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- LANGUAGE ----------------

  Widget _buildLanguageSection(AppLocalizations localizations) {
    return _buildSettingCard(
      title: localizations.languageSection,
      icon: Icons.language,
      children: [
        _buildLanguageOption(
          'Vietnamese',
          localizations.vietnameseDisplay,
          const Locale('vi'),
        ),
        _buildLanguageOption(
          'English',
          localizations.englishDisplay,
          const Locale('en'),
        ),
        _buildLanguageOption(
          'Chinese',
          localizations.chineseDisplay,
          const Locale('zh'),
        ),
        _buildLanguageOption(
          'Taiwanese',
          localizations.taiwaneseDisplay,
          const Locale('zh', 'TW'),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String value, String display, Locale locale) {
    return RadioListTile<String>(
      title: Text(display),
      value: value,
      groupValue: _selectedLanguage,
      onChanged: (String? newValue) async {
        if (newValue != null) {
          setState(() => _selectedLanguage = newValue);
          await _saveLanguagePreference(newValue);
          MyApp.of(context)?.changeLanguage(locale);
        }
      },
      activeColor: cusBlue,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ---------------- NOTIFICATIONS ----------------

  Widget _buildNotificationSection(AppLocalizations localizations) {
    return _buildSettingCard(
      title: localizations.notificationsSection,
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          localizations.pushNotifications,
          localizations.receiveNotifications,
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
        ),
      ],
    );
  }

  // ---------------- APPEARANCE ----------------

  // Widget _buildAppearanceSection() {
  //   return _buildSettingCard(
  //     title: 'Appearance',
  //     icon: Icons.palette,
  //     children: [
  //       _buildSwitchTile(
  //         'Dark Mode',
  //         'Switch to dark theme',
  //         _darkMode,
  //         (value) => setState(() => _darkMode = value),
  //       ),
  //     ],
  //   );
  // }

  // ---------------- FEATURE SECTION ----------------

  // Widget _buildAdditionalFeaturesSection() {
  //   return _buildSettingCard(
  //     title: 'Features',
  //     icon: Icons.settings,
  //     children: [
  //       _buildFeatureTile(
  //         'Data Backup',
  //         'Backup your data',
  //         Icons.backup,
  //         () => _showFeatureDialog('Data Backup'),
  //       ),
  //       _buildFeatureTile(
  //         'Export Reports',
  //         'Export maintenance reports',
  //         Icons.file_download,
  //         () => _showFeatureDialog('Export Reports'),
  //       ),
  //       _buildFeatureTile(
  //         'Sync Settings',
  //         'Synchronize across devices',
  //         Icons.sync,
  //         () => _showFeatureDialog('Sync Settings'),
  //       ),
  //       _buildFeatureTile(
  //         'Help & Support',
  //         'Get help and contact support',
  //         Icons.help_outline,
  //         () => _showFeatureDialog('Help & Support'),
  //       ),
  //     ],
  //   );
  // }

  // ---------------- COMMON COMPONENTS ----------------

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cusBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: cusBlue),
        ],
      ),
    );
  }

  // Widget _buildFeatureTile(
  //   String title,
  //   String subtitle,
  //   IconData icon,
  //   VoidCallback onTap,
  // ) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(8),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: cusBlue, size: 22),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: const TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 Text(
  //                   subtitle,
  //                   style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButtons(AppLocalizations localizations) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            label: Text(localizations.signOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[300]!),
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.signOutConfirmTitle),
        content: Text(localizations.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.signOut),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ApiService.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  // void _showFeatureDialog(String feature) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(feature),
  //       content: Text('$feature feature will be available in the next update.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
