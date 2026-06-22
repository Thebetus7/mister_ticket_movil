import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/verificador_provider.dart';

class HistorialEscaneosPage extends StatefulWidget {
  const HistorialEscaneosPage({super.key});

  @override
  State<HistorialEscaneosPage> createState() => _HistorialEscaneosPageState();
}

class _HistorialEscaneosPageState extends State<HistorialEscaneosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VerificadorProvider>(context, listen: false).loadRegistros();
    });
  }

  Color _colorResultado(String resultado) {
    switch (resultado) {
      case 'aprobado':
        return Colors.greenAccent;
      case 'ya_usado':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF7C6FF7);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: () => Provider.of<VerificadorProvider>(context, listen: false).loadRegistros(),
        child: Consumer<VerificadorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.registros.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: themeColor));
            }

            if (provider.registros.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Icon(Icons.history_rounded, size: 64, color: themeColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin escaneos registrados',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los tickets que verifiques aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.registros.length,
              itemBuilder: (context, index) {
                final reg = provider.registros[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161626),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reg.eventoNombre,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _colorResultado(reg.resultado).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reg.resultado.toUpperCase(),
                              style: TextStyle(
                                color: _colorResultado(reg.resultado),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(reg.zonaNombre, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        reg.ticketCodigoQr,
                        style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reg.createdAt.day}/${reg.createdAt.month}/${reg.createdAt.year} ${reg.createdAt.hour.toString().padLeft(2, '0')}:${reg.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
