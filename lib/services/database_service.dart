import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)',
        );
        db.execute(
          'CREATE TABLE scores(id INTEGER PRIMARY KEY, scoreX INTEGER, scoreO INTEGER)',
        );
      },
    );
  }

  // Método que insere um usuário no banco
  Future<void> insertUser(UserModel user) async {
    final db = await database;

    // Insere o usuário
    int userId = await db.insert('users', user.toMap());

    // Insere pontuação inicial do usuário
    await db.insert('scores', {
      'id': userId, // Usa o mesmo ID do usuário para vincular a pontuação
      'scoreX': 0,
      'scoreO': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserModel>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  Future<void> saveScore(int userId, int scoreX, int scoreO) async {
    final db = await database;
    await db.insert('scores', {
      'id': userId,
      'scoreX': scoreX,
      'scoreO': scoreO,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, int>> getScore(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scores',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return {'scoreX': maps[0]['scoreX'], 'scoreO': maps[0]['scoreO']};
    }
    return {
      'scoreX': 0,
      'scoreO': 0,
    }; // Retorna pontuação inicial se não encontrar
  }
}
