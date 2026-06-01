import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  final UserModel user;
  const NotificacionesScreen({super.key, required this.user});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen>
    with SingleTickerProviderStateMixin {
  late final NotificacionService _notificacionService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _notificacionService = NotificacionService();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Notificaciones',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tabs ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisMedio : AppColors.blanco,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.vinoClaro : AppColors.vino,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: AppColors.blanco,
              unselectedLabelColor: AppColors.textoGris,
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Asistencia'),
                Tab(text: 'Avisos'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Notificaciones de asistencia ──
                _NotificacionesAsistencia(
                  padreUid: widget.user.uid,
                  notificacionService: _notificacionService,
                ),
                // ── Tab 2: Avisos generales ──
                _AvisosGenerales(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notificaciones de asistencia ───────────────────────────
class _NotificacionesAsistencia extends StatelessWidget {
  final String padreUid;
  final NotificacionService notificacionService;

  const _NotificacionesAsistencia({
    required this.padreUid,
    required this.notificacionService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final docs = await FirebaseFirestore.instance
                    .collection('notificaciones')
                    .where('padreUid', isEqualTo: padreUid)
                    .where('leida', isEqualTo: false)
                    .get();
                for (final doc in docs.docs) {
                  await notificacionService.marcarLeida(doc.id);
                }
              },
              child: Text(
                'Marcar todas como leídas',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: isDark ? AppColors.vinoClaro : AppColors.vino,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: notificacionService.getNotificacionesPadre(padreUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: AppColors.textoGris.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin notificaciones',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildListaNotificaciones(
                  context, snapshot.data!.docs, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListaNotificaciones(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
    bool isDark,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final titulo = data['titulo'] ?? '';
        final mensaje = data['mensaje'] ?? '';
        final leida = data['leida'] ?? false;
        final fecha = (data['fecha'] as Timestamp).toDate();
        final tipo = data['tipo'] ?? '';

        Color tipoColor;
        IconData tipoIcono;
        if (tipo == 'entrada') {
          tipoColor = AppColors.exito;
          tipoIcono = Icons.login_outlined;
        } else if (tipo == 'salida') {
          tipoColor = AppColors.info;
          tipoIcono = Icons.logout_outlined;
        } else {
          tipoColor = AppColors.advertencia;
          tipoIcono = Icons.warning_amber_outlined;
        }

        return GestureDetector(
          onTap: () async {
            if (!leida) {
              await notificacionService.marcarLeida(docs[index].id);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisOscuro : AppColors.blanco,
              borderRadius: BorderRadius.circular(14),
              border: !leida
                  ? Border.all(
                      color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                          .withValues(alpha: 0.3),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tipoIcono, color: tipoColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titulo,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textoClaro
                                    : AppColors.textoOscuro,
                              ),
                            ),
                          ),
                          if (!leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.vinoClaro
                                    : AppColors.vino,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mensaje,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textoGris,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppColors.textoGris.withValues(alpha: 0.6),
                        ),
                      ),
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

// ── Avisos generales ────────────────────────────────────────
class _AvisosGenerales extends StatelessWidget {
  const _AvisosGenerales();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.colAvisos)
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: AppColors.textoGris.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin avisos',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final titulo = data['titulo'] ?? '';
            final mensaje = data['mensaje'] ?? '';
            final fecha = (data['fecha'] as Timestamp).toDate();

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.advertencia.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_outlined,
                      color: AppColors.advertencia,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textoClaro
                                : AppColors.textoOscuro,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mensaje,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textoGris,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: AppColors.textoGris.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
