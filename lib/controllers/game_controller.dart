import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jogodavelha/assets/app_images.dart';
import '../services/database_service.dart';
import '../enums/ai_difficulty.dart';

class GameController extends ChangeNotifier {
  List<List<String>> board = List.generate(
    3,
    (_) => List.generate(3, (_) => ''),
  );
  bool isXTurn = true;
  int scoreX = 0;
  int scoreO = 0;
  String? _winner;
  final DatabaseService _databaseService = DatabaseService();
  final String userId;
  AIDifficulty aiDifficulty = AIDifficulty.easy;
  bool aiStarts = true;
  bool isResetting = false;
  bool showRestartScreen = false;
  Timer? _aiMoveTimer;
  bool isGameStarting =
      false; // Variável de controle para evitar jogadas múltiplas

  String? get winner => _winner;
  bool get hasWinner => _winner != null;

  GameController(this.userId) {
    _loadScores();
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    aiDifficulty = difficulty;
    notifyListeners();
  }

  void setAIStarts(bool starts) {
    aiStarts = starts;
    notifyListeners();
  }

  void makeMove(int row, int col) {
    if (board[row][col].isEmpty && _winner == null) {
      board[row][col] = isXTurn ? AppImages.gremio : AppImages.inter;
      isXTurn = !isXTurn;

      // Primeiro, verifica se há um vencedor
      String? winner = checkWinner();
      if (winner != null) {
        _handleWin(winner);
        return; // Se houver um vencedor, evita verificar empate
      }

      // Agora verifica se deu empate
      if (isBoardFull()) {
        showRestartScreen = true;
        notifyListeners();
        Future.delayed(const Duration(seconds: 5), () {
          resetGame();
        });
      }

      notifyListeners();
    }
  }

  void makeAIMove() {
    switch (aiDifficulty) {
      case AIDifficulty.easy:
        _randomAIMove();
        break;
      case AIDifficulty.medium:
        _smartAIMove();
        break;
      case AIDifficulty.hard:
        _strategicAIMove();
        break;
    }
    notifyListeners();
  }

  void _randomAIMove() {
    List<List<int>> availableMoves = [];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col].isEmpty) {
          availableMoves.add([row, col]);
        }
      }
    }
    if (availableMoves.isNotEmpty) {
      var move = availableMoves[Random().nextInt(availableMoves.length)];
      board[move[0]][move[1]] = AppImages.inter;
      isXTurn = true;
    }
  }

  void _smartAIMove() {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col].isEmpty) {
          board[row][col] = AppImages.inter;
          if (checkWinner() == AppImages.inter) return;
          board[row][col] = '';

          board[row][col] = AppImages.gremio;
          if (checkWinner() == AppImages.gremio) {
            board[row][col] = AppImages.inter;
            isXTurn = true;
            return;
          }
          board[row][col] = '';
        }
      }
    }
    _randomAIMove();
  }

  void _strategicAIMove() {
    if (board[1][1].isEmpty) {
      board[1][1] = AppImages.inter;
    } else {
      _smartAIMove();
    }
    isXTurn = true;
  }

  String? checkWinner() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][0];
      }
      if (board[0][i] != '' &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[0][i];
      }
    }
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }
    return null;
  }

  bool isBoardFull() {
    return board.every((row) => row.every((cell) => cell.isNotEmpty));
  }

  void _handleWin(String winner) {
    _winner = winner;
    showRestartScreen = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (winner == AppImages.gremio) {
        scoreX++;
      } else if (winner == AppImages.inter) {
        scoreO++;
      }
      _saveScores();
      resetGameAfterLoss(winner);
    });
  }

  void resetGameAfterLoss(String winner) {
    isXTurn = winner == AppImages.inter ? aiStarts : !aiStarts;
    resetGame();
  }

  void resetGame() {
    showRestartScreen = false;
    board = List.generate(3, (_) => List.generate(3, (_) => ''));
    _winner = null;
    isXTurn = !aiStarts;
    isGameStarting = true; // Impede múltiplas chamadas da IA

    // Cancela o timer da IA se existir
    _aiMoveTimer?.cancel();
    _aiMoveTimer = null;

    notifyListeners();

    //  Aguarda um pouco antes de permitir que a IA jogue
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   if (!isXTurn) {
    //     _aiMoveTimer = Timer(const Duration(milliseconds: 500), () {
    //       if (_winner == null) {
    //         makeAIMove();
    //       }
    //       isGameStarting = false; // Libera o jogo após a jogada inicial da IA
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveScores() async {
    // Usando int.tryParse() para evitar exceções se userId não for válido
    int? userIdParsed = int.tryParse(userId ?? '');
    if (userIdParsed == null) {
      // Se o userId não for válido, faça algo para tratar esse erro
      print("Erro: userId não é um número válido.");
      return; // Evita continuar com um ID inválido
    }

    // Caso contrário, continue com a lógica de salvar os scores
    await _databaseService.saveScore(userIdParsed, scoreX, scoreO);
  }

  Future<void> _loadScores() async {
    // Usando int.tryParse() para evitar exceções se userId não for válido
    int? userIdParsed = int.tryParse(userId ?? '');
    if (userIdParsed == null) {
      // Se o userId não for válido, faça algo para tratar esse erro
      print("Erro: userId não é um número válido.");
      return; // Evita continuar com um ID inválido
    }

    // Carrega os scores com o userId válido
    final scores = await _databaseService.getScore(userIdParsed);
    scoreX = scores['scoreX'] ?? 0;
    scoreO = scores['scoreO'] ?? 0;
    notifyListeners();
  }
}
