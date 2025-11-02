import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';
import '../../2_auth/services/auth_service.dart';

class RedeemService {
  final AuthService _authService = AuthService();
  Future<Database> get _db async => await DatabaseService.instance.database;

  static const int _pointsPerCode = 10;
  Future<int> redeemCode(String code) async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception("Anda harus login untuk menukar kode.");
    }
    final db = await _db;
    try {
      await db.insert(
        'redeemed_codes',
        {'userId': userId, 'code': code},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception("Kode ini sudah pernah Anda gunakan.");
      }
      rethrow;
    }

    final int pointsToAdd = _pointsPerCode;
    final int currentPoints = await _authService.getCurrentUserPoints();
    final int newPoints = currentPoints + pointsToAdd;

    await db.update(
      'users',
      {'points': newPoints},
      where: 'id = ?',
      whereArgs: [userId],
    );

    await _authService.setCurrentUserPoints(newPoints);
    return newPoints;
  }
}