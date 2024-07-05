import 'package:flutter/material.dart';

class ScreenUtils {
  static double screenWidth(BuildContext context, double percentage) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    final safeWidth = mediaQuery.size.width - safeAreaHorizontal;
    return (percentage / 100) * safeWidth;
  }

  static double screenHeight(BuildContext context, double percentage) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    final safeHeight = mediaQuery.size.height - safeAreaVertical;
    return (percentage / 100) * safeHeight;
  }
}