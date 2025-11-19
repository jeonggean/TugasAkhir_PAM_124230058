import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';

class FriendService {
  Future<Database> get _db async => await DatabaseService.instance.database;

  Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['username', 'points'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      columns: ['id', 'username', 'points'],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }
  

  Future<int> getAcceptedFriendCount(int userId) async {
    final db = await _db;
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM friendships
      WHERE (requesterId = ? OR receiverId = ?) AND status = 'accepted'
    ''', [userId, userId]);
    return countResult.first['count'] as int? ?? 0;
  }
  
  

  Future<void> sendFriendRequest(int requesterId, int receiverId) async {
    if (requesterId == receiverId) {
      throw Exception('Anda tidak dapat menambahkan diri sendiri.');
    }
    final db = await _db;

    final status = await getRelationStatus(requesterId, receiverId);
    if (status != 'none') {
      throw Exception(_statusToMessage(status));
    }

    await db.insert(
      'friendships',
      {
        'requesterId': requesterId,
        'receiverId': receiverId,
        'status': 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> acceptFriendRequest(int requesterId, int receiverId) async {
    final db = await _db;
    final count = await db.update(
      'friendships',
      {'status': 'accepted'},
      where: 'requesterId = ? AND receiverId = ? AND status = ?',
      whereArgs: [requesterId, receiverId, 'pending'],
    );
    if (count == 0) {
      throw Exception('Permintaan tidak ditemukan atau sudah diproses.');
    }
  }

  Future<void> rejectFriendRequest(int requesterId, int receiverId) async {
    final db = await _db;
    await db.delete(
      'friendships',
      where: 'requesterId = ? AND receiverId = ? AND status = ?',
      whereArgs: [requesterId, receiverId, 'pending'],
    );
  }

  Future<void> removeFriend(int userIdA, int userIdB) async {
    final db = await _db;
    await db.delete(
      'friendships',
      where:
          'status = ? AND ((requesterId = ? AND receiverId = ?) OR (requesterId = ? AND receiverId = ?))',
      whereArgs: ['accepted', userIdA, userIdB, userIdB, userIdA],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(int userId) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT F.requesterId AS id, U.username, U.points
      FROM friendships F
      INNER JOIN users U ON U.id = F.requesterId
      WHERE F.receiverId = ? AND F.status = 'pending'
      ORDER BY F.id DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getOutgoingRequests(int userId) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT F.receiverId AS id, U.username, U.points
      FROM friendships F
      INNER JOIN users U ON U.id = F.receiverId
      WHERE F.requesterId = ? AND F.status = 'pending'
      ORDER BY F.id DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getFriends(int currentUserId) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT U.id, U.username, U.points
      FROM users U
      WHERE U.id != ?
        AND EXISTS (
          SELECT 1 FROM friendships F
          WHERE F.status = 'accepted'
            AND (
              (F.requesterId = ? AND F.receiverId = U.id) OR
              (F.receiverId = ? AND F.requesterId = U.id)
            )
        )
      ORDER BY U.points DESC
    ''', [currentUserId, currentUserId, currentUserId]);
  }

  Future<List<Map<String, dynamic>>> getFavoritesForUser(int friendId) async {
    final db = await _db;
    return await db.query('favorites', where: 'userId = ?', whereArgs: [friendId]);
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await _db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<String> getRelationStatus(int a, int b) async {
    if (a == b) return 'self';
    final db = await _db;

    final rows = await db.query(
      'friendships',
      where:
          '(requesterId = ? AND receiverId = ?) OR (requesterId = ? AND receiverId = ?)',
      whereArgs: [a, b, b, a],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) return 'none';
    final r = rows.first;
    final status = (r['status'] as String).toLowerCase();
    final isOutgoing = r['requesterId'] == a;

    if (status == 'accepted') return 'friends';
    if (status == 'pending' && isOutgoing) return 'pending_out';
    if (status == 'pending' && !isOutgoing) return 'pending_in';
    return 'none';
  }

  String _statusToMessage(String status) {
    switch (status) {
      case 'self':
        return 'Anda tidak dapat menambahkan diri sendiri.';
      case 'friends':
        return 'Sudah berteman.';
      case 'pending_out':
        return 'Permintaan sudah dikirim. Menunggu persetujuan.';
      case 'pending_in':
        return 'Pengguna ini sudah mengirim permintaan kepada Anda.';
      default:
        return 'Relasi sudah ada.';
    }
  }
}
