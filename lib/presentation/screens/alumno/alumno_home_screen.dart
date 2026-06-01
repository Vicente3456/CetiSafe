import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../../../app.dart';
import 'escanear_qr_screen.dart';
import 'historial_screen.dart';
import 'perfil_alumno_screen.dart';
import 'avisos_alumno_screen.dart';

class AlumnoHomeScreen extends StatefulWidget {
  final UserModel user;
  const AlumnoHomeScreen({super.key, required this.user});

  @override
  State<AlumnoHomeScreen> createState() => _AlumnoHomeScreenState();
}

class _AlumnoHomeScreenState extends State<AlumnoHomeScreen> {
  int _selectedIndex = 0;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  final List<_NavItem> _navItems = [
    _NavItem(icono: Icons.home_outlined, label: 'Inicio'),
    _NavItem(icono: Icons.qr_code_scanner_outlined, label: 'Escanear'),
    _NavItem(icono: Icons.history_outlined, label: 'Historial'),
    _NavItem(icono: Icons.campaign_outlined, label: 'Avisos'),
    _NavItem(icono: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      _AlumnoDashboard(user: widget.user),
      EscanearQrScreen(user: widget.user),
      HistorialScreen(user: widget.user),
      AvisosAlumnoScreen(user: widget.user),
      PerfilAlumnoScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: _buildAppBar(isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.grisOscuro : AppColors.vino,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.blanco.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo/logo.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blanco,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: AppColors.blanco,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.blanco),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_outlined,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.grisOscuro : AppColors.blanco,
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.vinoClaro.withValues(alpha: 0.15)
                            : AppColors.vino.withValues(alpha: 0.1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icono,
                        color: isSelected
                            ? (isDark ? AppColors.vinoClaro : AppColors.vino)
                            : AppColors.textoGris,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.vinoClaro : AppColors.vino)
                              : AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Alumno ────────────────────────────────────────
class _AlumnoDashboard extends StatelessWidget {
  final UserModel user;
  const _AlumnoDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ahora = DateTime.now();
    final hora = ahora.hour;
    String saludo;
    if (hora < 12) {
      saludo = 'Buenos días';
    } else if (hora < 18) {
      saludo = 'Buenas tardes';
    } else {
      saludo = 'Buenas noches';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$saludo,',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppColors.textoGris,
            ),
          ),
          Text(
            user.nombre,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.vinoOscuro, AppColors.vino]
                    : [AppColors.vino, AppColors.vinoClaro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vino.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar asistencia',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blanco,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Escanea el QR de entrada\no salida del CETIS 131',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.blanco.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blanco.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_outlined,
                    color: AppColors.blanco,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Accesos rápidos',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AccesoCard(
                  icono: Icons.history_outlined,
                  titulo: 'Mi historial',
                  subtitulo: 'Entradas y salidas',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccesoCard(
                  icono: Icons.calendar_month_outlined,
                  titulo: 'Calendario',
                  subtitulo: 'Mis asistencias',
                  color: AppColors.exito,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Últimos registros',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),
          const SizedBox(height: 14),
          _UltimosRegistros(alumnoUid: user.uid),
        ],
      ),
    );
  }
}

// ── Acceso card ─────────────────────────────────────────────
class _AccesoCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;

  const _AccesoCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
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
            color: AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),
          Text(
            subtitulo,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: AppColors.textoGris,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Últimos registros ───────────────────────────────────────
class _UltimosRegistros extends StatelessWidget {
  final String alumnoUid;
  const _UltimosRegistros({required this.alumnoUid});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.colAsistencias)
          .where('alumnoUid', isEqualTo: alumnoUid)
          .orderBy('fecha', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisOscuro : AppColors.blanco,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'Sin registros aún',
                style: GoogleFonts.montserrat(
                  color: AppColors.textoGris,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tipo = data['tipo'] ?? '';
            final hora = data['horaRegistro'] ?? '';
            final fecha = (data['fecha'] as Timestamp).toDate();
            final estado = data['estado'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(12),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (tipo == 'entrada'
                              ? AppColors.exito
                              : AppColors.error)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tipo == 'entrada'
                          ? Icons.login_outlined
                          : Icons.logout_outlined,
                      color:
                          tipo == 'entrada' ? AppColors.exito : AppColors.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipo == 'entrada' ? 'Entrada' : 'Salida',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${fecha.day}/${fecha.month}/${fecha.year}',
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
                      Text(
                        hora,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textoClaro
                              : AppColors.textoOscuro,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (estado == AppConstants.estadoAsistio
                                  ? AppColors.asistio
                                  : estado == AppConstants.estadoRetardo
                                      ? AppColors.retardo
                                      : AppColors.falta)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          estado == AppConstants.estadoAsistio
                              ? 'Asistió'
                              : estado == AppConstants.estadoRetardo
                                  ? 'Retardo'
                                  : 'Falta',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: estado == AppConstants.estadoAsistio
                                ? AppColors.asistio
                                : estado == AppConstants.estadoRetardo
                                    ? AppColors.retardo
                                    : AppColors.falta,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icono;
  final String label;
  _NavItem({required this.icono, required this.label});
}
