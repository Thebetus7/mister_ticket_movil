import '../../core/api/profile_api.dart';
import '../../core/network/api_client.dart';
import 'package:image_picker/image_picker.dart' show XFile;

/// Service de perfil de usuario.
/// Procesa los datos de respuesta y maneja la lógica de negocio del perfil.
class ProfileService {
  final ProfileApi _profileApi;

  ProfileService() : _profileApi = ProfileApi(ApiClient());

  /// Obtiene los datos del perfil del usuario autenticado.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _profileApi.getProfile();
    return response.data as Map<String, dynamic>;
  }

  /// Actualiza los datos de texto del perfil (sin foto).
  Future<Map<String, dynamic>> updateProfileData(Map<String, dynamic> data) async {
    final response = await _profileApi.updateProfileData(data);
    return response.data as Map<String, dynamic>;
  }

  /// Actualiza la foto de perfil (con multipart) y opcionalmente otros campos.
  Future<Map<String, dynamic>> updateProfileWithPhoto({
    required XFile foto,
    Map<String, String>? fields,
  }) async {
    final response = await _profileApi.updateProfileWithPhoto(
      foto: foto,
      fields: fields,
    );
    return response.data as Map<String, dynamic>;
  }
}
