import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/asistencia_model.dart';
import '../../../data/services/pdf_service.dart';
import '../../widgets/estado_badge_widget.dart';

class HistorialHijoScreen extends StatefulWidget {
  final UserModel user;
  const HistorialHijoScreen({super.key, required this.user});

  @override
  State<HistorialHijoScreen> createState() => _HistorialHijoScreenState();
}

class _HistorialHijoScreenState extends State<HistorialHijoScreen> {
  String? _hijoUidSeleccionado;
  String? _hijoNombreSeleccionado;
  List<Map<String, dynamic>> _hijos = [];

  @override
  void initState() {
    super.initState();
    _cargarHijos();
  }

  Future<void> _cargarHijos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.colAlumnos)
        .where('padresUid', arrayContains: widget.user.uid)
        .get();

    setState(() {
      _hijos = snapshot.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
      // Print temporal
      print('Hijos encontrados: ${_hijos.length}');
      print('Primer hijo: ${_hijos.isNotEmpty ? _hijos.first : 'ninguno'}');
      if (_hijos.isNotEmpty) {
        _hijoUidSeleccionado = _hijos.first['uid'];
        _hijoNombreSeleccionado =
            '${_hijos.first['nombre']} ${_hijos.first['apellido']}';
      }
    });
  }

  void _mostrarDialogPdf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hijo = _hijos.firstWhere((h) => h['uid'] == _hijoUidSeleccionado);
    final nombre = '${hijo['nombre']} ${hijo['apellido']}';
    final noControl = (hijo['noControl'] ?? '').toString();

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
              'Exportar reporte de $nombre',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildBotonPeriodo(
              ctx: ctx,
              titulo: 'Reporte semanal',
              subtitulo: 'Asistencias de esta semana',
              icono: Icons.calendar_view_week_outlined,
              periodo: 'semanal',
              alumnoUid: _hijoUidSeleccionado!,
              alumnoNombre: nombre,
              noControl: noControl,
            ),
            const SizedBox(height: 12),
            _buildBotonPeriodo(
              ctx: ctx,
              titulo: 'Reporte mensual',
              subtitulo: 'Asistencias de este mes',
              icono: Icons.calendar_month_outlined,
              periodo: 'mensual',
              alumnoUid: _hijoUidSeleccionado!,
              alumnoNombre: nombre,
              noControl: noControl,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonPeriodo({
    required BuildContext ctx,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required String periodo,
    required String alumnoUid,
    required String alumnoNombre,
    required String noControl,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        await PdfService().generarPdfPadre(
          alumnoUid: alumnoUid,
          alumnoNombre: alumnoNombre,
          noControl: noControl,
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
      floatingActionButton: _hijoUidSeleccionado == null
          ? null
          : FloatingActionButton.extended(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.textoClaro : AppColors.textoOscuro,
                  ),
                ),
                Text(
                  'Asistencia de tus hijos',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Selector de hijo ──
          if (_hijos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textoGris.withValues(alpha: 0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _hijoUidSeleccionado,
                    isExpanded: true,
                    style: GoogleFonts.montserrat(fontSize: 14),
                    items: _hijos.map((h) {
                      return DropdownMenuItem(
                        value: h['uid'] as String,
                        child: Text(
                          '${h['nombre']} ${h['apellido']}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textoClaro
                                : AppColors.textoOscuro,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      final hijo = _hijos.firstWhere((h) => h['uid'] == v);
                      setState(() {
                        _hijoUidSeleccionado = v;
                        _hijoNombreSeleccionado =
                            '${hijo['nombre']} ${hijo['apellido']}';
                      });
                    },
                  ),
                ),
              ),
            ),

          if (_hijos.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textoGris.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes hijos vinculados',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_hijoUidSeleccionado != null) ...[
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.colAsistencias)
                    .where('alumnoUid', isEqualTo: _hijoUidSeleccionado)
                    .orderBy('fecha', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin registros de ${_hijoNombreSeleccionado ?? ''}',
                        style: GoogleFonts.montserrat(
                          color: AppColors.textoGris,
                        ),
                      ),
                    );
                  }

                  final asistencias = snapshot.data!.docs
                      .map((d) => AsistenciaModel.fromMap(
                          d.data() as Map<String, dynamic>))
                      .toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: asistencias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final a = asistencias[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.grisOscuro : AppColors.blanco,
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
        ],
      ),
    );
  }
}
