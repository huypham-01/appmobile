import 'package:flutter/material.dart';
import 'package:mobile/ems/data/models/machine_model.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';

import '../../ems/data/auth_api_service.dart';
import '../../main.dart';
import '../../utils/routes/Ems_routes.dart';
import '../../utils/routes/app_routes.dart';
import 'widgets/tab_screen.dart';

class HomeEms extends StatefulWidget {
  const HomeEms({super.key});

  @override
  State<HomeEms> createState() => _HomeEmsState();
}

class _HomeEmsState extends State<HomeEms> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoggedIn = false;
  bool canApprove = false;
  bool canAction = false;

  // Thống kê cho từng tab
  Map<String, TabStats> tabStatsMap = {
    'mold': TabStats(),
    'tuft': TabStats(),
    'blister': TabStats(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged); // Lắng nghe sự thay đổi tab
    _loadAuthState();
    _loadPermissions();
  }

  void _loadPermissions() async {
    canApprove = await PermissionHelper.has("approve.action.ems");
    canAction = await PermissionHelper.has("view.list.action");
    setState(() {});
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {}); // Rebuild để cập nhật stats hiển thị
    }
  }

  Future<void> _loadAuthState() async {
    final loggedIn = await ApiServiceAuth.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  // Callback để nhận thống kê từ TabScreen
  void _updateTabStats(String keyword, TabStats stats) {
    if (mounted) {
      setState(() {
        tabStatsMap[keyword] = stats;
      });
    }
  }

  // Lấy stats của tab hiện tại
  TabStats get currentTabStats {
    final keywords = ['mold', 'tuft', 'blister'];
    final currentKeyword = keywords[_tabController.index];
    return tabStatsMap[currentKeyword] ?? TabStats();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            // fontFamily: "NotoSansSC",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = currentTabStats; // Lấy stats của tab hiện tại

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/images/acumenIcon.png", height: 26),
            const SizedBox(width: 10),
            const Text(
              "EMS",
              style: TextStyle(
                color: Color.fromARGB(221, 35, 34, 34),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: "NotoSansSC",
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, EmsRoutes.dashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A7BEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.dashboard,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              icon: const Icon(
                Icons.menu_sharp,
                color: Colors.black87,
                size: 30,
              ),
              onSelected: (value) async {
                if (value == 'login') {
                  Navigator.pushNamed(context, EmsRoutes.login).then((_) async {
                    final loggedIn = await ApiServiceAuth.isLoggedIn();
                    if (mounted) setState(() => _isLoggedIn = loggedIn);
                  });
                } else if (value == 'logout') {
                  await ApiServiceAuth.logout();
                  if (mounted) setState(() => _isLoggedIn = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                } else if (value == 'menu1') {
                  if (_isLoggedIn) {
                    Navigator.pushNamed(context, EmsRoutes.system);
                  } else {
                    Navigator.pushNamed(context, EmsRoutes.login).then((
                      _,
                    ) async {
                      final loggedIn = await ApiServiceAuth.isLoggedIn();
                      if (mounted) setState(() => _isLoggedIn = loggedIn);
                    });
                  }
                } else if (value == 'menu3') {
                  await ApiServiceAuth.logout();
                  if (mounted) setState(() => _isLoggedIn = false);
                  Navigator.pushNamed(context, AppRoutes.home);
                } else if (value == 'menu4') {
                  if (_isLoggedIn) {
                    Navigator.pushNamed(context, EmsRoutes.action);
                  } else {
                    Navigator.pushNamed(context, EmsRoutes.login).then((
                      _,
                    ) async {
                      final loggedIn = await ApiServiceAuth.isLoggedIn();
                      if (mounted) setState(() => _isLoggedIn = loggedIn);
                    });
                  }
                } else if (value == 'language') {
                  // Hiển thị menu phụ
                  await showMenu<String>(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 100, 20, 0),
                    items: [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          AppLocalizations.of(context)!.selectLanguage,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lang_en',
                        child: Text('English'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lang_vi',
                        child: Text('Tiếng Việt'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lang_zh',
                        child: Text('中文（简体）'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'lang_tw',
                        child: Text('中文（繁體）'),
                      ),
                    ],
                    elevation: 8,
                  ).then((selected) {
                    if (selected == null) return;
                    if (selected == 'lang_en') {
                      MyApp.of(context)?.changeLanguage(const Locale('en'));
                    } else if (selected == 'lang_vi') {
                      MyApp.of(context)?.changeLanguage(const Locale('vi'));
                    } else if (selected == 'lang_zh') {
                      MyApp.of(context)?.changeLanguage(const Locale('zh'));
                    } else if (selected == 'lang_tw') {
                      MyApp.of(
                        context,
                      )?.changeLanguage(const Locale('zh', 'TW'));
                    }
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'menu1',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.systemSettings),
                    ],
                  ),
                ),
                if (canApprove) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'menu4',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.grey, size: 20),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context)!.action),
                      ],
                    ),
                  ),
                ],

                const PopupMenuDivider(),

                // 🌐 Mục menu cấp 1
                // PopupMenuItem(
                //   value: 'language',
                //   child: Row(
                //     children: [
                //       Icon(Icons.language, color: Colors.blueGrey, size: 20),
                //       SizedBox(width: 10),
                //       Text(AppLocalizations.of(context)!.language),
                //     ],
                //   ),
                // ),
                // const PopupMenuDivider(),
                PopupMenuItem(
                  value: _isLoggedIn ? 'logout' : 'login',
                  child: Row(
                    children: [
                      Icon(
                        _isLoggedIn ? Icons.logout : Icons.login,
                        color: _isLoggedIn ? Colors.red : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isLoggedIn
                            ? AppLocalizations.of(context)!.logout
                            : AppLocalizations.of(context)!.login,
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'menu3',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.back),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 4,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: _buildAllChips(stats, small: true)
                            .map(
                              (chip) => SizedBox(
                                width: (constraints.maxWidth - 32) / 3,
                                child: chip,
                              ),
                            )
                            .toList(),
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildAllChips(stats, small: false)
                            .map(
                              (chip) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: chip,
                              ),
                            )
                            .toList(),
                      );
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(color: Colors.white),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicator: BoxDecoration(
                    color: const Color(0xFF5A7BEF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: -9,
                    vertical: 2,
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tabs: [
                    _buildTab(
                      Icons.show_chart_sharp,
                      AppLocalizations.of(context)!.mold,
                    ),
                    _buildTab(
                      Icons.show_chart_outlined,
                      AppLocalizations.of(context)!.tuft,
                    ),
                    _buildTab(
                      Icons.show_chart,
                      AppLocalizations.of(context)!.blister,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabScreen(
            keywork: "mold",
            onStatsUpdate: (stats) => _updateTabStats("mold", stats),
            canAction: canAction,
          ),
          TabScreen(
            keywork: "tuft",
            onStatsUpdate: (stats) => _updateTabStats("tuft", stats),
            canAction: canAction,
          ),
          TabScreen(
            keywork: "blister",
            onStatsUpdate: (stats) => _updateTabStats("blister", stats),
            canAction: canAction,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllChips(TabStats stats, {bool small = false}) {
    return [
      _buildStatusChip(
        AppLocalizations.of(context)!.online,
        stats.online.toString(),
        Colors.green.shade100,
        Colors.green,
        small: small,
      ),
      _buildStatusChip(
        AppLocalizations.of(context)!.offline,
        stats.offline.toString(),
        Colors.grey.shade300,
        Colors.grey,
        small: small,
      ),
      _buildStatusChip(
        AppLocalizations.of(context)!.flexible,
        stats.flexible.toString(),
        Colors.blue.shade100,
        Colors.blue,
        small: small,
      ),
      _buildStatusChip(
        AppLocalizations.of(context)!.warning,
        stats.warning.toString(),
        Colors.red.shade100,
        Colors.red,
        small: small,
      ),
      _buildStatusChip(
        AppLocalizations.of(context)!.total,
        stats.total.toString(),
        Colors.lightBlue.shade100,
        Colors.blue.shade700,
        small: small,
      ),
      _buildStatusChip(
        AppLocalizations.of(context)!.action,
        stats.action.toString(),
        Colors.purple.shade100,
        Colors.purple,
        small: small,
      ),
    ];
  }

  Widget _buildStatusChip(
    String label,
    String value,
    Color bgColor,
    Color borderColor, {
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 4 : 6,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Text(
          "$label: $value",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            // fontFamily: "NotoSansSC",
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    );
  }
}
