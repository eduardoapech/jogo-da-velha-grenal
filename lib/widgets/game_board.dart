// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:jogodavelha/assets/app_images.dart';
import 'package:jogodavelha/views/game_screen.dart';
import '../controllers/game_controller.dart';

class GameBoard extends StatefulWidget {
  final GameController controller;

  const GameBoard({super.key, required this.controller});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  bool showWinnerMessage = false;
  bool isRestarting = false; // Nova variável para controlar o reinício

  bool _isRestarting() {
    return (context.findAncestorStateOfType<GameScreenState>()?.countdown ??
            0) >
        0;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onGameUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onGameUpdated);
    super.dispose();
  }

  void _onGameUpdated() {
    if (widget.controller.hasWinner) {
      _onGameEnd();
    }
    setState(() {}); // Atualiza o tabuleiro sempre que há mudanças
  }

  void _onGameEnd() {
    setState(() {
      showWinnerMessage = true; // Ativa a mensagem do vencedor
      isRestarting = true; // Indica que o jogo está reiniciando
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showWinnerMessage = false; // Esconde a mensagem após o tempo
        isRestarting = false;
        widget.controller.resetGame(); // Reseta o jogo
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exibe a tela de reinício se o jogo estiver reiniciando
    if (isRestarting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              showWinnerMessage && widget.controller.winner != null
                  ? "O vencedor é: ${widget.controller.winner == AppImages.gremio ? "Grêmio" : "Inter"}"
                  : "", // Apenas exibe o vencedor
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    // Exibe o tabuleiro apenas se não estiver no estado de reinício
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        int row = index ~/ 3;
        int col = index % 3;

        return GestureDetector(
          onTap: () {
            if (widget.controller.board[row][col].isEmpty &&
                !widget.controller.hasWinner &&
                !_isRestarting()) {
              // Bloqueia jogadas durante a contagem regressiva
              widget.controller.makeMove(row, col);
            }
          },

          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: Colors.green,
            ),
            child: Center(
              child:
                  widget.controller.board[row][col].isEmpty
                      ? const SizedBox.shrink()
                      : Image.asset(
                        widget.controller.board[row][col],
                        fit: BoxFit.cover,
                      ),
            ),
          ),
        );
      },
    );
  }
}
