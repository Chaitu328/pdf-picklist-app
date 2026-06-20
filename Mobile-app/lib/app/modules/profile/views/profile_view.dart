import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../../../services/theme_controller.dart';

class _DT {
  static ThemeController get _tc => Get.find<ThemeController>();
  static bool get isDark => _tc.isDarkMode.value;

  static Color get bg => isDark ? const Color(0xFF060A16) : const Color(0xFFF5F6FA);
  static Color get cardBg => isDark ? const Color(0xFF0E1220) : Colors.white;
  static Color get textPrimary => isDark ? const Color(0xFFE8EAF6) : const Color(0xFF1E293B);
  static Color get textSecondary => isDark ? const Color(0xFF8B92A9) : const Color(0xFF64748B);
  static Color get dividerColor => isDark ? Colors.white12 : const Color(0xFFE2E8F0);
}

// ══════════════════════════════════════════════════════════════════════════════
//  ProfileView
// ══════════════════════════════════════════════════════════════════════════════

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final String email = box.read("user_token") != null
        ? (box.read("user_email") ?? 'User')
        : 'User';
    final String role = box.read("user_role") ?? 'worker';
    final bool isManager = role == 'manager';
    final themeCtrl = Get.find<ThemeController>();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.cAppPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.cAppPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Obx(() {
      final isDarkTheme = _DT.isDark;
      return Scaffold(
        backgroundColor: _DT.bg,
        appBar: AppBar(
          backgroundColor: AppColor.cAppPrimaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: isDarkTheme
                  ? const Icon(Icons.light_mode_rounded, color: Colors.white)
                  : const Icon(Icons.dark_mode_rounded, color: Colors.white),
              onPressed: themeCtrl.toggleTheme,
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile header ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColor.cAppPrimaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Icon(
                        isManager
                            ? Icons.manage_accounts_rounded
                            : Icons.engineering_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      email,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isManager ? 'Manager' : 'Worker',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Settings list ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _DT.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isDarkTheme ? 0.35 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _themeToggleTile(themeCtrl),
                      _divider(),
                      _settingsTile(
                        icon: Icons.lock_outline,
                        label: 'Privacy & Security',
                        onTap: () =>
                            Get.to(() => const PrivacySecurityView()),
                      ),
                      _divider(),
                      _settingsTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notification Preferences',
                        onTap: () => Get.to(
                                () => const NotificationPreferencesView()),
                      ),
                      _divider(),
                      _settingsTile(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () =>
                            Get.to(() => const HelpSupportView()),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Logout ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _DT.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isDarkTheme ? 0.35 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 22),
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.red),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text('Log Out'),
                          content: const Text(
                              'Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.pop(ctx);
                                box.remove('user_token');
                                box.remove('user_role');
                                box.remove('user_id');
                                box.remove('user_email');
                                Get.offAllNamed(AppRoutes.login);
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _themeToggleTile(ThemeController themeCtrl) {
    return SwitchListTile.adaptive(
      value: _DT.isDark,
      onChanged: (val) => themeCtrl.toggleTheme(),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.cAppPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _DT.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: AppColor.cAppPrimaryColor,
          size: 22,
        ),
      ),
      title: Text(
        'Dark Theme',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _DT.textPrimary,
        ),
      ),
      activeColor: AppColor.cAppPrimaryColor,
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.cAppPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColor.cAppPrimaryColor, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _DT.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: _DT.isDark ? Colors.grey.shade500 : Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 60, endIndent: 16, color: _DT.dividerColor);
}

// ══════════════════════════════════════════════════════════════════════════════
//  Shared widgets
// ══════════════════════════════════════════════════════════════════════════════

/// Toggle row — onChanged is nullable so it can be disabled.
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged; // nullable → disabled state

  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onChanged == null;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _DT.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11, color: _DT.textSecondary),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged, // null disables the switch
              activeColor: AppColor.cAppPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Info / navigation row.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _DT.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11, color: _DT.textSecondary),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right,
                  color: _DT.isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Card wrapper with optional section label.
