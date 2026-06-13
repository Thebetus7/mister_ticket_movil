import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> login(String username, String password) async {
    try {
      await _authService.login(username, password);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
  }
}
