import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit/utils/contrast_utils.dart';

void main() {
  test('light accent colors use dark readable text in light mode', () {
    const pastel = Color(0xFFD6E8FF);
    final color = ContrastUtils.accentText(pastel, isDark: false);
    expect(color, const Color(0xFF1A2B35));
  });

  test('light item colors use high contrast name text', () {
    const pastel = Color(0xFFB0C4DE);
    final color = ContrastUtils.itemNameColor(pastel, false);
    expect(color, const Color(0xFF1A2B35));
  });

  test('dark item colors keep vivid text in light mode', () {
    const dark = Color(0xFF2C3E50);
    final color = ContrastUtils.itemNameColor(dark, false);
    expect(color, dark);
  });
}
