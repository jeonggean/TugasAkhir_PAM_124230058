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
      version: 4, // 🔼 NAIKKAN VERSI DATABASE
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 🔹 Dijalankan saat pertama kali install
  Future _createDB(Database db, int version) async {
    // Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        hashedPassword TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Favorites
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

    // Redeemed codes
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

    // 🔹 Tabel friendships baru: dengan status permintaan
    await db.execute('''
      CREATE TABLE friendships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requesterId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        status TEXT CHECK(status IN ('pending','accepted','rejected')) DEFAULT 'pending',
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (requesterId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (receiverId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(requesterId, receiverId)
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_req_rec ON friendships(requesterId, receiverId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status)');
  }


  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // v2: tambah points dan redeemed_codes
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE users ADD COLUMN points INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
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
      } catch (_) {}
    }

    // v3: versi lama masih pakai userId/friendId
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
      } catch (_) {}
    }
    
    if (oldVersion < 4) {
      // 1️⃣ Buat tabel baru
      await db.execute('''
        CREATE TABLE IF NOT EXISTS friendships_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          requesterId INTEGER NOT NULL,
          receiverId INTEGER NOT NULL,
          status TEXT CHECK(status IN ('pending','accepted','rejected')) DEFAULT 'accepted',
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (requesterId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (receiverId) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(requesterId, receiverId)
        )
      ''');

      try {
        await db.execute('''
          INSERT OR IGNORE INTO friendships_new (requesterId, receiverId, status)
          SELECT userId, friendId, 'accepted' FROM friendships
        ''');
      } catch (e) {
        print("Gagal migrasi data lama: $e");
      }

      await db.execute('DROP TABLE IF EXISTS friendships');
      await db.execute('ALTER TABLE friendships_new RENAME TO friendships');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_req_rec ON friendships(requesterId, receiverId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status)');
    }
  }
}
