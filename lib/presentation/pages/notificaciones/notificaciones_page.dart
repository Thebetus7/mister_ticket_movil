import 'package:flutter/material.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista simulada de notificaciones con diseño premium
    final notificaciones = [
      {
        'title': '¡Nuevo concierto anunciado!',
        'body': 'Duki se presentará el 15 de Octubre. ¡Preventa disponible mañana!',
        'time': 'Hace 5 min',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xFF7C6FF7),
        'unread': true,
      },
      {
        'title': 'Compra de Ticket Exitosa 🎉',
        'body': 'Tu boleto para "Coldplay - Music of the Spheres" ha sido emitido con éxito.',
        'time': 'Hace 2 horas',
        'icon': Icons.confirmation_number_rounded,
        'color': const Color(0xFF2ECC71),
        'unread': false,
      },
      {
        'title': 'Perfil verificado',
        'body': 'Tu perfil de Artista ha sido verificado. Ya puedes importar tu música.',
        'time': 'Hace 1 día',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF3498DB),
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mantente al día con tus eventos y música',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: notificaciones.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final notif = notificaciones[index];
                  final isUnread = notif['unread'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isUnread ? const Color(0xFF7C6FF7).withOpacity(0.3) : const Color(0xFF2A2A4E),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icono circular
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (notif['color'] as Color).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notif['icon'] as IconData,
                            color: notif['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Contenido de la notificación
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title'] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isUnread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF7C6FF7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['body'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                notif['time'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
