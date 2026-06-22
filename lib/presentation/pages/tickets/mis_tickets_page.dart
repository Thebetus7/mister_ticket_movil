import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/compra_provider.dart';
import '../../../data/models/mis_ticket_model.dart';
import '../../widgets/ticket_qr_widget.dart';
import 'transferir_ticket_sheet.dart';


class MisTicketsPage extends StatefulWidget {
  const MisTicketsPage({super.key});

  @override
  State<MisTicketsPage> createState() => _MisTicketsPageState();
}

class _MisTicketsPageState extends State<MisTicketsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompraProvider>(context, listen: false).loadMisTickets();
    });
  }

  void _mostrarTransferirSheet(MisTicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransferirTicketSheet(ticket: ticket),
    );
  }

  String _formatFecha(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatHora(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7C6FF7);
    final backgroundColor = const Color(0xFF0F0F1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: themeColor,
        backgroundColor: const Color(0xFF161626),
        onRefresh: () async {
          final provider = Provider.of<CompraProvider>(context, listen: false);
          await provider.loadMisTickets();
        },
        child: Consumer<CompraProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'comprados', label: Text('Comprados')),
                      ButtonSegment(value: 'usados', label: Text('Usados')),
                    ],
                    selected: {provider.filtroTickets},
                    onSelectionChanged: (selection) {
                      final nuevoFiltro = selection.first;
                      if (nuevoFiltro == provider.filtroTickets) return;
                      provider.loadMisTickets(filtro: nuevoFiltro);
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return Colors.white54;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return themeColor;
                        }
                        return const Color(0xFF161626);
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTicketList(context, provider, themeColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context, CompraProvider provider, Color themeColor) {
    if (provider.isLoadingTickets) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
      );
    }

    if (provider.error != null && provider.misTickets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No pudimos cargar tus tickets.',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.loadMisTickets(),
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.misTickets.isEmpty) {
      final esUsados = provider.filtroTickets == 'usados';
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161626),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_number_outlined,
                      color: themeColor.withOpacity(0.4), size: 64),
                ),
                const SizedBox(height: 20),
                Text(
                  esUsados ? 'No tienes tickets usados' : 'Aún no tienes tickets comprados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  esUsados
                      ? 'Los tickets que ya fueron escaneados en la entrada aparecerán aquí.'
                      : 'Tus boletos para eventos aparecerán en esta sección una vez completes una compra exitosa.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: provider.misTickets.length,
      itemBuilder: (context, index) {
        final ticket = provider.misTickets[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161626),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Parte superior: Información del evento
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF7C6FF7).withOpacity(0.05), const Color(0xFFE100FF).withOpacity(0.05)],
                            ),
                            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icono Ticket
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.local_activity_rounded, color: themeColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.eventoNombre.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, color: Colors.white30, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatFecha(ticket.eventoFecha),
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.access_time_rounded, color: Colors.white30, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatHora(ticket.eventoFecha),
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Parte Media: Detalles del boleto (Zona, asiento, estado)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ZONA / SECCIÓN',
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ticket.zonaNombre,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'ASIENTO',
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ticket.asientoDetalle != null
                                        ? 'Fila ${ticket.asientoDetalle!.fila}, Col ${ticket.asientoDetalle!.columna}'
                                        : 'General (Sin Numerar)',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'ESTADO',
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: ticket.estado == 'activo'
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ticket.estado.toUpperCase(),
                                      style: TextStyle(
                                        color: ticket.estado == 'activo'
                                            ? Colors.greenAccent
                                            : Colors.white38,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Línea discontinua simulando cupón de ticket
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: List.generate(
                              30,
                              (index) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  height: 1,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Parte inferior: QR Placeholder, código y acciones
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'CÓDIGO DE BOLETO',
                                      style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket.codigoQr,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ticket.transferido
                                          ? 'Este ticket ya fue transferido.'
                                          : 'Presenta el ticket digital en la entrada del evento.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              TicketQrWidget(codigoQr: ticket.codigoQr),
                            ],
                          ),
                              if (ticket.transferible) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _mostrarTransferirSheet(ticket),
                                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                                    label: const Text('Transferir a otro fan'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: themeColor,
                                      side: BorderSide(color: themeColor.withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
  }
}
