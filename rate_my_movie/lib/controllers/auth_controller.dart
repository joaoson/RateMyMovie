import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    final userId = await _authService.getLoggedInUserId();
    if (userId != null) {
      // Load user from database
      final users = await DatabaseService.instance.database;
      final userMaps = await users.query('users', where: 'id = ?', whereArgs: [userId]);
      if (userMaps.isNotEmpty) {
        _currentUser = UserModel.fromMap(userMaps.first);
      }
    }
    // Don't call notifyListeners during initial load from splash screen
  }

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Por favor, preencha todos os campos';
    }

    _isLoading = true;
    notifyListeners();

    final user = await _authService.login(email, password);
    
    _isLoading = false;
    
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return null; // Success
    } else {
      notifyListeners();
      return 'Email ou senha incorretos';
    }
  }

  Future<String?> register(UserModel user) async {
    if (user.name.isEmpty || user.email.isEmpty || user.password.isEmpty) {
      return 'Por favor, preencha todos os campos';
    }

    if (!_isValidEmail(user.email)) {
      return 'Por favor, insira um email válido';
    }

    if (user.password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    _isLoading = true;
    notifyListeners();

    try {
      // If user selected a profile image, copy it to permanent storage
      String? permanentImagePath;
      if (user.profileImagePath != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'profile_temp_$timestamp${path.extension(user.profileImagePath!)}';
        permanentImagePath = path.join(appDir.path, fileName);
        
        final File sourceFile = File(user.profileImagePath!);
        if (await sourceFile.exists()) {
          await sourceFile.copy(permanentImagePath);
        } else {
          permanentImagePath = null;
        }
      }

      // Create user with permanent image path
      final userToRegister = user.copyWith(profileImagePath: permanentImagePath);
      final success = await _authService.register(userToRegister);
      
      _isLoading = false;

      if (success) {
        // Auto login after registration
        await login(userToRegister.email, userToRegister.password);
        return null; // Success
      } else {
        notifyListeners();
        return 'Este email já está cadastrado';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Erro ao cadastrar: $e';
    }
  }

  Future<String?> updateEmail(String newEmail, String password) async {
    if (_currentUser == null) {
      return 'Usuário não autenticado';
    }

    if (newEmail.isEmpty) {
      return 'Por favor, insira um email';
    }

    if (!_isValidEmail(newEmail)) {
      return 'Por favor, insira um email válido';
    }

    if (password.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    // Verify current password
    if (_currentUser!.password != password) {
      return 'Senha incorreta';
    }

    // Check if email already exists
    final existingUser = await DatabaseService.instance.getUserByEmail(newEmail);
    if (existingUser != null && existingUser.id != _currentUser!.id) {
      return 'Este email já está cadastrado';
    }

    try {
      final success = await _authService.updateUserEmail(_currentUser!.id!, newEmail);
      if (success) {
        _currentUser = _currentUser!.copyWith(email: newEmail);
        notifyListeners();
        return null; // Success
      } else {
        return 'Erro ao atualizar email';
      }
    } catch (e) {
      return 'Erro ao atualizar email: $e';
    }
  }

  Future<String?> updatePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) {
      return 'Usuário não autenticado';
    }

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      return 'Por favor, preencha todos os campos';
    }

    if (_currentUser!.password != currentPassword) {
      return 'Senha atual incorreta';
    }

    if (newPassword.length < 6) {
      return 'A nova senha deve ter pelo menos 6 caracteres';
    }

    try {
      final success = await _authService.updateUserPassword(_currentUser!.id!, newPassword);
      if (success) {
        _currentUser = _currentUser!.copyWith(password: newPassword);
        notifyListeners();
        return null; // Success
      } else {
        return 'Erro ao atualizar senha';
      }
    } catch (e) {
      return 'Erro ao atualizar senha: $e';
    }
  }

  Future<String?> updateProfileImage(String imagePath) async {
    if (_currentUser == null) {
      return 'Usuário não autenticado';
    }

    try {
      // Copy the image to permanent storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final permanentPath = path.join(appDir.path, fileName);
      
      // Copy the file
      final File sourceFile = File(imagePath);
      await sourceFile.copy(permanentPath);
      
      // Delete old profile image if it exists
      if (_currentUser!.profileImagePath != null) {
        try {
          final oldFile = File(_currentUser!.profileImagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          print('Error deleting old profile image: $e');
        }
      }
      
      final success = await _authService.updateUserProfileImage(_currentUser!.id!, permanentPath);
      if (success) {
        _currentUser = _currentUser!.copyWith(profileImagePath: permanentPath);
        notifyListeners();
        return null; // Success
      } else {
        return 'Erro ao atualizar foto de perfil';
      }
    } catch (e) {
      return 'Erro ao atualizar foto de perfil: $e';
    }
  }

  Future<String?> removeProfileImage() async {
    if (_currentUser == null) {
      return 'Usuário não autenticado';
    }

    try {
      // Delete the profile image file
      if (_currentUser!.profileImagePath != null) {
        try {
          final file = File(_currentUser!.profileImagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting profile image file: $e');
        }
      }
      
      final success = await _authService.updateUserProfileImage(_currentUser!.id!, null);
      if (success) {
        _currentUser = _currentUser!.copyWith(profileImagePath: null);
        notifyListeners();
        return null; // Success
      } else {
        return 'Erro ao remover foto de perfil';
      }
    } catch (e) {
      return 'Erro ao remover foto de perfil: $e';
    }
  }

  Future<String?> deleteAccount(String password) async {
    if (_currentUser == null) {
      return 'Usuário não autenticado';
    }

    if (password.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (_currentUser!.password != password) {
      return 'Senha incorreta';
    }

    try {
      final success = await _authService.deleteUser(_currentUser!.id!);
      if (success) {
        await logout();
        return null; // Success
      } else {
        return 'Erro ao excluir conta';
      }
    } catch (e) {
      return 'Erro ao excluir conta: $e';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);
  }
}