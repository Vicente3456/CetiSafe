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
import 'notificaciones_screen.dart';
import 'historial_hijo_screen.dart';
import 'vincular_hijo_screen.dart';
import 'perfil_padre_screen.dart';

class PadreHomeScreen extends StatefulWidget {
  final UserModel user;
  const PadreHomeScreen({super.key, required this.user});

  @override
  State<PadreHomeScreen> createState() => _PadreHomeScreenState();
}

class _PadreHomeScreenState extends State<PadreHomeScreen> {
  int _selectedIndex = 0;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  final List<_NavItem> _navItems = [
    _NavItem(icono: Icons.home_outlined, label: 'Inicio'),
    _NavItem(icono: Icons.notifications_outlined, label: 'Avisos'),
    _NavItem(icono: Icons.history_outlined, label: 'Historial'),
    _NavItem(icono: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      _PadreDashboard(user: widget.user),
      NotificacionesScreen(user: widget.user),
      HistorialHijoScreen(user: widget.user),
      PerfilPadreScreen(user: widget.user),
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
            } else if (value == 'vincular') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VincularHijoScreen(user: widget.user),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'vincular',
              child: Row(
                children: [
                  const Icon(Icons.link_outlined, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Vincular hijo',
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

// ── Dashboard Padre ─────────────────────────────────────────
class _PadreDashboard extends StatelessWidget {
  final UserModel user;
  const _PadreDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hora = DateTime.now().hour;
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

          // ── Banner ──
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
                        'Monitoreo en tiempo real',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blanco,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Recibe notificaciones cuando\ntu hijo llegue o salga del CETIS',
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
                    Icons.family_restroom_outlined,
                    color: AppColors.blanco,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Hijos vinculados ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hijos vinculados',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VincularHijoScreen(user: user),
                  ),
                ),
                child: Text(
                  '+ Vincular',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.vinoClaro : AppColors.vino,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _HijosVinculados(padreUid: user.uid),

          const SizedBox(height: 24),

          // ── Últimas notificaciones ──
          Text(
            'Últimas notificaciones',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
            ),
          ),

          const SizedBox(height: 14),

          _UltimasNotificaciones(padreUid: user.uid),
        ],
      ),
    );
  }
}

// ── Hijos vinculados ────────────────────────────────────────
class _HijosVinculados extends StatelessWidget {
  final String padreUid;
  const _HijosVinculados({required this.padreUid});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.colAlumnos)
          .where('padresUid', arrayContains: padreUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisOscuro : AppColors.blanco,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.textoGris.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textoGris,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'No tienes hijos vinculados aún.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombre = '${data['nombre']} ${data['apellido']}';
            final noControl = data['noControl'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.vinoClaro : AppColors.vino,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'No. Control: $noControl',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textoGris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.exito.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Vinculado',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.exito,
                      ),
                    ),
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

// ── Últimas notificaciones ──────────────────────────────────
class _UltimasNotificaciones extends StatelessWidget {
  final String padreUid;
  const _UltimasNotificaciones({required this.padreUid});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notificaciones')
          .where('padreUid', isEqualTo: padreUid)
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
                'Sin notificaciones aún',
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

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(12),
                border: !leida
                    ? Border.all(
                        color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                            .withValues(alpha: 0.3),
                      )
                    : null,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tipoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(tipoIcono, color: tipoColor, size: 18),
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
                        const SizedBox(height: 2),
                        Text(
                          mensaje,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textoGris,
                          ),
                        ),
                        const SizedBox(height: 4),
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

// ignore: depend_on_referenced_packages
