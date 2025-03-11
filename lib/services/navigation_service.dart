import 'package:flutter/material.dart';

class NavigationService {
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNamed(String route, {Object? args}) async {
    if (navigatorKey.currentState != null) {
      return await navigatorKey.currentState!.pushNamed(route, arguments: args);
    } else {
      // Se o currentState for null, você pode logar ou lidar com isso de forma adequada
      debugPrint("Navigator state is null.");
      return null;
    }
  }

  Future<dynamic> pushNamedAndRemoveUntil(String route, {Object? args}) async {
    return await navigatorKey.currentState!.pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: args,
    );
  }

  Future<dynamic> popAndPushNamed(String route, {Object? args}) async {
    return await navigatorKey.currentState!.popAndPushNamed(
      route,
      arguments: args,
    );
  }

  void pop<T>([T? args]) {
    navigatorKey.currentState!.pop(args);
  }

  void popUntil(bool Function(Route) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  Future<dynamic> showModal({required Widget child}) async {
    return await navigatorKey.currentState!.push(
      PageRouteBuilder(
        barrierDismissible: true,
        opaque: false,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) {
          return child;
        },
      ),
    );
  }
}
