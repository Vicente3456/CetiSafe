import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/asistencia_model.dart';
import '../../../data/services/pdf_service.dart';
import '../../widgets/estado_badge_widget.dart';

class HistorialScreen extends StatefulWidget {
  final UserModel user;
  const HistorialScreen({super.key, required this.user});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _filtro = 'Todo';
  final List<String> _filtros = ['Todo', 'Entrada', 'Salida'];

  void _mostrarDialogPdf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grisOscuro : AppColors.blanco,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textoGris.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Exportar reporte PDF',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _BotonPeriodo(
              titulo: 'Reporte semanal',
              subtitulo: 'Asistencias de esta semana',
              icono: Icons.calendar_view_week_outlined,
              onTap: () async {
                Navigator.pop(ctx);
                await PdfService().generarPdfAlumno(
                  alumnoUid: widget.user.uid,
                  alumnoNombre: widget.user.nombreCompleto,
                  noControl: '',
                  periodo: 'semanal',
                );
              },
            ),
            const SizedBox(height: 12),
            _BotonPeriodo(
              titulo: 'Reporte mensual',
              subtitulo: 'Asistencias de este mes',
              icono: Icons.calendar_month_outlined,
              onTap: () async {
                Navigator.pop(ctx);
                await PdfService().generarPdfAlumno(
                  alumnoUid: widget.user.uid,
                  alumnoNombre: widget.user.nombreCompleto,
                  noControl: '',
                  periodo: 'mensual',
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogPdf(context),
        backgroundColor: isDark ? AppColors.vinoClaro : AppColors.vino,
        icon: const Icon(
          Icons.picture_as_pdf_outlined,
          color: AppColors.blanco,
        ),
        label: Text(
          'Exportar PDF',
          style: GoogleFonts.montserrat(
            color: AppColors.blanco,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi historial',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.textoClaro : AppColors.textoOscuro,
                  ),
                ),
                Text(
                  'Registro de entradas y salidas',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Filtros ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _filtros.map((f) {
                final isSelected = _filtro == f;
                return GestureDetector(
                  onTap: () => setState(() => _filtro = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.vinoClaro : AppColors.vino)
                          : (isDark ? AppColors.grisMedio : AppColors.blanco),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? AppColors.blanco : AppColors.textoGris,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Lista ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection(AppConstants.colAsistencias)
                  .where('alumnoUid', isEqualTo: widget.user.uid)
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
                          Icons.history_outlined,
                          size: 64,
                          color: AppColors.textoGris.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin registros aún',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var asistencias = snapshot.data!.docs
                    .map((d) => AsistenciaModel.fromMap(
                        d.data() as Map<String, dynamic>))
                    .toList();

                if (_filtro != 'Todo') {
                  asistencias = asistencias
                      .where((a) =>
                          a.tipo ==
                          (_filtro == 'Entrada' ? 'entrada' : 'salida'))
                      .toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: asistencias.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final a = asistencias[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.negro
                                .withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (a.tipo == 'entrada'
                                      ? AppColors.exito
                                      : AppColors.error)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              a.tipo == 'entrada'
                                  ? Icons.login_outlined
                                  : Icons.logout_outlined,
                              color: a.tipo == 'entrada'
                                  ? AppColors.exito
                                  : AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.tipo == 'entrada' ? 'Entrada' : 'Salida',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textoClaro
                                        : AppColors.textoOscuro,
                                  ),
                                ),
                                Text(
                                  a.fechaFormateada,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: AppColors.textoGris,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                a.horaRegistro,
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textoClaro
                                      : AppColors.textoOscuro,
                                ),
                              ),
                              const SizedBox(height: 4),
                              EstadoBadge(estado: a.estado, small: true),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón periodo PDF ───────────────────────────────────────
class _BotonPeriodo extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final VoidCallback onTap;

  const _BotonPeriodo({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grisMedio : AppColors.grisClaro,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: isDark ? AppColors.vinoClaro : AppColors.vino,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textoGris,
            ),
          ],
        ),
      ),
    );
  }
}
