import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import '../alumno/alumno_home_screen.dart';
import '../padre/padre_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;

  String _rolSeleccionado = AppConstants.rolAlumno;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        correo: _correoController.text.trim(),
        password: _passwordController.text,
        rolSeleccionado: _rolSeleccionado,
      );

      if (!mounted) return;

      switch (user!.rol) {
        case AppConstants.rolAlumno:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AlumnoHomeScreen(user: user),
            ),
          );
          break;
        case AppConstants.rolPadre:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PadreHomeScreen(user: user),
            ),
          );
          break;
        case AppConstants.rolAdmin:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomeScreen(user: user),
            ),
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: GoogleFonts.montserrat(fontSize: 13),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarDialogRecuperar() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Recuperar contraseña',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: CustomTextField(
          label: 'Correo electrónico',
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(color: AppColors.textoGris),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _authService.recuperarPassword(controller.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Se envió un correo para recuperar tu contraseña.',
                      style: GoogleFonts.montserrat(fontSize: 13),
                    ),
                    backgroundColor: AppColors.exito,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Enviar',
              style: GoogleFonts.montserrat(
                color: AppColors.vino,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.08),

              // ── Logo y título ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.vinoClaro : AppColors.vino,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vino.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/logo/logo.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textoClaro
                            : AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.institucion,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // ── Selector de rol ──
              Text(
                'Iniciar sesión como',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppColors.textoGris,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _RolSelector(
                rolSeleccionado: _rolSeleccionado,
                onRolChanged: (rol) => setState(() => _rolSeleccionado = rol),
              ),

              const SizedBox(height: 28),

              // ── Formulario ──
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Correo electrónico',
                      hint: 'ejemplo@correo.com',
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'El correo es obligatorio.';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'La contraseña es obligatoria.';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Olvidé contraseña ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _mostrarDialogRecuperar,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: isDark ? AppColors.vinoClaro : AppColors.vino,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Botón login ──
              CustomButton(
                texto: 'Iniciar sesión',
                onPressed: _login,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              // ── Ir a registro ──
              if (_rolSeleccionado != AppConstants.rolAdmin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textoGris,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(
                            rolInicial: _rolSeleccionado,
                          ),
                        ),
                      ),
                      child: Text(
                        'Regístrate',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.vinoClaro : AppColors.vino,
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget selector de rol ──────────────────────────────────
class _RolSelector extends StatelessWidget {
  final String rolSeleccionado;
  final void Function(String) onRolChanged;

  const _RolSelector({
    required this.rolSeleccionado,
    required this.onRolChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final roles = [
      {
        'rol': AppConstants.rolAlumno,
        'label': 'Alumno',
        'icono': Icons.school_outlined,
      },
      {
        'rol': AppConstants.rolPadre,
        'label': 'Padre',
        'icono': Icons.family_restroom_outlined,
      },
      {
        'rol': AppConstants.rolAdmin,
        'label': 'Admin',
        'icono': Icons.admin_panel_settings_outlined,
      },
    ];

    return Row(
      children: roles.map((r) {
        final isSelected = rolSeleccionado == r['rol'];
        return Expanded(
          child: GestureDetector(
            onTap: () => onRolChanged(r['rol'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.vinoClaro : AppColors.vino)
                    : (isDark ? AppColors.grisMedio : AppColors.grisClaro),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.vino.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    r['icono'] as IconData,
                    color: isSelected ? AppColors.blanco : AppColors.textoGris,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r['label'] as String,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.blanco : AppColors.textoGris,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
