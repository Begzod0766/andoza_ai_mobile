import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/design_tokens.dart';
import '../../features/ar_scan/ar_scan_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/push_permission.dart';

/// Public privacy policy page on the web app.
const _privacyPolicyUrl = 'https://andozaai.uz/privacy';

/// E9: App Preferences & Settings
/// Customize app behavior, notifications, and display settings
class E9PreferencesSettingsScreen extends ConsumerStatefulWidget {
  const E9PreferencesSettingsScreen({super.key});

  @override
  ConsumerState<E9PreferencesSettingsScreen> createState() =>
      _E9PreferencesSettingsScreenState();
}

class _E9PreferencesSettingsScreenState
    extends ConsumerState<E9PreferencesSettingsScreen>
    with WidgetsBindingObserver {
  bool _notificationsOn = false;
  bool _clearingCache = false;
  String? _appVersion;
  String? _buildNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPackageInfo();
    _refreshNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from the OS settings page: pick up a changed permission.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    final on = await ref.read(pushPermissionProvider).isGranted();
    if (!mounted) return;
    setState(() => _notificationsOn = on);
  }

  Future<void> _openNotificationSettings() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await launchUrl(Uri.parse('app-settings:'));
    } else {
      await ref.read(arScanServiceProvider).openAppSettings();
    }
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _clearCache() async {
    setState(() => _clearingCache = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {
            // Skip files still in use; not fatal for a cache clear.
          }
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCacheClearedMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCacheClearFailedMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _clearingCache = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsLinkOpenFailedMessage(url))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsScreenTitle),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Settings
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsProjectSettingsSectionTitle,
                    style: DesignTokens.subtitle1.copyWith(
                      color: DesignTokens.text,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  _ActionTile(
                    title: l10n.settingsNotificationsTitle,
                    subtitle: _notificationsOn
                        ? l10n.settingsNotificationsOn
                        : l10n.settingsNotificationsOff,
                    icon: Icons.notifications_outlined,
                    onTap: _openNotificationSettings,
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  _ActionTile(
                    title: l10n.settingsClearCacheTitle,
                    subtitle: _clearingCache
                        ? l10n.settingsClearingCacheInProgress
                        : l10n.settingsClearCacheSubtitle,
                    icon: Icons.delete_outline,
                    onTap: _clearingCache ? () {} : _clearCache,
                  ),
                ],
              ),
            ),
            const Divider(color: DesignTokens.border),

            // Privacy & Security
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsPrivacySecuritySectionTitle,
                    style: DesignTokens.subtitle1.copyWith(
                      color: DesignTokens.text,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  _ActionTile(
                    title: l10n.settingsPrivacyPolicyTitle,
                    subtitle: l10n.settingsPrivacyPolicySubtitle,
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _openUrl(_privacyPolicyUrl),
                  ),
                ],
              ),
            ),
            const Divider(color: DesignTokens.border),

            // About
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsAboutSectionTitle,
                    style: DesignTokens.subtitle1.copyWith(
                      color: DesignTokens.text,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spacing12),
                    decoration: BoxDecoration(
                      border: Border.all(color: DesignTokens.border),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.settingsAppVersionLabel,
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.text,
                              ),
                            ),
                            Text(
                              _appVersion ?? '…',
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacing12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.settingsBuildNumberLabel,
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.text,
                              ),
                            ),
                            Text(
                              _buildNumber ?? '…',
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.textSecondary,
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
            const SizedBox(height: DesignTokens.spacing32),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing12),
        decoration: BoxDecoration(
          border: Border.all(color: DesignTokens.border),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: DesignTokens.primaryBlue),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTokens.subtitle2.copyWith(
                      color: DesignTokens.text,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    subtitle,
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: DesignTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}