class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _DT.textSecondary,
                    letterSpacing: 0.8),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: _DT.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(_DT.isDark ? 0.35 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                        height: 1, indent: 70, endIndent: 16, color: _DT.dividerColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared scaffold for sub-pages.
class _SettingsScaffold extends StatelessWidget {
  final String title;
  final List<Widget> slivers;

  const _SettingsScaffold(
      {required this.title, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: _DT.bg,
        appBar: AppBar(
          backgroundColor: AppColor.cAppPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slivers,
          ),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Privacy & Security
// ══════════════════════════════════════════════════════════════════════════════

class PrivacySecurityView extends StatefulWidget {
  const PrivacySecurityView({super.key});

  @override
  State<PrivacySecurityView> createState() =>
      _PrivacySecurityViewState();
}

class _PrivacySecurityViewState extends State<PrivacySecurityView> {
  // ── Privacy ───────────────────────────────────────────────────────────
  late bool _allowScreenshots;
  late bool _activityTracking;
  late bool _locationSharing;
  late bool _analyticsData;

  // ── Security ──────────────────────────────────────────────────────────
  late bool _biometricLogin;
  late bool _twoFactorAuth;
  late bool _autoLock;

  @override
  void initState() {
    super.initState();
    _allowScreenshots = box.read('allow_screenshots') ?? true;
    _activityTracking = box.read('activity_tracking') ?? true;
    _locationSharing = box.read('location_sharing') ?? false;
    _analyticsData = box.read('analytics_data') ?? true;
    _biometricLogin = box.read('biometric_login') ?? false;
    _twoFactorAuth = box.read('two_factor_auth') ?? false;
    _autoLock = box.read('auto_lock') ?? true;
  }

  void _save(String key, bool v) => box.write(key, v);

  void _showSnack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white)),
      backgroundColor:
      success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Privacy & Security',
      slivers: [
        // ── Privacy ────────────────────────────────────────────────────
        _SectionCard(
          title: 'Privacy',
          children: [
            _ToggleRow(
              icon: Icons.screenshot_monitor_rounded,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              title: 'Allow Screenshots',
              subtitle: 'Let users capture screen content',
              value: _allowScreenshots,
              onChanged: (v) {
                setState(() => _allowScreenshots = v);
                _save('allow_screenshots', v);
                _showSnack(
                  v
                      ? 'Screenshots enabled'
                      : 'Screenshots disabled',
                  success: v,
                );
              },
            ),
            _ToggleRow(
              icon: Icons.track_changes_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Activity Tracking',
              subtitle: 'Track in-app usage for improvements',
              value: _activityTracking,
              onChanged: (v) {
                setState(() => _activityTracking = v);
                _save('activity_tracking', v);
              },
            ),
            _ToggleRow(
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'Location Sharing',
              subtitle: 'Share your location with the team',
              value: _locationSharing,
              onChanged: (v) {
                setState(() => _locationSharing = v);
                _save('location_sharing', v);
              },
            ),
            _ToggleRow(
              icon: Icons.bar_chart_rounded,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Analytics Data',
              subtitle: 'Share anonymous usage analytics',
              value: _analyticsData,
              onChanged: (v) {
                setState(() => _analyticsData = v);
                _save('analytics_data', v);
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Security ───────────────────────────────────────────────────
        _SectionCard(
          title: 'Security',
          children: [
            _ToggleRow(
              icon: Icons.fingerprint_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or Face ID to sign in',
              value: _biometricLogin,
              onChanged: (v) {
                setState(() => _biometricLogin = v);
                _save('biometric_login', v);
                _showSnack(
                    v
                        ? 'Biometric login enabled'
                        : 'Biometric login enabled',
                    success: v);
              },
            ),
            _ToggleRow(
              icon: Icons.security_rounded,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'Two-Factor Auth',
              subtitle: 'Require a code on each login',
              value: _twoFactorAuth,
              onChanged: (v) {
                setState(() => _twoFactorAuth = v);
                _save('two_factor_auth', v);
              },
            ),
            _ToggleRow(
              icon: Icons.lock_clock_rounded,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Auto-Lock',
              subtitle: 'Lock app after 5 min of inactivity',
              value: _autoLock,
              onChanged: (v) {
                setState(() => _autoLock = v);
                _save('auto_lock', v);
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Account actions ────────────────────────────────────────────
        _SectionCard(
          title: 'Account',
          children: [
            _InfoRow(
              icon: Icons.password_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showChangePasswordSheet(),
            ),
            _InfoRow(
              icon: Icons.delete_outline_rounded,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              title: 'Delete Account',
              subtitle: 'Permanently remove your account',
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Change password sheet ──────────────────────────────────────────────

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Change Password',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _pwField(currentCtrl, 'Current Password'),
            const SizedBox(height: 10),
            _pwField(newCtrl, 'New Password'),
            const SizedBox(height: 10),
            _pwField(confirmCtrl, 'Confirm New Password'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cAppPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack('Password updated successfully');
                },
                child: const Text('Update Password',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pwField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: Color(0xFFCBD5E1)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: AppColor.cAppPrimaryColor, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: const Icon(Icons.lock_outline,
            color: Color(0xFF94A3B8)),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This action is permanent. All your data will be deleted and cannot be recovered.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Notification Preferences
// ══════════════════════════════════════════════════════════════════════════════

class NotificationPreferencesView extends StatefulWidget {
  const NotificationPreferencesView({super.key});

  @override
  State<NotificationPreferencesView> createState() =>
      _NotificationPreferencesViewState();
}

class _NotificationPreferencesViewState
    extends State<NotificationPreferencesView> {
  // ── Push ──────────────────────────────────────────────────────────────
  late bool _pushEnabled;
  late bool _pickListAssigned;
  late bool _pickListUpdated;
  late bool _submitConfirm;

  // ── In-app ────────────────────────────────────────────────────────────
  late bool _inAppEnabled;
  late bool _inAppSounds;
  late bool _inAppVibration;

  // ── Email ─────────────────────────────────────────────────────────────
  late bool _emailSummary;
  late bool _emailAlerts;

  @override
  void initState() {
    super.initState();
    _pushEnabled = box.read('notif_push') ?? true;
    _pickListAssigned = box.read('notif_pick_assigned') ?? true;
    _pickListUpdated = box.read('notif_pick_updated') ?? true;
    _submitConfirm = box.read('notif_submit_confirm') ?? true;
    _inAppEnabled = box.read('notif_in_app') ?? true;
    _inAppSounds = box.read('notif_in_app_sound') ?? true;
    _inAppVibration = box.read('notif_in_app_vibration') ?? false;
    _emailSummary = box.read('notif_email_summary') ?? false;
    _emailAlerts = box.read('notif_email_alerts') ?? false;
  }

  void _save(String key, bool v) => box.write(key, v);

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Notifications',
      slivers: [
        // ── Push ───────────────────────────────────────────────────────
        _SectionCard(
          title: 'Push Notifications',
          children: [
            _ToggleRow(
              icon: Icons.notifications_active_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Push Notifications',
              subtitle: 'Receive alerts on your device',
              value: _pushEnabled,
              onChanged: (v) {
                setState(() => _pushEnabled = v);
                _save('notif_push', v);
              },
            ),
            _ToggleRow(
              icon: Icons.assignment_turned_in_rounded,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'Pick List Assigned',
              subtitle: 'Alert when a new pick list is assigned',
              value: _pickListAssigned,
              // null when parent disabled → switch greys out
              onChanged: _pushEnabled
                  ? (v) {
                setState(() => _pickListAssigned = v);
                _save('notif_pick_assigned', v);
              }
                  : null,
            ),
            _ToggleRow(
              icon: Icons.update_rounded,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Pick List Updated',
              subtitle: 'Alert when a pick list changes',
              value: _pickListUpdated,
              onChanged: _pushEnabled
                  ? (v) {
                setState(() => _pickListUpdated = v);
                _save('notif_pick_updated', v);
              }
                  : null,
            ),
            _ToggleRow(
              icon: Icons.check_circle_outline_rounded,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'Submission Confirmation',
              subtitle: 'Alert when a pick list is submitted',
              value: _submitConfirm,
              onChanged: _pushEnabled
                  ? (v) {
                setState(() => _submitConfirm = v);
                _save('notif_submit_confirm', v);
              }
                  : null,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── In-App ────────────────────────────────────────────────────
        _SectionCard(
          title: 'In-App',
          children: [
            _ToggleRow(
              icon: Icons.notification_important_outlined,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              title: 'In-App Notifications',
              subtitle: 'Show banners inside the app',
              value: _inAppEnabled,
              onChanged: (v) {
                setState(() => _inAppEnabled = v);
                _save('notif_in_app', v);
              },
            ),
            _ToggleRow(
              icon: Icons.volume_up_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Sound',
              subtitle: 'Play a sound for in-app alerts',
              value: _inAppSounds,
              onChanged: _inAppEnabled
                  ? (v) {
                setState(() => _inAppSounds = v);
                _save('notif_in_app_sound', v);
              }
                  : null,
            ),
            _ToggleRow(
              icon: Icons.vibration_rounded,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Vibration',
              subtitle: 'Vibrate on in-app notifications',
              value: _inAppVibration,
              onChanged: _inAppEnabled
                  ? (v) {
                setState(() => _inAppVibration = v);
                _save('notif_in_app_vibration', v);
              }
                  : null,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Email ─────────────────────────────────────────────────────
        _SectionCard(
          title: 'Email',
          children: [
            _ToggleRow(
              icon: Icons.email_outlined,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Daily Summary',
              subtitle: 'Receive a daily email digest',
              value: _emailSummary,
              onChanged: (v) {
                setState(() => _emailSummary = v);
                _save('notif_email_summary', v);
              },
            ),
            _ToggleRow(
              icon: Icons.mark_email_unread_outlined,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              title: 'Critical Alerts',
              subtitle: 'Email for urgent or overdue items',
              value: _emailAlerts,
              onChanged: (v) {
                setState(() => _emailAlerts = v);
                _save('notif_email_alerts', v);
              },
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Help & Support
// ══════════════════════════════════════════════════════════════════════════════

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  bool _feedbackSent = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Help & Support',
      slivers: [
        // ── Quick help ─────────────────────────────────────────────────
        _SectionCard(
          title: 'Quick Help',
          children: [
            _InfoRow(
              icon: Icons.menu_book_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'User Guide',
              subtitle: 'Step-by-step app walkthrough',
              onTap: () => _showGuideSheet(context),
            ),
            _InfoRow(
              icon: Icons.quiz_outlined,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'FAQs',
              subtitle: 'Answers to common questions',
              onTap: () => _showFaqSheet(context),
            ),
            _InfoRow(
              icon: Icons.video_library_outlined,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Video Tutorials',
              subtitle: 'Watch how-to guides',
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Contact ────────────────────────────────────────────────────
        _SectionCard(
          title: 'Contact Us',
          children: [
            _InfoRow(
              icon: Icons.chat_bubble_outline_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'Live Chat',
              subtitle: 'Chat with support — avg. 2 min wait',
              onTap: () {},
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              iconBg: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              title: 'Email Support',
              subtitle: 'support@yourapp.com',
              onTap: () {},
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              title: 'Call Us',
              subtitle: '+1 (800) 000-0000  ·  Mon–Fri 9–5',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Feedback ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'SEND FEEDBACK',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: _feedbackSent
                    ? const Column(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Color(0xFF16A34A), size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Thank you for your feedback!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    TextField(
                      controller: _feedbackCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                        'Describe your issue or suggestion…',
                        hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBD5E1)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.cAppPrimaryColor,
                              width: 1.5),
                        ),
                        contentPadding:
                        const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColor.cAppPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (_feedbackCtrl.text
                              .trim()
                              .isNotEmpty) {
                            setState(
                                    () => _feedbackSent = true);
                          }
                        },
                        child: const Text('Send Feedback',
                            style: TextStyle(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── App info ───────────────────────────────────────────────────
        _SectionCard(
          title: 'App Info',
          children: [
            _InfoRow(
              icon: Icons.info_outline_rounded,
              iconBg: AppColor.cAppBackgroundColor,
              iconColor: AppColor.cPrimaryButtonColor,
              title: 'App Version',
              subtitle: '1.0.0 (Build 100)',
            ),
            _InfoRow(
              icon: Icons.description_outlined,
              iconBg: const Color(0xFFF8FAFC),
              iconColor: const Color(0xFF64748B),
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              onTap: () {},
            ),
            _InfoRow(
              icon: Icons.policy_outlined,
              iconBg: const Color(0xFFF8FAFC),
              iconColor: const Color(0xFF64748B),
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── User Guide sheet ──────────────────────────────────────────────────

  void _showGuideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('User Guide',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ..._guideSteps
                .map((s) => _guideStep(s['icon']!, s['title']!, s['body']!))
                .toList(),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _guideSteps = [
    {
      'icon': '1',
      'title': 'Log In',
      'body':
      'Enter your email and password on the login screen. Contact your manager if you need credentials.',
    },
    {
      'icon': '2',
      'title': 'View Pick Lists',
      'body':
      'Open the Pick Lists tab to see all tasks assigned to you. Tap a pick list to start working on it.',
    },
    {
      'icon': '3',
      'title': 'Scan Barcodes',
      'body':
      'Tap the scan icon next to any part. Point your camera at the barcode — the count updates by +1 per scan.',
    },
    {
      'icon': '4',
      'title': 'Submit',
      'body':
      'Once all quantities are filled in, tap Submit Pick List at the bottom of the screen.',
    },
  ];

  Widget _guideStep(String icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.cAppPrimaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(icon,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FAQ sheet ──────────────────────────────────────────────────────────

  void _showFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('FAQs',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ..._faqs
                .map((f) => _FaqTile(
                question: f['q']!, answer: f['a']!))
                .toList(),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'What does each scan do?',
      'a':
      'Each scan adds +1 to the allocated quantity for that part. You can scan multiple times up to the required quantity.',
    },
    {
      'q': 'Can I manually type a quantity?',
      'a':
      'Yes — tap the allocated quantity field and type a number directly. The field is editable unless the required limit has been reached.',
    },
    {
      'q': 'What happens when I reach the required quantity?',
      'a':
      'Scanning is blocked for that part. A "Limit Reached" overlay appears and the scan button turns red.',
    },
    {
      'q': 'How do I reset a scan count?',
      'a':
      'Open the limit overlay by tapping the red scan button, then tap Reset to clear the count back to zero.',
    },
    {
      'q': 'Who can see my submitted pick lists?',
      'a':
      'Submitted pick lists are visible to your manager and the admin team.',
    },
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
//  FAQ expandable tile
// ══════════════════════════════════════════════════════════════════════════════

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B)),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                widget.answer,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
        ],
      ),
    );
  }
}