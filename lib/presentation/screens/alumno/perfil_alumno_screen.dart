import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/alumno_model.dart';
import '../../../data/models/grupo_model.dart';
import '../../widgets/info_row_widget.dart';

class PerfilAlumnoScreen extends StatelessWidget {
  final UserModel user;
  const PerfilAlumnoScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(AppConstants.colAlumnos)
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          AlumnoModel? alumno;
          if (snapshot.hasData && snapshot.data!.exists) {
            alumno = AlumnoModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header perfil ──
                Text(
                  'Mi perfil',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textoClaro
                        : AppColors.textoOscuro,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Avatar ──
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.vinoOscuro, AppColors.vino]
                                : [AppColors.vino, AppColors.vinoClaro],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.vino.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.nombre.isNotEmpty
                                ? user.nombre[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blanco,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.nombreCompleto,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textoClaro
                              : AppColors.textoOscuro,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.vinoClaro
                                  : AppColors.vino)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Alumno — CETIS 131',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.vinoClaro
                                : AppColors.vino,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Datos personales ──
                _SeccionPerfil(
                  titulo: 'Datos personales',
                  children: [
                    InfoRow(
                      label: 'Nombre',
                      value: user.nombre,
                      icono: Icons.person_outline,
                    ),
                    InfoRow(
                      label: 'Apellidos',
                      value: user.apellido,
                      icono: Icons.person_outline,
                    ),
                    InfoRow(
                      label: 'Correo',
                      value: user.correo,
                      icono: Icons.email_outlined,
                    ),
                    if (alumno != null)
                      InfoRow(
                        label: 'No. Control',
                        value: alumno.noControl,
                        icono: Icons.badge_outlined,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Datos académicos ──
                if (alumno != null)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(AppConstants.colGrupos)
                        .doc(alumno.grupoId)
                        .get(),
                    builder: (context, grupoSnap) {
                      String grupoNombre = '—';
                      String turno = alumno!.turno;
                      if (grupoSnap.hasData && grupoSnap.data!.exists) {
                        final grupo = GrupoModel.fromMap(
                            grupoSnap.data!.data() as Map<String, dynamic>);
                        grupoNombre = grupo.nombre;
                      }
                      return _SeccionPerfil(
                        titulo: 'Datos académicos',
                        children: [
                          InfoRow(
                            label: 'Grupo',
                            value: grupoNombre,
                            icono: Icons.groups_outlined,
                          ),
                          InfoRow(
                            label: 'Turno',
                            value: turno,
                            icono: Icons.schedule_outlined,
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeccionPerfil extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionPerfil({
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grisOscuro : AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.vinoClaro : AppColors.vino,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.textoGris.withValues(alpha: 0.2),
            height: 1,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}