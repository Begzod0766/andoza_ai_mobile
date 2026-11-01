import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/estimate_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/orders_provider.dart';
import '../home/home_empty_screen.dart';
import 'delete_account_dialog.dart';
import '../settings/language_picker_sheet.dart';

/// E4: Profil bosh — avatar, name, verified badge, three stat cards, and
/// the profile menu list. The "tejaldi" savings figure is the real
/// [estimateProvider] total (backfilled from Step 8's placeholder once
/// Step 11's pricing layer landed).
class E4ProfileSettingsScreen extends ConsumerWidget {
  const E4ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final name = currentUser.maybeWhen(
      data: (user) => user?.firstName ?? user?.name ?? user?.username,
      orElse: () => null,
    );
    final phone = currentUser.maybeWhen(
      data: (user) => user?.phone,
      orElse: () => null,
    );
    final projectCount = ref.watch(projectsProvider).maybeWhen(
      data: (projects) => projects.length,
      orElse: () => 0,
    );
    final orderCount = ref.watch(serverOrdersProvider).maybeWhen(
      data: (data) => data.length,
      orElse: () => ref.watch(ordersProvider).length,
    );
    final savings = estimateSavingsTotal(ref.watch(estimateProvider));

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(l10n.navProfile, style: DesignTokens.heading3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: DesignTokens.primaryBlue,
                  child: Icon(
                    Icons.person,
                    color: DesignTokens.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name ?? l10n.profileDefaultName,
                      style: DesignTokens.heading3,
                    ),
                  ],
                ),
                if (phone != null)
                  Text(
                    phone,
                    style: DesignTokens.body2.copyWith(
                      color: DesignTokens.textGray,
                    ),
                  ),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(
                  l10n.commonVerifiedBadge,
                  style: DesignTokens.caption.copyWith(
                    color: DesignTokens.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '$projectCount',
                  label: l10n.profileStatProjects,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: _StatCard(
                  value: '$orderCount',
                  label: l10n.profileStatOrders,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: _StatCard(
                  value: savings > 0
                      ? l10n.profileSavedMln(
                          (savings / 1000000).toStringAsFixed(1),
                        )
                      : l10n.homeStatDash,
                  label: l10n.profileStatSaved,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          // Shop owners and ustas see their business first; everyone else is
          // offered the way in.
          _MenuTile(
            icon: Icons.storefront_outlined,
            label: (ref.watch(accountRolesProvider).valueOrNull?.hasBusiness ?? false)
                ? l10n.profileMenuBusiness
                : l10n.profileMenuBecomePartner,
            onTap: () => context.push('/business'),
          ),
          // The web mebel workshop; on the web too a phone reaches it only
          // from the profile.
          _MenuTile(
            icon: Icons.chair_outlined,
            label: l10n.profileMenuMebel,
            subtitle: l10n.profileMenuMebelHint,
            onTap: () => context.push('/mebel'),
          ),
          _MenuTile(
            icon: Icons.architecture_outlined,
            label: l10n.profileMenuProjects,
            onTap: () => context.push('/profile/e5'),
          ),
          _MenuTile(
            icon: Icons.shopping_bag_outlined,
            label: l10n.profileMenuOrders,
            onTap: () => context.push('/profile/e6'),
          ),
          _MenuTile(
            icon: Icons.language_outlined,
            label: l10n.profileMenuLanguage,
            trailing:
                '${languageFlagEmoji(ref.watch(localeProvider))} ${languageDisplayName(ref.watch(localeProvider))}',
            onTap: () => showLanguagePickerSheet(context, ref),
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: l10n.profileMenuSettings,
            onTap: () => context.push('/profile/settings'),
          ),
          _MenuTile(
            icon: Icons.help_outline,
            label: l10n.profileMenuHelp,
            onTap: () => context.push('/onboarding/e8'),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          _MenuTile(
            icon: Icons.logout,
            label: l10n.profileMenuLogout,
            isDestructive: true,
            onTap: () => ref.read(authStateProvider.notifier).logout(),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          const Divider(),
          _MenuTile(
            icon: Icons.delete_forever_outlined,
            label: l10n.profileMenuDeleteAccount,
            isDestructive: true,
            onTap: () => confirmAndDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: DesignTokens.subtitle1.copyWith(
              color: DesignTokens.primaryBlue,
            ),
          ),
          Text(
            label,
            style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? DesignTokens.errorRed : DesignTokens.textDark;
    return Semantics(
      button: true,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingSm),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? DesignTokens.errorRed
                  : DesignTokens.textGray,
            ),
            const SizedBox(width: DesignTokens.spacingMd),
            Expanded(
              child: subtitle == null
                  ? Text(
                      label,
                      style: DesignTokens.body2.copyWith(color: color),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: DesignTokens.body2.copyWith(color: color),
                        ),
                        Text(
                          subtitle!,
                          style: DesignTokens.caption.copyWith(
                            color: DesignTokens.textGray,
                          ),
                        ),
                      ],
                    ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: DesignTokens.body2.copyWith(
                  color: DesignTokens.textGray,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXs),
            ],
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: DesignTokens.textMuted),
          ],
        ),
      ),
      ),
    );
  }
}
