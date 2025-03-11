import 'dart:async'; // Importação para Timer
import 'dart:io'; // Importação para verificar o tipo de plataforma
import 'package:flutter/material.dart';
import 'package:jogodavelha/assets/app_images.dart';
import 'package:jogodavelha/widgets/cs_app_bar.dart';
import '../widgets/game_board.dart';
import '../controllers/game_controller.dart';
import '../enums/ai_difficulty.dart'; // Importação do enum

class GameScreen extends StatefulWidget {
  final String userId;

  const GameScreen({super.key, required this.userId});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  AIDifficulty _selectedDifficulty = AIDifficulty.easy;
  Timer? _resetTimer; // Timer para reiniciar o jogo
  int _countdown = 0; // Inicializa a contagem regressiva
  int get countdown => _countdown;
  bool _isGameReset = false; // Flag para evitar múltiplos reinícios

  @override
  void initState() {
    super.initState();
    _controller = GameController(widget.userId);
    _controller.setAIDifficulty(
      _selectedDifficulty,
    ); // Inicializar com a dificuldade selecionada
    _controller.addListener(_onGameUpdated);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameUpdated);
    _resetTimer?.cancel(); // Cancelar o timer se a tela for descartada
    super.dispose();
  }

  void _onGameUpdated() {
    if (_controller.hasWinner) {
      // Iniciar a contagem regressiva de 5 segundos após o vencedor ser determinado
      _startCountdown();
    }
    setState(() {});
  }

  void _startCountdown() {
    if (_resetTimer?.isActive ?? false) {
      return; // Evita múltiplos timers ativos
    }

    setState(() {
      _countdown = 5;
      _isGameReset = false; // Resetando o flag a cada nova contagem
    });

    // Iniciar o timer
    _resetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          // Log para verificar a chamada do resetGame
          print("Game reset iniciado");

          // Evitar reiniciar o jogo mais de uma vez
          if (!_isGameReset) {
            timer.cancel(); // Cancela o timer
            _controller.resetGame(); // Reinicia o jogo
            setState(() {
              _countdown = 0;
              _isGameReset = true; // Marca que o jogo foi reiniciado
            });
          }
        }
      });
    });
  }

  void _changeDifficulty(AIDifficulty newLevel) {
    setState(() {
      _selectedDifficulty = newLevel;
    });
    _controller.setAIDifficulty(
      newLevel,
    ); // Atualizar a dificuldade no controller
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Definir tamanhos diferentes para desktop e mobile
    double boardSize;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      boardSize = 350;
    } else {
      boardSize = screenWidth * 0.9;
      if (boardSize > screenHeight * 0.6) {
        boardSize = screenHeight * 0.6;
      }
    }

    return Scaffold(
      appBar: CsAppBar(title: "Jogo da Velha"),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown para selecionar dificuldade
              DropdownButton<AIDifficulty>(
                value: _selectedDifficulty,
                onChanged: (AIDifficulty? newValue) {
                  if (newValue != null) {
                    _changeDifficulty(newValue);
                  }
                },
                items:
                    AIDifficulty.values.map((AIDifficulty level) {
                      return DropdownMenuItem<AIDifficulty>(
                        value: level,
                        child: Text(
                          level.toString().split('.').last.toUpperCase(),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // Placar Responsivo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.gremio, width: 30, height: 30),
                      Text(
                        "${_controller.scoreX}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'X',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.inter, width: 30, height: 30),
                      Text(
                        "${_controller.scoreO}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contagem regressiva de 5 segundos
              if (_countdown > 0)
                Text(
                  'Reiniciando em: $_countdown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // Tabuleiro do jogo
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: GameBoard(controller: _controller),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
