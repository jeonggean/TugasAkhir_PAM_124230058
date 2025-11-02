import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';

class FriendService {
  Future<Database> get _db async => await DatabaseService.instance.database;

  // Untuk mencari user berdasarkan username (untuk ditambah jadi teman)
  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      columns: ['id', 'username', 'points'], // Jangan ambil password
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Menambahkan teman
  Future<void> addFriend(int currentUserId, int friendId) async {
    if (currentUserId == friendId) {
      throw Exception('Anda tidak dapat menambahkan diri sendiri.');
    }
    
    final db = await _db;
    try {
      await db.insert(
        'friendships',
        {'userId': currentUserId, 'friendId': friendId},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Anda sudah berteman dengan pengguna ini.');
      }
      rethrow;
    }
  }

  // Menghapus teman
  Future<void> removeFriend(int currentUserId, int friendId) async {
    final db = await _db;
    await db.delete(
      'friendships',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [currentUserId, friendId],
    );
  }

  // Mendapatkan daftar teman (beserta detailnya)
  Future<List<Map<String, dynamic>>> getFriends(int currentUserId) async {
    final db = await _db;
    // Query ini menggabungkan tabel friendships dengan users
    // untuk mendapatkan detail (username, points) dari friendId
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT U.id, U.username, U.points 
      FROM users U 
      INNER JOIN friendships F ON U.id = F.friendId 
      WHERE F.userId = ?
    ''', [currentUserId]);

    return maps;
  }

  // Mendapatkan event favorit DARI SEORANG TEMAN
  Future<List<Map<String, dynamic>>> getFavoritesForUser(int friendId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [friendId],
    );
    return maps;
  }
}