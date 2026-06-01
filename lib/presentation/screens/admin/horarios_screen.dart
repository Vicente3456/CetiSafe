import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/grupo_model.dart';
import '../../widgets/custom_button.dart';

class HorariosScreen extends StatefulWidget {
  final GrupoModel grupo;
  const HorariosScreen({super.key, required this.grupo});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late List<HorarioDia> _horarios;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _horarios = List.from(widget.grupo.horarios);
    // Si no tiene los 5 días, agregar los faltantes
    for (final dia in GrupoModel.diasSemana) {
      if (!_horarios.any((h) => h.dia == dia)) {
        _horarios.add(HorarioDia(
          dia: dia,
          horaEntrada: '07:00',
          horaSalida: '13:30',
        ));
      }
    }
    // Ordenar según días de semana
    _horarios.sort((a, b) => GrupoModel.diasSemana
        .indexOf(a.dia)
        .compareTo(GrupoModel.diasSemana.indexOf(b.dia)));
  }

  Future<void> _seleccionarHora(
    BuildContext context,
    int index,
    bool esEntrada,
  ) async {
    final horario = _horarios[index];
    final partsActual = esEntrada
        ? horario.horaEntrada.split(':')
        : horario.horaSalida.split(':');

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(partsActual[0]),
        minute: int.parse(partsActual[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.vino,
              onPrimary: AppColors.blanco,
              surface: AppColors.grisOscuro,
              onSurface: AppColors.textoClaro,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final horaStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (esEntrada) {
          _horarios[index] = _horarios[index].copyWith(horaEntrada: horaStr);
        } else {
          _horarios[index] = _horarios[index].copyWith(horaSalida: horaStr);
        }
      });
    }
  }

  Future<void> _guardarHorarios() async {
    setState(() => _guardando = true);
    try {
      await _db.collection(AppConstants.colGrupos).doc(widget.grupo.id).update({
        'horarios': _horarios.map((h) => h.toMap()).toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Horarios guardados correctamente.',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          backgroundColor: AppColors.exito,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar: $e',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _diaLabel(String dia) {
    const labels = {
      'lunes': 'Lunes',
      'martes': 'Martes',
      'miercoles': 'Miércoles',
      'jueves': 'Jueves',
      'viernes': 'Viernes',
    };
    return labels[dia] ?? dia;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: Text('Horarios — ${widget.grupo.nombre}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Info del grupo ──
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.vinoOscuro, AppColors.vino]
                    : [AppColors.vino, AppColors.vinoClaro],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  color: AppColors.blanco,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grupo ${widget.grupo.nombre}',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blanco,
                      ),
                    ),
                    Text(
                      'Semestre ${widget.grupo.semestre} — ${widget.grupo.turno}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.blanco.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tabla de horarios ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _horarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final horario = _horarios[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grisOscuro : AppColors.blanco,
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
                  child: Row(
                    children: [
                      // Día
                      SizedBox(
                        width: 90,
                        child: Text(
                          _diaLabel(horario.dia),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textoClaro
                                : AppColors.textoOscuro,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Entrada
                      GestureDetector(
                        onTap: () => _seleccionarHora(context, index, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.exito.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.exito.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.login_outlined,
                                color: AppColors.exito,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                horario.horaEntrada,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.exito,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.textoGris,
                      ),

                      const SizedBox(width: 8),

                      // Salida
                      GestureDetector(
                        onTap: () => _seleccionarHora(context, index, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout_outlined,
                                color: AppColors.error,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                horario.horaSalida,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Botón guardar ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              texto: 'Guardar horarios',
              icono: Icons.save_outlined,
              onPressed: _guardarHorarios,
              isLoading: _guardando,
            ),
          ),
        ],
      ),
    );
  }
}
