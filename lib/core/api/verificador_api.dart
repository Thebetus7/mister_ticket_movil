import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class VerificadorApi {
  final ApiClient _client;

  VerificadorApi(this._client);

  Future<ApiResponse> verificarQr(String codigoQr) {
    return _client.post(
      ApiConstants.verificarQr,
      body: {'codigo_qr': codigoQr},
    );
  }

  Future<ApiResponse> getMisRegistros() {
    return _client.get(ApiConstants.misRegistros);
  }
}
