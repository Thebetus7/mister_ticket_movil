import '../models/registro_escaneo_model.dart';
import '../services/verificador_service.dart';

class VerificadorRepository {
  final VerificadorService _verificadorService = VerificadorService();

  Future<Map<String, dynamic>> verificarQr(String codigoQr) async {
    return await _verificadorService.verificarQr(codigoQr);
  }

  Future<List<RegistroEscaneoModel>> getMisRegistros() async {
    return await _verificadorService.getMisRegistros();
  }
}
