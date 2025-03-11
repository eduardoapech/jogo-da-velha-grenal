import 'package:flutter/material.dart';
import 'package:jogodavelha/router/local_routes.dart';
import 'package:jogodavelha/views/login_screen.dart';
import 'package:jogodavelha/views/register_screen.dart';
import 'package:jogodavelha/views/game_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LocalRoutes.Login:
        return _PageBuilder(child: const LoginScreen(), settings: settings);

      case LocalRoutes.Cadastro:
        return _PageBuilder(child: const RegisterScreen(), settings: settings);

      case LocalRoutes.Game:
        // ✅ Verifica se `arguments` não é nulo e se é uma String
        final args = settings.arguments;
        if (args is String) {
          return _PageBuilder(
            child: GameScreen(userId: args),
            settings: settings,
          );
        } else {
          return _errorRoute();
        }

      default:
        return _errorRoute();
    }
  }

  /// Tela de erro caso a rota não exista
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder:
          (_) =>
              const Scaffold(body: Center(child: Text("Rota não encontrada!"))),
    );
  }
}

class _PageBuilder extends PageRouteBuilder {
  ///Responsável pelo efeito de 'fade transition' entre as transições de telas
  _PageBuilder({required this.child, required this.settings})
    : super(
        settings: settings,
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionDuration:
            settings.name == LocalRoutes.Login
                ? const Duration(milliseconds: 1000)
                : const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secAnimation) => child,
        transitionsBuilder: (context, animation, secAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );

  final Widget child;

  @override
  final RouteSettings settings;
}
