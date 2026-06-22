import 'package:flutter/material.dart';
import '../../data/models/zona_model.dart';
import '../../data/models/compra_response_model.dart';
import '../../data/models/mis_ticket_model.dart';
import '../../data/repositories/compra_repository.dart';

class CompraProvider extends ChangeNotifier {
  final CompraRepository _compraRepository = CompraRepository();

  List<ZonaModel> _zonas = [];
  bool _isLoading = false;
  String? _error;
  CompraResponseModel? _compraResponse;
  List<MisTicketModel> _misTickets = [];
  String _filtroTickets = 'comprados';
  bool _isLoadingTickets = false;
  int _ticketsRequestSeq = 0;

  List<ZonaModel> get zonas => _zonas;
  bool get isLoading => _isLoading;
  bool get isLoadingTickets => _isLoadingTickets;
  String? get error => _error;
  CompraResponseModel? get compraResponse => _compraResponse;
  List<MisTicketModel> get misTickets => _misTickets;
  String get filtroTickets => _filtroTickets;

  Future<void> loadZonas(int eventoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _zonas = await _compraRepository.getZonasEvento(eventoId);
    } catch (e) {
      _error = e.toString();
      _zonas = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> comprar({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String paymentMethodId,
  }) async {
    _isLoading = true;
    _error = null;
    _compraResponse = null;
    notifyListeners();

    try {
      _compraResponse = await _compraRepository.realizarCompra(
        eventoId: eventoId,
        zonaId: zonaId,
        cantidad: cantidad,
        paymentMethodId: paymentMethodId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Extraer mensaje limpio del error si es posible
      final errorStr = e.toString();
      if (errorStr.contains('Exception: ')) {
        _error = errorStr.split('Exception: ').last;
      } else {
        _error = errorStr;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMisTickets({String? filtro}) async {
    final filtroSolicitado = filtro ?? _filtroTickets;
    final cambioFiltro = filtro != null && filtro != _filtroTickets;

    if (filtro != null) {
      _filtroTickets = filtro;
    }

    final requestId = ++_ticketsRequestSeq;

    if (cambioFiltro) {
      _misTickets = [];
    }

    _isLoadingTickets = true;
    _error = null;
    notifyListeners();

    try {
      final tickets = await _compraRepository.getMisTickets(filtro: filtroSolicitado);

      if (requestId != _ticketsRequestSeq) return;

      _misTickets = tickets;
      _error = null;
    } catch (e) {
      if (requestId != _ticketsRequestSeq) return;

      final errorStr = e.toString();
      if (errorStr.contains('Exception: ')) {
        _error = errorStr.split('Exception: ').last;
      } else {
        _error = errorStr;
      }
      _misTickets = [];
    }

    if (requestId == _ticketsRequestSeq) {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }
}
