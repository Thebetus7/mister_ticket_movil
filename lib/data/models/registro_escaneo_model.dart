class RegistroEscaneoModel {
  final int id;
  final String resultado;
  final String ticketCodigoQr;
  final String eventoNombre;
  final String zonaNombre;
  final DateTime createdAt;

  RegistroEscaneoModel({
    required this.id,
    required this.resultado,
    required this.ticketCodigoQr,
    required this.eventoNombre,
    required this.zonaNombre,
    required this.createdAt,
  });

  factory RegistroEscaneoModel.fromJson(Map<String, dynamic> json) {
    return RegistroEscaneoModel(
      id: json['id'],
      resultado: json['resultado'] ?? '',
      ticketCodigoQr: json['ticket_codigo_qr'] ?? '',
      eventoNombre: json['evento_nombre'] ?? '',
      zonaNombre: json['zona_nombre'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
