import 'dart:io'; // Importação necessária para verificar a plataforma
import 'package:flutter/material.dart';
import 'package:jogodavelha/router_app.dart';
import 'package:jogodavelha/services/service_locator.dart';
import 'package:jogodavelha/services/navigation_service.dart';
import 'package:window_manager/window_manager.dart'; // Pacote para controle de janelas (somente para desktop)

void main() async {
  setupServiceLocator();

  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se está rodando no Windows, macOS ou Linux antes de chamar o window_manager
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(400, 400)); // Tamanho mínimo
    windowManager.setSize(const Size(600, 600)); // Tamanho inicial
    windowManager.setTitle("Jogo da Velha"); // Define um título para a janela
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a instância do NavigationService usando o ServiceLocator
    final NavigationService navigationService = getIt<NavigationService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jogo da Velha',
      navigatorKey: navigationService.navigatorKey, // Passa o navigatorKey aqui
      initialRoute: '/', // Rota inicial
      onGenerateRoute:
          AppRouter.generateRoute, // Gera as rotas a partir do AppRouter
    );
  }
}
