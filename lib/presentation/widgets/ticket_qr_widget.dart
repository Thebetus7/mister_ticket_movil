import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketQrWidget extends StatelessWidget {
  final String codigoQr;
  final double size;

  const TicketQrWidget({
    super.key,
    required this.codigoQr,
    this.size = 70,
  });

  static void showQrModal(BuildContext context, String codigoQr) {
    if (codigoQr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este ticket no tiene código QR disponible.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF161626),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Código QR del ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: QrImageView(
                      data: codigoQr,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  codigoQr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showQrModal(context, codigoQr),
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: codigoQr.isEmpty
            ? const Icon(Icons.qr_code_2, color: Colors.black38)
            : SizedBox(
                width: size - 12,
                height: size - 12,
                child: QrImageView(
                  data: codigoQr,
                  version: QrVersions.auto,
                  size: size - 12,
                  backgroundColor: Colors.white,
                ),
              ),
      ),
    );
  }
}
