import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../state/verificador_provider.dart';

class EscanearQrPage extends StatefulWidget {
  const EscanearQrPage({super.key});

  @override
  State<EscanearQrPage> createState() => _EscanearQrPageState();
}

class _EscanearQrPageState extends State<EscanearQrPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);
    await _controller.stop();

    final provider = Provider.of<VerificadorProvider>(context, listen: false);
    final ok = await provider.verificarQr(raw.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? (provider.lastMessage ?? 'Ticket verificado') : (provider.error ?? 'Error')),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );

    setState(() => _processing = false);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF7C6FF7);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                const Text(
                  'Escanear ticket',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Apunta la cámara al código QR del ticket del fan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),
                    if (_processing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: themeColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processing
                    ? null
                    : () async {
                        if (_controller.torchEnabled) {
                          await _controller.toggleTorch();
                        } else {
                          await _controller.toggleTorch();
                        }
                      },
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Alternar linterna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
