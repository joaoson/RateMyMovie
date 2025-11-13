import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const String _loggedInUserKey = 'logged_in_user_id';

  Future<bool> register(UserModel user) async {
    try {
      final existingUser = await DatabaseService.instance.getUserByEmail(user.email);
      if (existingUser != null) {
        return false; 
      }

      await DatabaseService.instance.createUser(user);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final user = await DatabaseService.instance.getUserByEmail(email);
      if (user != null && user.password == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_loggedInUserKey, user.id!);
        return user;
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  Future<bool> updateUserEmail(int userId, String newEmail) async {
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.update(
        'users',
        {'email': newEmail},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  Future<bool> updateUserPassword(int userId, String newPassword) async {
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  Future<bool> updateUserProfileImage(int userId, String? imagePath) async {
    try {
      final db = await DatabaseService.instance.database;
      int result;
      
      if (imagePath == null) {
        // Use raw SQL to properly set NULL value
        result = await db.rawUpdate(
          'UPDATE users SET profileImagePath = ? WHERE id = ?',
          [null, userId],
        );
      } else {
        result = await db.update(
          'users',
          {'profileImagePath': imagePath},
          where: 'id = ?',
          whereArgs: [userId],
        );
      }
      
      return result > 0;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final db = await DatabaseService.instance.database;
      await db.delete('rated_movies', where: 'userId = ?', whereArgs: [userId]);
      final result = await db.delete('users', where: 'id = ?', whereArgs: [userId]);
      return result > 0;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loggedInUserKey);
  }
}