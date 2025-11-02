import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eventfinder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // NAIKKAN VERSI DATABASE
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        hashedPassword TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        eventId TEXT NOT NULL,
        eventJson TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, eventId) 
      )
    ''');

    await db.execute('''
      CREATE TABLE redeemed_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        code TEXT NOT NULL,
        redeemedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, code)
      )
    ''');

    // TAMBAHKAN TABEL BARU INI
    await db.execute('''
      CREATE TABLE friendships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        friendId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (friendId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, friendId)
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE users ADD COLUMN points INTEGER NOT NULL DEFAULT 0");
      } catch (e) {
        print("Kolom 'points' sudah ada, mengabaikan error: $e");
      }
      
      try {
        await db.execute('''
          CREATE TABLE redeemed_codes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            code TEXT NOT NULL,
            redeemedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(userId, code)
          )
        ''');
      } catch (e) {
         print("Tabel 'redeemed_codes' sudah ada, mengabaikan error: $e");
      }
    }

    // TAMBAHKAN LOGIKA UPGRADE UNTUK VERSI 3
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE friendships (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            friendId INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (friendId) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(userId, friendId)
          )
        ''');
      } catch (e) {
         print("Tabel 'friendships' sudah ada, mengabaikan error: $e");
      }
    }
  }
}