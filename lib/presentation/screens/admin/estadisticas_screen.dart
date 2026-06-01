import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/asistencia_model.dart';
import '../../../data/services/pdf_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _periodoSeleccionado = 'Hoy';
  final List<String> _periodos = ['Hoy', 'Esta semana', 'Este mes'];

  Stream<QuerySnapshot> _getStream() {
    final ahora = DateTime.now();
    late DateTime desde;
    if (_periodoSeleccionado == 'Hoy') {
      desde = DateTime(ahora.year, ahora.month, ahora.day);
    } else if (_periodoSeleccionado == 'Esta semana') {
      desde = ahora.subtract(Duration(days: ahora.weekday - 1));
      desde = DateTime(desde.year, desde.month, desde.day);
    } else {
      desde = DateTime(ahora.year, ahora.month, 1);
    }
    return _db
        .collection(AppConstants.colAsistencias)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .snapshots();
  }

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
            _buildBotonPdf(
              ctx: ctx,
              titulo: 'Reporte semanal',
              subtitulo: 'Todos los grupos esta semana',
              icono: Icons.calendar_view_week_outlined,
              periodo: 'semanal',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildBotonPdf(
              ctx: ctx,
              titulo: 'Reporte mensual',
              subtitulo: 'Todos los grupos este mes',
              icono: Icons.calendar_month_outlined,
              periodo: 'mensual',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonPdf({
    required BuildContext ctx,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required String periodo,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        await PdfService().generarPdfAdmin(
          grupoId: null,
          grupoNombre: 'Todos los grupos',
          periodo: periodo,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: () => _mostrarDialogPdf(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Selector de periodo ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _periodos.map((p) {
                final isSelected = _periodoSeleccionado == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodoSeleccionado = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.vinoClaro : AppColors.vino)
                            : (isDark ? AppColors.grisMedio : AppColors.blanco),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          p,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.blanco
                                : AppColors.textoGris,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Estadísticas ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final asistencias = docs
                    .map((d) => AsistenciaModel.fromMap(
                        d.data() as Map<String, dynamic>))
                    .toList();

                final total = asistencias.length;
                final asistio = asistencias
                    .where((a) => a.estado == AppConstants.estadoAsistio)
                    .length;
                final retardo = asistencias
                    .where((a) => a.estado == AppConstants.estadoRetardo)
                    .length;
                final falta = asistencias
                    .where((a) => a.estado == AppConstants.estadoFalta)
                    .length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Card total ──
                      Row(
                        children: [
                          _StatBig(
                            titulo: 'Total registros',
                            valor: '$total',
                            icono: Icons.people_outline,
                            color:
                                isDark ? AppColors.vinoClaro : AppColors.vino,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Cards detalle ──
                      Row(
                        children: [
                          Expanded(
                            child: _StatBig(
                              titulo: 'Asistencias',
                              valor: '$asistio',
                              icono: Icons.check_circle_outline,
                              color: AppColors.asistio,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBig(
                              titulo: 'Retardos',
                              valor: '$retardo',
                              icono: Icons.access_time_outlined,
                              color: AppColors.retardo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBig(
                              titulo: 'Faltas',
                              valor: '$falta',
                              icono: Icons.cancel_outlined,
                              color: AppColors.falta,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Barra de porcentaje ──
                      if (total > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.grisOscuro
                                : AppColors.blanco,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.negro
                                    .withValues(alpha: isDark ? 0.3 : 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distribución de asistencia',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    if (asistio > 0)
                                      Flexible(
                                        flex: asistio,
                                        child: Container(
                                          height: 12,
                                          color: AppColors.asistio,
                                        ),
                                      ),
                                    if (retardo > 0)
                                      Flexible(
                                        flex: retardo,
                                        child: Container(
                                          height: 12,
                                          color: AppColors.retardo,
                                        ),
                                      ),
                                    if (falta > 0)
                                      Flexible(
                                        flex: falta,
                                        child: Container(
                                          height: 12,
                                          color: AppColors.falta,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _Leyenda(
                                    color: AppColors.asistio,
                                    label:
                                        '${(asistio / total * 100).toStringAsFixed(0)}% Asistió',
                                  ),
                                  const SizedBox(width: 16),
                                  _Leyenda(
                                    color: AppColors.retardo,
                                    label:
                                        '${(retardo / total * 100).toStringAsFixed(0)}% Retardo',
                                  ),
                                  const SizedBox(width: 16),
                                  _Leyenda(
                                    color: AppColors.falta,
                                    label:
                                        '${(falta / total * 100).toStringAsFixed(0)}% Falta',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBig extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatBig({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grisOscuro : AppColors.blanco,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              valor,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppColors.textoGris,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String label;

  const _Leyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: AppColors.textoGris,
          ),
        ),
      ],
    );
  }
}
