import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../auth/login_screen.dart';
import 'grupos_screen.dart';
import 'generar_qr_screen.dart';
import 'lista_asistencia_screen.dart';
import 'estadisticas_screen.dart';
import 'avisos_screen.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';

class AdminHomeScreen extends StatefulWidget {
  final UserModel user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  final List<_NavItem> _navItems = [
    _NavItem(icono: Icons.dashboard_outlined, label: 'Inicio'),
    _NavItem(icono: Icons.groups_outlined, label: 'Grupos'),
    _NavItem(icono: Icons.qr_code_rounded, label: 'QR'),
    _NavItem(icono: Icons.bar_chart_outlined, label: 'Reportes'),
    _NavItem(icono: Icons.campaign_outlined, label: 'Avisos'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      _AdminDashboard(user: widget.user),
      const GruposScreen(),
      const GenerarQrScreen(),
      const EstadisticasScreen(),
      const AvisosScreen(),
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
        // Toggle modo oscuro/claro
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
        // Menú de opciones
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
            } else if (value == 'perfil') {
              _mostrarPerfil();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'perfil',
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Mi perfil',
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                ],
              ),
            ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
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

  void _mostrarPerfil() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grisOscuro : AppColors.blanco,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
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
            const SizedBox(height: 24),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? AppColors.vinoClaro : AppColors.vino,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.user.nombre[0].toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blanco,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.user.nombreCompleto,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.correo,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppColors.textoGris,
              ),
            ),
            const SizedBox(height: 8),
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
                'Administrador',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.vinoClaro : AppColors.vino,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard principal ─────────────────────────────────────
class _AdminDashboard extends StatelessWidget {
  final UserModel user;
  const _AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final hora = now.hour;
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
          // ── Saludo ──
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

          // ── Banner fecha ──
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
                        AppConstants.institucion,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.blanco.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Panel de Control',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blanco,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFechaFormateada(now),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppColors.blanco.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.blanco,
                  size: 48,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Accesos rápidos ──
          Text(
            'Accesos rápidos',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _AccesoRapido(
                icono: Icons.qr_code_rounded,
                titulo: 'Generar QR',
                subtitulo: 'Entrada y salida',
                color: AppColors.vino,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GenerarQrScreen(),
                  ),
                ),
              ),
              _AccesoRapido(
                icono: Icons.fact_check_outlined,
                titulo: 'Asistencia',
                subtitulo: 'Lista del día',
                color: AppColors.info,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ListaAsistenciaScreen(),
                  ),
                ),
              ),
              _AccesoRapido(
                icono: Icons.groups_outlined,
                titulo: 'Grupos',
                subtitulo: 'Horarios',
                color: AppColors.exito,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GruposScreen(),
                  ),
                ),
              ),
              _AccesoRapido(
                icono: Icons.campaign_outlined,
                titulo: 'Avisos',
                subtitulo: 'Notificaciones',
                color: AppColors.advertencia,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvisosScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Estadísticas rápidas ──
          Text(
            'Resumen del día',
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
                child: _StatCard(
                  titulo: 'Asistencias',
                  valor: '—',
                  icono: Icons.check_circle_outline,
                  color: AppColors.asistio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  titulo: 'Retardos',
                  valor: '—',
                  icono: Icons.access_time_outlined,
                  color: AppColors.retardo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  titulo: 'Faltas',
                  valor: '—',
                  icono: Icons.cancel_outlined,
                  color: AppColors.falta,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getFechaFormateada(DateTime fecha) {
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${dias[fecha.weekday - 1]}, ${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

// ── Acceso rápido card ──────────────────────────────────────
class _AccesoRapido extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.textoClaro : AppColors.textoOscuro,
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
          ],
        ),
      ),
    );
  }
}

// ── Stat card ───────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            valor,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: AppColors.textoGris,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icono;
  final String label;
  _NavItem({required this.icono, required this.label});
}
