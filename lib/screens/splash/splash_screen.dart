import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/sign_in_history.dart';
import '../../widgets/brand/assembling_logo.dart';

/// Splash Screen (S0)
/// The first thing on every cold start: the logo assembles from its own
/// pieces while renovation and design tools gather into it (see
/// [AssemblingLogo]), then the wordmark settles under it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  /// How long the assembly runs, and the least time the splash stays up — a
  /// returning user's token restores in a few ms, which would otherwise cut
  /// the animation off before the logo is even whole.
  static const _assemble = Duration(milliseconds: 2200);
  static const _minimumShown = Duration(milliseconds: 2500);

  late final AnimationController _build =
      AnimationController(vsync: this, duration: _assemble);
  late final AnimationController _idle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion: show the finished logo straight away and leave sooner.
    final still = MediaQuery.of(context).disableAnimations;
    if (still) {
      _build.value = 1;
    } else {
      _build.forward();
      _idle.repeat();
    }
    _bootstrap(minimum: still ? const Duration(milliseconds: 600) : _minimumShown);
  }

  /// Restore any persisted session BEFORE navigating, so a returning user with
  /// a valid stored token lands on Home instead of being bounced to /login by
  /// the router's auth guard. Once auth resolves (and the logo has had its
  /// moment), we leave the splash and the redirect routes to '/'
  /// (authenticated, a silent guest included) or '/login' (not) — see
  /// [resolveColdStart].
  Future<void> _bootstrap({required Duration minimum}) async {
    final restore = resolveColdStart(
      ref.read(authStateProvider.notifier),
      ref.read(signInHistoryProvider),
    );
    await Future.wait([restore, Future<void>.delayed(minimum)]);
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _build.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The wordmark and tagline arrive as the ladder finishes.
    final reveal = CurvedAnimation(
      parent: _build,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOutCubic),
    );
    return Scaffold(
      backgroundColor: DesignTokens.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [Color(0xFF1A2230), DesignTokens.darkBg],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AssemblingLogo(progress: _build, idle: _idle, size: 260),
              const SizedBox(height: DesignTokens.spacingLg),
              FadeTransition(
                opacity: reveal,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(reveal),
                  child: Column(
                    children: [
                      Text.rich(
                        const TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            color: DesignTokens.white,
                          ),
                          children: [
                            TextSpan(text: 'andoza'),
                            TextSpan(text: '.', style: TextStyle(color: Color(0xFFF97316))),
                            TextSpan(text: 'ai', style: TextStyle(color: Color(0xFF7FA2FF))),
                          ],
                        ),
                        semanticsLabel: 'andoza.ai',
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      Text(
                        l10n.loginTagline,
                        textAlign: TextAlign.center,
                        style: DesignTokens.bodyMedium.copyWith(
                          color: DesignTokens.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXxl),
              FadeTransition(
                opacity: reveal,
                child: SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: DesignTokens.white.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDBA74)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
