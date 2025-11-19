import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';
import '../../2_auth/services/auth_service.dart';

class PostService {
  final AuthService _authService = AuthService();
  Future<Database> get _db async => await DatabaseService.instance.database;

  Future<int> getPostCount(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM posts WHERE userId = ?',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<void> createPost({
    required String eventId,
    required String imagePath,
    required String caption,
  }) async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    final db = await _db;
    
    await db.transaction((txn) async {
      await txn.insert('posts', {
        'userId': userId,
        'eventId': eventId,
        'imagePath': imagePath,
        'caption': caption,
      });

      final List<Map<String, dynamic>> userMaps = await txn.query(
        'users',
        columns: ['points'],
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (userMaps.isNotEmpty) {
        int currentPoints = userMaps.first['points'];
        int newPoints = currentPoints + 10;

        await txn.update(
          'users',
          {'points': newPoints},
          where: 'id = ?',
          whereArgs: [userId],
        );

        await _authService.setCurrentUserPoints(newPoints);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getPostsByUser(int userId) async {
    final db = await _db;
    return await db.query(
      'posts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPostsForFriend(int friendId) async {
    return await getPostsByUser(friendId);
  }

  Future<void> deletePost(int postId) async {
     final db = await _db;
     await db.delete(
       'posts', 
       where: 'id = ?', 
       whereArgs: [postId]
     );
  }
}