import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mood_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        moodRating INTEGER NOT NULL,
        description TEXT NOT NULL,
        activities TEXT
      )
    ''');
  }

  // Inserir uma nova entrada no diário
  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert('mood_entries', entry.toMap());
  }

  // Atualizar uma entrada existente
  Future<int> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Excluir uma entrada
  Future<int> deleteMoodEntry(int id) async {
    final db = await database;
    return await db.delete(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obter todas as entradas
  Future<List<MoodEntry>> getMoodEntries() async {
    final db = await database;
    final result = await db.query('mood_entries', orderBy: 'date DESC');
    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  // Obter uma entrada específica pelo ID
  Future<MoodEntry?> getMoodEntry(int id) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MoodEntry.fromMap(maps.first);
    }
    return null;
  }

  // Fechar o banco de dados
  Future close() async {
    final db = await database;
    db.close();
  }
} 