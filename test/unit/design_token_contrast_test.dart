import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/config/design_tokens.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final l1 = lum(a), l2 = lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  // Body-size text needs 4.5:1 (WCAG AA).
  test('white on the strong orange button colour passes AA', () {
    expect(contrast(DesignTokens.white, DesignTokens.accentOrangeStrong), greaterThanOrEqualTo(4.5));
  });

  test('status text colours pass AA on white and on the light background', () {
    for (final c in [DesignTokens.errorText, DesignTokens.successText]) {
      expect(contrast(c, DesignTokens.white), greaterThanOrEqualTo(4.5));
      expect(contrast(c, DesignTokens.backgroundLight), greaterThanOrEqualTo(4.5));
    }
  });

  test('form errors use the readable red', () {
    expect(AndozaTheme.lightTheme().colorScheme.error, DesignTokens.errorText);
  });
}
