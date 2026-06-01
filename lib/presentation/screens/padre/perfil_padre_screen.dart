import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/info_row_widget.dart';

class PerfilPadreScreen extends StatelessWidget {
  final UserModel user;
  const PerfilPadreScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi perfil',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
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
                      color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Padre de familia — CETIS 131',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.vinoClaro : AppColors.vino,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Datos personales ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(16),
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
                    'Datos personales',
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Hijos vinculados ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(16),
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
                    'Hijos vinculados',
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(AppConstants.colAlumnos)
                        .where('padresUid', arrayContains: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Text(
                          'Sin hijos vinculados',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.textoGris,
                          ),
                        );
                      }
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return InfoRow(
                            label: 'Alumno',
                            value:
                                '${data['nombre']} ${data['apellido']}',
                            icono: Icons.school_outlined,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}