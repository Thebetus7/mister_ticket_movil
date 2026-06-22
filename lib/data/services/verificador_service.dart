import '../../core/api/verificador_api.dart';
import '../../core/network/api_client.dart';
import '../models/registro_escaneo_model.dart';

class VerificadorService {
  final VerificadorApi _verificadorApi;

  VerificadorService() : _verificadorApi = VerificadorApi(ApiClient());

  Future<Map<String, dynamic>> verificarQr(String codigoQr) async {
    final response = await _verificadorApi.verificarQr(codigoQr);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Respuesta de verificación inválida.');
  }

  Future<List<RegistroEscaneoModel>> getMisRegistros() async {
    final response = await _verificadorApi.getMisRegistros();
    if (response.data is List) {
      return (response.data as List)
          .map((json) => RegistroEscaneoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
