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
  version: 4,
 onCreate: _createDB,
 );
}

Future _createDB(Database db, int version) async {
await db.execute('''
CREATE TABLE users (
id INTEGER PRIMARY KEY AUTOINCREMENT,
 username TEXT NOT NULL UNIQUE,
 hashedPassword TEXT NOT NULL,
 points INTEGER NOT NULL DEFAULT 0 )
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

await db.execute('''
    CREATE TABLE posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      eventId TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      caption TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_req_rec ON friendships(requesterId, receiverId)');
await db.execute('CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status)');
 }

}