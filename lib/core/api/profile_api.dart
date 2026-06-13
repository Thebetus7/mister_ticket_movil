import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';
import 'package:image_picker/image_picker.dart' show XFile;

/// API modular de perfil de usuario.
/// Define todos los endpoints relacionados con el perfil del usuario autenticado.
class ProfileApi {
  final ApiClient _client;

  ProfileApi(this._client);

  /// GET /api/usuarios/perfil/ — Obtener mi perfil
  Future<ApiResponse> getProfile() {
    return _client.get(ApiConstants.profile);
  }

  /// PATCH /api/usuarios/perfil/ — Actualizar datos del perfil (sin foto)
  Future<ApiResponse> updateProfileData(Map<String, dynamic> data) {
    return _client.patch(ApiConstants.profile, body: data);
  }

  /// PUT /api/usuarios/perfil/ — Actualizar perfil con foto (multipart/form-data)
  Future<ApiResponse> updateProfileWithPhoto({
    required XFile foto,
    Map<String, String>? fields,
  }) {
    return _client.patchMultipart(
      ApiConstants.profile,
      file: foto,
      fileFieldName: 'foto',
      fields: fields,
    );
  }
}
