// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogodavelha/assets/app_images.dart';
import 'package:jogodavelha/router/local_routes.dart';
import 'package:jogodavelha/widgets/cs_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  Future<void> _register() async {
    String username = userController.text.trim();
    String password = passController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Recuperar lista de usuários cadastrados
      String? usersJson = prefs.getString('users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

      // Verificar se o usuário já existe
      bool userExists = users.any((user) => user['username'] == username);
      if (userExists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Usuário já existe!")));
        return;
      }

      // Adicionar novo usuário à lista
      users.add({'username': username, 'password': password});
      await prefs.setString('users', jsonEncode(users));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );

      // Aguardar antes de navegar para login
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, LocalRoutes.Login);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo com imagem PNG
          Image.asset(AppImages.cadastro, fit: BoxFit.cover),
          // Conteúdo da tela de cadastro
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: "Usuário",
                      filled: true,
                      fillColor: Colors.white70, // Para destacar os campos
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passController,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  CsElevatedButton(onPressed: _register, label: 'Cadastrar'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
