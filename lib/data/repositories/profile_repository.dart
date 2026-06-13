import '../services/profile_service.dart';
import 'package:image_picker/image_picker.dart' show XFile;

/// Repositorio de perfil de usuario.
/// Intermediario entre el ProfileProvider (estado) y el ProfileService (red).
class ProfileRepository {
  final ProfileService _profileService = ProfileService();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _profileService.getProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileData(Map<String, dynamic> data) async {
    try {
      return await _profileService.updateProfileData(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileWithPhoto({
    required XFile foto,
    Map<String, String>? fields,
  }) async {
    try {
      return await _profileService.updateProfileWithPhoto(
        foto: foto,
        fields: fields,
      );
    } catch (e) {
      rethrow;
    }
  }
}
