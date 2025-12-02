import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/utils/helper/onboarding_helper.dart';
import 'package:mobile/utils/routes/app_routes.dart';
import 'package:mobile/utils/routes/cmms_routes.dart';
import 'package:app_links/app_links.dart';
import 'package:mobile/utils/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Timer? _debounceTimer;
  String _lastProcessedOtp = '';
  bool _showOtpField = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _checkFirstLaunch();
    otpController.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _debounceTimer?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App state changed: $state');
    if (state == AppLifecycleState.resumed) {
      print('🔍 [Resume] OTP: "${otpController.text}"');
      print('🔍 [Resume] Username: "${usernameController.text}"');
      print(
        '🔍 [Resume] Password: ${passwordController.text.isNotEmpty ? "có" : "không"}',
      );
    }
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await OnboardingHelper.isFirstTime();
    setState(() {
      _showOtpField = !isFirst;
    });
    print('🔍 [LoginScreen] Lần đầu: $isFirst → showOtp=$_showOtpField');
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Lắng nghe stream deeplink với debounce
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('📩 [LoginScreen] Nhận URI từ stream: $uri');

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          _handleIncomingLink(uri);
        }
      });
    });
  }

  void _handleIncomingLink(Uri uri) {
    print('🔗 [LoginScreen] Xử lý incoming link: $uri (host: ${uri.host})');

    if (uri.host == 'login') {
      final otp = uri.queryParameters['otp'];
      if (otp != null && otp.isNotEmpty) {
        if (otp == _lastProcessedOtp) {
          print('⏭️ [LoginScreen] Bỏ qua OTP trùng: $otp');
          return;
        }

        print('✅ [LoginScreen] Nhận OTP mới: $otp');
        _lastProcessedOtp = otp;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          print('✅ [LoginScreen] PostFrameCallback - set OTP');

          otpController.value = TextEditingValue(
            text: otp,
            selection: TextSelection.collapsed(offset: otp.length),
          );

          if (mounted) {
            setState(() {});
          }

          print('🔍 [LoginScreen] OTP đã set: "${otpController.text}"');
        });
      }
    }
  }

  Future<void> openOtpApp() async {
    print('💾 [LoginScreen] Trước khi mở OTP:');
    print('   Username: "${usernameController.text}"');
    print(
      '   Password: ${passwordController.text.isNotEmpty ? "có" : "không"}',
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final otpAppUri = Uri.parse('myotpapp://generate?from=login&t=$timestamp');

    try {
      await launchUrl(otpAppUri, mode: LaunchMode.externalApplication);
      print('✅ [LoginScreen] Đã mở app OTP');
    } catch (e) {
      print('❌ [LoginScreen] Không mở được app OTP: $e');
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorCannotOpenOtpApp);
      }
    }
  }

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final otp = otpController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError(AppLocalizations.of(context)!.errorEmptyFields);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.login(username, password, otp);
      if (response['success'] == true) {
        otpController.clear();
        _lastProcessedOtp = '';
        // final decoded = await ApiService.decodeToken();
        // print('🔓 Decode token: $decoded');

        print('✅ Login thành công, chuyển màn hình');

        // await NotificationManager.onLogin();
        // await NotificationManagerV2.fetchAllData();
        await MaintenanceNotificationService.fetchAndSaveMaintenanceData();

        // 2. Hẹn giờ báo 7:00 và 19:00 mỗi ngày
        await MaintenanceNotificationService.scheduleDailyAlarms();

        if (mounted) {
          if (useMock) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              CmmsRoutes.main, // hoặc AppRoutes.home tùy bạn đặt trang chính
              (route) => false,
            );
            return;
          }
          if (_showOtpField) {
            // 👉 Chuyển sang trang đổi mật khẩu
            Navigator.pushNamedAndRemoveUntil(
              context,
              CmmsRoutes.main,
              (route) => false,
            );
          } else {
            // 👉 Không phải lần đầu → vào trang chính

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.changepassword,
              (route) => false,
            );
          }
        }
      } else {
        _showError(response['message']);
        setState(() => otpController.clear());
      }
    } catch (e) {
      print('❌ Lỗi khi đăng nhập: $e');
      _showError(AppLocalizations.of(context)!.errorUnableConnect);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        keyboardType: maxLength == 6
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: suffixIcon,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
          ),
          counterText: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _lastProcessedOtp = '';
              _linkSubscription?.cancel();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            tooltip: "Back",
          ),
          backgroundColor: Colors.white,
          elevation: 2,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 60, color: cusBlue),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.loginTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: cusBlue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 300,
                      child: _buildTextField(
                        label: AppLocalizations.of(context)!.usernameLabel,
                        icon: Icons.person_outline,
                        controller: usernameController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: _buildTextField(
                        label: AppLocalizations.of(context)!.passwordLabel,
                        icon: Icons.lock_outline,
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_showOtpField) ...[
                      SizedBox(
                        width: 300,
                        child: _buildTextField(
                          label: AppLocalizations.of(context)!.otpCodeLabel,
                          icon: Icons.security_outlined,
                          controller: otpController,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => otpController.clear());
                            await openOtpApp();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.getOtp,
                            style: TextStyle(
                              fontSize: 14,
                              color: cusBlue,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 300,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cusBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _login,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                AppLocalizations.of(context)!.loginButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
  }
}
