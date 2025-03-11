// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogodavelha/assets/app_images.dart';
import 'package:jogodavelha/router/local_routes.dart';
import 'package:jogodavelha/services/navigation_service.dart';
import 'package:jogodavelha/services/service_locator.dart';
import 'package:jogodavelha/widgets/cs_elevated_button.dart';
import 'package:jogodavelha/widgets/cs_text_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuários Cadastrados'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text('Senha: ${user['password']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      String username = userController.text.trim();
      String password = passController.text.trim();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersJson = prefs.getString('users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

      bool isValidUser = users.any(
        (user) => user['username'] == username && user['password'] == password,
      );

      if (isValidUser) {
        Navigator.pushNamed(context, LocalRoutes.Game, arguments: username);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário ou senha incorretos!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              AppImages.login,
              fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
            ),
          ),
          // Conteúdo da tela
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white, // Transparência no fundo do Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Jogo da Velha",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: userController,
                          decoration: const InputDecoration(
                            labelText: "Usuário",
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o usuário';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passController,
                          decoration: const InputDecoration(
                            labelText: "Senha",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CsElevatedButton(onPressed: _login, label: 'Entrar'),
                        const SizedBox(height: 10),
                        CsTextButton(
                          onPressed: () {
                            getIt<NavigationService>().pushNamed(
                              LocalRoutes.Cadastro,
                            );
                          },
                          label: 'Ainda não tem uma conta? Cadastre-se aqui',
                        ),
                        const SizedBox(height: 10),
                        CsElevatedButton(
                          onPressed: _showUsers,
                          label: 'Mostrar Usuários Cadastrados',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
