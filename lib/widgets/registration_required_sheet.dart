import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/design_tokens.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

/// The name of a guest-closed [feature] (the backend's `registration_required`
/// feature keys); an unknown key falls back to the sheet title.
String guestFeatureLabel(AppLocalizations l10n, String feature) {
  return switch (feature) {
    'ai_design' => l10n.guestFeatureAiDesign,
    'ai_build' => l10n.guestFeatureAiBuild,
    'smeta_ask' => l10n.guestFeatureSmetaAsk,
    'render' => l10n.guestFeatureRender,
    'photo_model' => l10n.guestFeaturePhotoModel,
    'mebel_ai' => l10n.guestFeatureMebelAi,
    'contact' => l10n.guestFeatureContact,
    'order' => l10n.guestFeatureOrder,
    'workshop_link' => l10n.guestFeatureWorkshopLink,
    'business' => l10n.guestFeatureBusiness,
    'market_prices' => l10n.guestFeatureMarketPrices,
    _ => l10n.guestSheetTitle,
  };
}

/// "Sign up to use this": tells a guest that [feature] needs an account and
/// offers `/signup`. True only when the person is no longer a guest
/// afterwards (signed up, or signed in to an existing account).
Future<bool> showRegistrationRequiredSheet(
  BuildContext context, {
  required String feature,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final router = GoRouter.of(context);
  final signUp = await showModalBottomSheet<bool>(
    context: context,
    // Over the bottom bar: a shell-navigator sheet sits under it.
    useRootNavigator: true,
    // Sized to its content (large text included), not capped at 9/16.
    isScrollControlled: true,
    backgroundColor: DesignTokens.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _RegistrationRequiredSheet(feature: feature),
  );
  if (signUp != true) return false;
  await router.push<bool>('/signup');
  final auth = container.read(authStateProvider);
  return auth is AuthAuthenticated && !auth.isGuest;
}

/// True at once for anyone who is not a guest; a guest gets the sign-up
/// sheet for [feature] and true only if they signed up or in from it.
Future<bool> ensureRegistered(
  BuildContext context,
  WidgetRef ref,
  String feature,
) async {
  if (!ref.read(authStateProvider).isGuest) return true;
  return showRegistrationRequiredSheet(context, feature: feature);
}

/// For a call that came back 403 `registration_required` (the server knew
/// better than the app, e.g. a stale guest flag): shows the sheet and returns
/// true. False (nothing shown) for any other error.
Future<bool> handleRegistrationRequired(
  BuildContext context,
  Object error,
) async {
  if (error is! ApiException || !error.isRegistrationRequired) return false;
  await showRegistrationRequiredSheet(context, feature: error.feature ?? '');
  return true;
}

class _RegistrationRequiredSheet extends StatelessWidget {
  const _RegistrationRequiredSheet({required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = guestFeatureLabel(l10n, feature);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacing24,
            DesignTokens.spacing24,
            DesignTokens.spacing24,
            DesignTokens.spacing16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_outline,
                color: DesignTokens.primary,
                size: 32,
              ),
              const SizedBox(height: DesignTokens.spacing16),
              Text(
                l10n.guestSheetTitle,
                textAlign: TextAlign.center,
                style: DesignTokens.headingMedium,
              ),
              if (label != l10n.guestSheetTitle) ...[
                const SizedBox(height: DesignTokens.spacing8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: DesignTokens.subtitle2.copyWith(
                    color: DesignTokens.primary,
                  ),
                ),
              ],
              const SizedBox(height: DesignTokens.spacing12),
              Text(
                l10n.guestSheetBody,
                textAlign: TextAlign.center,
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.guestSheetSignUp),
              ),
              const SizedBox(height: DesignTokens.spacing8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.guestSheetLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
