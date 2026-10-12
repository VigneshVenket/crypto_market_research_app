import 'package:flutter/material.dart';

class CustomNavigation {

  static Future<T?> push<T>(BuildContext context, Widget widget) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (c) => widget),
    );
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget widget) {
    return Navigator.of(context).pushReplacement<T, T>(
      MaterialPageRoute(builder: (c) => widget),
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (c) => widget),
          (route) => false,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}