import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/asistencia_model.dart';
import '../../../data/models/grupo_model.dart';
import '../../widgets/estado_badge_widget.dart';

class ListaAsistenciaScreen extends StatefulWidget {
  const ListaAsistenciaScreen({super.key});

  @override
  State<ListaAsistenciaScreen> createState() => _ListaAsistenciaScreenState();
}

class _ListaAsistenciaScreenState extends State<ListaAsistenciaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _grupoSeleccionado;
  List<GrupoModel> _grupos = [];

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    final snapshot =
        await _db.collection(AppConstants.colGrupos).orderBy('nombre').get();
    setState(() {
      _grupos = snapshot.docs.map((d) => GrupoModel.fromMap(d.data())).toList();
      if (_grupos.isNotEmpty) _grupoSeleccionado = _grupos.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Asistencia del día'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Selector de grupo ──
          if (_grupos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
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
                    value: _grupoSeleccionado,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: GoogleFonts.montserrat(fontSize: 14),
                    items: _grupos.map((g) {
                      return DropdownMenuItem(
                        value: g.id,
                        child: Text('Grupo ${g.nombre} — ${g.turno}'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _grupoSeleccionado = v),
                  ),
                ),
              ),
            ),

          // ── Lista de asistencias ──
          Expanded(
            child: _grupoSeleccionado == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection(AppConstants.colAsistencias)
                        .where('grupoId', isEqualTo: _grupoSeleccionado)
                        .where('fecha',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
                        .where('fecha', isLessThan: Timestamp.fromDate(fin))
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
                                Icons.fact_check_outlined,
                                size: 64,
                                color:
                                    AppColors.textoGris.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sin registros hoy',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: AppColors.textoGris,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final asistencias = snapshot.data!.docs
                          .map((d) => AsistenciaModel.fromMap(
                              d.data() as Map<String, dynamic>))
                          .toList();

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: asistencias.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final a = asistencias[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.grisOscuro
                                  : AppColors.blanco,
                              borderRadius: BorderRadius.circular(12),
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.vino.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      a.alumnoNombre.isNotEmpty
                                          ? a.alumnoNombre[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.vino,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.alumnoNombre,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'No. Control: ${a.noControl}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: AppColors.textoGris,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    EstadoBadge(
                                      estado: a.estado,
                                      small: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${a.tipo == 'entrada' ? '↓' : '↑'} ${a.horaRegistro}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: AppColors.textoGris,
                                      ),
                                    ),
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
