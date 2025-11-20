import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/database_service.dart';

class AuthService {
  static const String _sessionUserIdKey = 'currentUserId';
  static const String _sessionUsernameKey = 'currentUsername';
  static const String _sessionPointsKey = 'currentUserPoints';

  Future<Database> get _db async => await DatabaseService.instance.database;

  Future<bool> register(String username, String password) async {
    final db = await _db;
    final String hashedPassword =
        BCrypt.hashpw(password, BCrypt.gensalt());
    try {
      await db.insert(
        'users',
        {
          'username': username,
          'hashedPassword': hashedPassword,
          'points': 0
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Username sudah terdaftar.');
      }
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    final db = await _db;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) {
      throw Exception('Username tidak ditemukan.');
    }

    final user = maps.first;
    final String hashedPassword = user['hashedPassword'];

    if (BCrypt.checkpw(password, hashedPassword)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionUserIdKey, user['id']);
      await prefs.setString(_sessionUsernameKey, user['username']);
      await prefs.setInt(_sessionPointsKey, user['points']);
      return true;
    } else {
      throw Exception('Password salah.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionUsernameKey);
    await prefs.remove(_sessionPointsKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionUserIdKey);
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionUsernameKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionUserIdKey);
  }

  Future<int> getCurrentUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionPointsKey) ?? 0;
  }

  Future<void> setCurrentUserPoints(int newPoints) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionPointsKey, newPoints);
  }
}