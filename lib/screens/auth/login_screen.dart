import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/locale_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/api_client.dart';
import '../../services/apple_sign_in_service.dart';
import '../../services/google_sign_in_service.dart';
import '../../utils/error_mapper.dart';
import '../settings/language_picker_sheet.dart';

/// Login screen — a Flutter port of the web `/login` page: phone-OTP by default,
/// with a 6-digit code step, plus username/password login and registration.
/// On success it flips [authStateProvider] to authenticated and the router's
/// redirect navigates onward.
enum _Mode { otpPhone, otpCode, login, register }

const int _resendCooldown = 60;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _Mode _mode = _startMode;

  /// Where the screen opens and where "back" leads.
  static const _Mode _startMode =
      AppConfig.smsLoginEnabled ? _Mode.otpPhone : _Mode.login;

  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();

  final List<TextEditingController> _otp =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _phoneFocused = false;
  // What the person is signing up as; null is an ordinary user.
  BusinessKind? _businessKind;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// The resend cooldown ticks once a second. Kept in a [ValueNotifier] (not
  /// plain state) so the timer only rebuilds the small countdown label via a
  /// [ValueListenableBuilder] instead of setState-ing the entire screen.
  final ValueNotifier<int> _cooldown = ValueNotifier<int>(0);
  Timer? _timer;
  String _sentPhone = '';

  @override
  void dispose() {
    _timer?.cancel();
    _cooldown.dispose();
    for (final c in [_phone, _username, _password, _confirm, _name, ..._otp]) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998')) return '+$digits';
    if (digits.startsWith('0')) return '+998${digits.substring(1)}';
    return '+998$digits';
  }

  bool _isValidPhone(String phone) => RegExp(r'^\+998\d{9}$').hasMatch(phone);

  void _switch(_Mode m) => setState(() {
        _mode = m;
        _error = null;
      });

  void _startCooldown() {
    _timer?.cancel();
    _cooldown.value = _resendCooldown;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown.value <= 1) {
        t.cancel();
        _cooldown.value = 0;
      } else {
        _cooldown.value--;
      }
    });
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  // ── actions ───────────────────────────────────────────────────────────────
  Future<void> _requestOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _formatPhone(_phone.text);
    if (!_isValidPhone(phone)) {
      setState(() => _error = l10n.loginErrorInvalidPhone);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.requestOtp(phone);
      _sentPhone = phone;
      _startCooldown();
      setState(() => _mode = _Mode.otpCode);
      WidgetsBinding.instance.addPostFrameCallback((_) => _otpFocus[0].requestFocus());
    } catch (_) {
      setState(() => _error = l10n.loginErrorServer);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp(String code) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.verifyOtp(_sentPhone, code);
      final analytics = ref.read(analyticsProvider);
      ref.read(authStateProvider.notifier).setSession(res);
      analytics.login('password');
    } catch (_) {
      setState(() {
        _error = l10n.loginErrorInvalidCode;
        for (final c in _otp) {
          c.clear();
        }
      });
      _otpFocus[0].requestFocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown.value > 0) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.requestOtp(_sentPhone);
      for (final c in _otp) {
        c.clear();
      }
      _startCooldown();
      _otpFocus[0].requestFocus();
    } catch (_) {
      setState(() => _error = l10n.loginErrorServer);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = l10n.loginErrorCredentialsRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    // Drive the login through AuthNotifier so AuthState is the single source of
    // truth: on success it flips to AuthAuthenticated (the router redirect
    // navigates onward); on failure it lands in AuthError, which we surface with
    // the same inline message as before.
    await ref.read(authStateProvider.notifier).login(
          _username.text.trim(),
          _password.text,
        );
    if (!mounted) return;
    final state = ref.read(authStateProvider);
    if (state is AuthAuthenticated) ref.read(analyticsProvider).login('password');
    setState(() {
      _loading = false;
      if (state is AuthError) _error = _loginErrorMessage(l10n, state);
    });
  }

  /// Picks the inline login-failure message. A genuine credential rejection is
  /// a 401 → keep the "wrong username/password" wording; every other failure
  /// (network/timeout/5xx) is routed through [mapErrorToMessage] so it doesn't
  /// misleadingly read as a bad password. Classified by [AuthError.statusCode]
  /// (carried from [AuthException]), not by substring-matching the message.
  String _loginErrorMessage(AppLocalizations l10n, AuthError error) {
    if (error.statusCode == 401) {
      return l10n.loginErrorWrongCredentials;
    }
    return mapErrorToMessage(
      ApiException(message: error.message, statusCode: error.statusCode),
    );
  }

  /// Google sign-in: the plugin hands us an ID token, the backend
  /// (`POST /auth/google`) swaps it for an andoza session, and — like OTP and
  /// register — we flip [authStateProvider] so the router redirect navigates
  /// onward exactly as after a password login. A dismissed account picker is
  /// not an error: nothing happens.
  Future<void> _googleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final idToken = await ref.read(googleSignInServiceProvider).getIdToken();
      if (idToken == null) return;
      final res = await _repo.loginWithGoogle(idToken);
      final analytics = ref.read(analyticsProvider);
      ref.read(authStateProvider.notifier).setSession(res);
      analytics.login('google');
    } catch (e) {
      if (mounted) {
        setState(() => _error = _socialErrorMessage(e, l10n.loginGoogleFailed));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _appleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await ref.read(appleSignInServiceProvider).getCredential();
      if (cred == null) return;
      final res = await _repo.loginWithApple(cred.identityToken, name: cred.name);
      final analytics = ref.read(analyticsProvider);
      ref.read(authStateProvider.notifier).setSession(res);
      analytics.login('apple');
    } catch (e) {
      if (mounted) {
        setState(() => _error = _socialErrorMessage(e, l10n.loginAppleFailed));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// A rejected token (401) or a plugin failure reads as [failed] ("Google /
  /// Apple sign-in failed"); network/5xx/503-not-configured go through
  /// [mapErrorToMessage] like the password login does.
  String _socialErrorMessage(Object error, String failed) {
    if (error is AuthException && error.statusCode != 401) {
      return mapErrorToMessage(
        ApiException(message: error.message, statusCode: error.statusCode),
      );
    }
    return failed;
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final u = _username.text.trim();
    if (u.length < 3) {
      setState(() => _error = l10n.loginErrorUsernameShort);
      return;
    }
    // The API takes 3–50 characters (after trimming) and refuses more with a
    // 422, which would otherwise surface as a vague "registration failed".
    if (u.length > 50) {
      setState(() => _error = l10n.loginErrorUsernameLong);
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = l10n.loginErrorPasswordShort);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = l10n.loginErrorPasswordMismatch);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.register(u, _password.text, _name.text.trim());
      // Registering as a shop owner or an usta only creates the account; the
      // application itself is the next screen (the app shell opens it), where
      // it can be filled in — or left for later without losing the account.
      ref.read(pendingBusinessSetupProvider.notifier).state = _businessKind;
      final analytics = ref.read(analyticsProvider);
      ref.read(authStateProvider.notifier).setSession(res);
      analytics.login('password');
    } catch (e) {
      // 409 Conflict = username already taken — classify by the real status
      // code (carried on AuthException), not a fragile message substring.
      final taken = e is AuthException && e.statusCode == 409;
      setState(() => _error =
          taken ? l10n.loginErrorUsernameTaken : l10n.loginErrorRegisterFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F7FB), Color(0xFFECEEF5)],
          ),
        ),
        child: SafeArea(
          // Top-anchored, not centred: the card's height differs per step
          // (phone / code / username / register), and a centred column moved the
          // logo up and down every time the step changed.
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacing24, 72, DesignTokens.spacing24, DesignTokens.spacing32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: DesignTokens.spacing32),
                      _card(),
                      const SizedBox(height: DesignTokens.spacing24),
                      const _VersionLabel(),
                    ],
                  ),
                ),
              ),
              // The profile's language row is out of reach before sign-in.
              const Positioned(
                top: DesignTokens.spacing8,
                right: DesignTokens.spacing8,
                child: _LanguageButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(DesignTokens.spacing24),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: switch (_mode) {
        _Mode.otpPhone => _otpPhoneView(),
        _Mode.otpCode => _otpCodeView(),
        _Mode.login => _loginView(),
        _Mode.register => _registerView(),
      },
    );
  }

  // ── views ─────────────────────────────────────────────────────────────────
  Widget _otpPhoneView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.loginPhoneLabel, style: DesignTokens.headingMedium),
        const SizedBox(height: 4),
        Text(l10n.loginPhoneSubtitle,
            style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textMuted)),
        const SizedBox(height: DesignTokens.spacing24),
        Text(l10n.loginPhoneLabel, style: DesignTokens.caption.copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.spacing8),
        Focus(
          onFocusChange: (focused) => setState(() => _phoneFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: _phoneFocused ? DesignTokens.primary : DesignTokens.border,
                width: _phoneFocused ? 1.6 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
            child: Row(
              children: [
                const Text('+998', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: DesignTokens.spacing12),
                Container(width: 1, height: 22, color: DesignTokens.border),
                const SizedBox(width: DesignTokens.spacing12),
                Expanded(
                  child: TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                    decoration: InputDecoration(
                      hintText: l10n.loginPhoneHint,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => _requestOtp(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(l10n.loginPhoneSmsHint,
            style: DesignTokens.caption.copyWith(color: DesignTokens.textMuted)),
        _errorText(),
        const SizedBox(height: DesignTokens.spacing16),
        _primaryButton(l10n.loginSendOtp, _loading ? null : _requestOtp),
        const SizedBox(height: DesignTokens.spacing24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.info_outline, size: 16, color: DesignTokens.textMuted),
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Expanded(
              child: Text(
                l10n.loginOtpInfoBox,
                style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing24),
        const _OrDivider(),
        const SizedBox(height: DesignTokens.spacing16),
        _outlinedButton(l10n.loginWithUsername, () => _switch(_Mode.login)),
      ],
    );
  }

  Widget _otpCodeView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.loginCodeSentTitle, style: DesignTokens.headingMedium),
        const SizedBox(height: 4),
        Text.rich(TextSpan(
          style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textMuted),
          children: [
            TextSpan(text: _sentPhone, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            TextSpan(text: l10n.loginCodeSentSuffix),
          ],
        )),
        const SizedBox(height: DesignTokens.spacing24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var i = 0; i < 6; i++) _otpBox(i)],
        ),
        _errorText(),
        const SizedBox(height: DesignTokens.spacing16),
        _primaryButton(l10n.loginVerify, _loading ? null : () {
          final code = _otp.map((c) => c.text).join();
          if (code.length == 6) _verifyOtp(code);
        }),
        const SizedBox(height: DesignTokens.spacing8),
        Center(
          child: ValueListenableBuilder<int>(
            valueListenable: _cooldown,
            builder: (context, cooldown, _) => TextButton(
              onPressed: cooldown > 0 || _loading ? null : _resend,
              child: Text(cooldown > 0 ? l10n.loginResendCountdown(cooldown) : l10n.loginResend),
            ),
          ),
        ),
        Center(child: TextButton(onPressed: () => _switch(_Mode.otpPhone), child: Text(l10n.loginBackArrow))),
      ],
    );
  }

  Widget _loginView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // With SMS sign-in off this is the first screen: nothing to go back to.
        if (_startMode != _Mode.login) _backButton(),
        Text(l10n.loginSignIn, style: DesignTokens.headingMedium),
        const SizedBox(height: DesignTokens.spacing16),
        _field(_username, l10n.loginUsernameHint, autofillHints: const [AutofillHints.username]),
        const SizedBox(height: DesignTokens.spacing16),
        _passwordField(_password, l10n.loginPasswordLabel, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
        _errorText(),
        const SizedBox(height: DesignTokens.spacing24),
        _primaryButton(l10n.loginSignIn, _loading ? null : _login),
        ..._socialSection(l10n),
        const SizedBox(height: DesignTokens.spacing16),
        Center(
          child: Wrap(
            children: [
              Text(l10n.loginNoAccount, style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textMuted)),
              GestureDetector(
                onTap: () => _switch(_Mode.register),
                child: Text(l10n.loginRegister,
                    style: DesignTokens.bodySmall.copyWith(color: DesignTokens.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _registerView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        Text(l10n.loginRegister, style: DesignTokens.headingMedium),
        const SizedBox(height: DesignTokens.spacing16),
        Text(l10n.registerRoleTitle, style: DesignTokens.subtitle2),
        const SizedBox(height: DesignTokens.spacing8),
        _roleOption(null, Icons.person_outline, l10n.roleUser, l10n.roleUserDesc),
        _roleOption(BusinessKind.shop, Icons.storefront_outlined, l10n.roleShop, l10n.roleShopDesc),
        _roleOption(BusinessKind.usta, Icons.handyman_outlined, l10n.roleUsta, l10n.roleUstaDesc),
        const SizedBox(height: DesignTokens.spacing8),
        _field(_name, l10n.loginNameHint),
        const SizedBox(height: DesignTokens.spacing12),
        _field(_username, l10n.loginUsernameHint),
        const SizedBox(height: DesignTokens.spacing12),
        _passwordField(_password, l10n.loginPasswordLabel, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
        const SizedBox(height: DesignTokens.spacing12),
        _passwordField(_confirm, l10n.loginConfirmPasswordHint, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
        _errorText(),
        const SizedBox(height: DesignTokens.spacing24),
        _primaryButton(l10n.loginRegister, _loading ? null : _register),
        ..._socialSection(l10n),
        const SizedBox(height: DesignTokens.spacing16),
        Center(
          child: Wrap(
            children: [
              Text(l10n.loginHaveAccount, style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textMuted)),
              GestureDetector(
                onTap: () => _switch(_Mode.login),
                child: Text(l10n.loginSignIn,
                    style: DesignTokens.bodySmall.copyWith(color: DesignTokens.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── small widgets ───────────────────────────────────────────────────────
  /// "yoki" divider + "Apple bilan kirish" (iOS, see
  /// [AppleSignInService.isAvailable]) + "Google bilan kirish" (hidden where
  /// Google sign-in isn't configured — see [GoogleSignInService.isAvailable]).
  List<Widget> _socialSection(AppLocalizations l10n) {
    final apple = AppleSignInService.isAvailable;
    final google = GoogleSignInService.isAvailable;
    if (!apple && !google) return const [];
    return [
      const SizedBox(height: DesignTokens.spacing16),
      const _OrDivider(),
      const SizedBox(height: DesignTokens.spacing16),
      if (apple) _appleButton(l10n.loginWithApple, _loading ? null : _appleLogin),
      if (apple && google) const SizedBox(height: DesignTokens.spacing12),
      if (google)
        _outlinedButton(
          l10n.loginWithGoogle,
          _loading ? null : _googleLogin,
          leading: const _GoogleMark(),
        ),
    ];
  }

  /// Apple's own look (black, white logo and text), as its guidelines ask —
  /// and at least as prominent as the Google button below it.
  Widget _appleButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: DesignTokens.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.apple, size: 22),
            const SizedBox(width: DesignTokens.spacing8),
            Flexible(
              child: Text(label, style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleOption(BusinessKind? kind, IconData icon, String title, String desc) {
    final selected = _businessKind == kind;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        onTap: _loading ? null : () => setState(() => _businessKind = kind),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? DesignTokens.primary.withValues(alpha: 0.06) : DesignTokens.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: selected ? DesignTokens.primary : DesignTokens.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? DesignTokens.primary : DesignTokens.textMuted),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: DesignTokens.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(desc, style: DesignTokens.caption.copyWith(color: DesignTokens.textMuted)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, size: 20, color: DesignTokens.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() => Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
        child: GestureDetector(
          onTap: () => _switch(_startMode),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back, size: 18, color: DesignTokens.textMuted),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context)!.actionBack, style: DesignTokens.bodySmall.copyWith(color: DesignTokens.textMuted)),
          ]),
        ),
      );

  Widget _otpBox(int i) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: _otp[i],
        focusNode: _otpFocus[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: DesignTokens.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            borderSide: const BorderSide(color: DesignTokens.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            borderSide: const BorderSide(color: DesignTokens.primary, width: 1.6),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) _otpFocus[i + 1].requestFocus();
          if (v.isEmpty && i > 0) _otpFocus[i - 1].requestFocus();
          final code = _otp.map((c) => c.text).join();
          if (code.length == 6 && !_loading) _verifyOtp(code);
        },
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {Iterable<String>? autofillHints}) {
    return TextField(
      controller: c,
      autofillHints: autofillHints,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _passwordField(TextEditingController c, String hint, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: IconButton(
          tooltip: obscure
              ? AppLocalizations.of(context)!.loginShowPassword
              : AppLocalizations.of(context)!.loginHidePassword,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
            color: DesignTokens.textMuted,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  // One look for every field on this screen (and the phone field above):
  // white, hairline border, a slightly heavier brand-coloured border on focus.
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: DesignTokens.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.primary, width: 1.6),
        ),
      );

  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          disabledBackgroundColor: DesignTokens.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
        ),
        child: _loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.white)))
            : Text(label, style: const TextStyle(color: DesignTokens.white, fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }

  Widget _outlinedButton(String label, VoidCallback? onPressed, {Widget? leading}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: const BorderSide(color: DesignTokens.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: DesignTokens.spacing12)],
            Flexible(
              child: Text(label, style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorText() => _error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spacing12),
          child: Text(_error!, style: DesignTokens.bodySmall.copyWith(color: DesignTokens.error)),
        );
}

/// Static brand header above the auth card: a mark, the product name and a
/// one-line tagline. Extracted as a `const` widget so the per-keystroke /
/// per-cooldown rebuilds of the stateful screen never rebuild it.
/// The current language; opens the language picker.
class _LanguageButton extends ConsumerWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Tooltip(
      message: AppLocalizations.of(context)!.profileMenuLanguage,
      child: TextButton(
        onPressed: () => showLanguagePickerSheet(context, ref),
        child: Text(
          '${languageFlagEmoji(locale)} ${languageDisplayName(locale)}',
          style: DesignTokens.subtitle2,
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/andozaai-lockup.png',
          width: 200,
          cacheWidth: 600,
          semanticLabel: 'andoza.ai',
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Text(l10n.loginTagline,
            textAlign: TextAlign.center,
            style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textSecondary)),
      ],
    );
  }
}

/// Static app-version footnote below the auth card. `const` for the same reason.
class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.loginVersion,
        style: DesignTokens.caption.copyWith(color: DesignTokens.textMuted));
  }
}

/// Static "yoki" divider between alternative sign-in entry points.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider(color: DesignTokens.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12),
        child: Text(AppLocalizations.of(context)!.loginOr, style: DesignTokens.caption.copyWith(color: DesignTokens.textMuted)),
      ),
      const Expanded(child: Divider(color: DesignTokens.border)),
    ]);
  }
}

/// The Google "G", drawn as text in Google blue — avoids shipping an SVG
/// dependency for one glyph.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
