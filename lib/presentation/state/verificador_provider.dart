import 'package:flutter/material.dart';
import '../../data/models/registro_escaneo_model.dart';
import '../../data/repositories/verificador_repository.dart';

class VerificadorProvider extends ChangeNotifier {
  final VerificadorRepository _repository = VerificadorRepository();

  List<RegistroEscaneoModel> _registros = [];
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _error;
  String? _lastMessage;

  List<RegistroEscaneoModel> get registros => _registros;
  bool get isLoading => _isLoading;
  bool get isVerifying => _isVerifying;
  String? get error => _error;
  String? get lastMessage => _lastMessage;

  Future<void> loadRegistros() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _registros = await _repository.getMisRegistros();
    } catch (e) {
      _error = _extractError(e);
      _registros = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verificarQr(String codigoQr) async {
    _isVerifying = true;
    _error = null;
    _lastMessage = null;
    notifyListeners();

    try {
      final result = await _repository.verificarQr(codigoQr);
      _lastMessage = result['detail']?.toString();
      _isVerifying = false;
      await loadRegistros();
      return true;
    } catch (e) {
      _error = _extractError(e);
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  String _extractError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('Exception: ')) {
      return errorStr.split('Exception: ').last;
    }
    return errorStr;
  }
}
