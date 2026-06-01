import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/grupo_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final String rolInicial;

  const RegisterScreen({
    super.key,
    required this.rolInicial,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _noControlController = TextEditingController();

  late String _rolSeleccionado;
  String? _grupoIdSeleccionado;
  String? _turnoSeleccionado;
  bool _isLoading = false;
  bool _cargandoGrupos = false;
  List<GrupoModel> _grupos = [];

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _rolSeleccionado = widget.rolInicial;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _cargarGrupos();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    _noControlController.dispose();
    super.dispose();
  }

  Future<void> _cargarGrupos() async {
    setState(() => _cargandoGrupos = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.colGrupos)
          .get();
      if (mounted) {
        final lista =
            snapshot.docs.map((d) => GrupoModel.fromMap(d.data())).toList();
        lista.sort((a, b) => a.nombre.compareTo(b.nombre));
        setState(() {
          _grupos = lista;
          _cargandoGrupos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoGrupos = false);
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rolSeleccionado == AppConstants.rolAlumno) {
      if (_grupoIdSeleccionado == null) {
        _mostrarError('Selecciona tu grupo.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registrar(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        password: _passwordController.text,
        rol: _rolSeleccionado,
        noControl: _rolSeleccionado == AppConstants.rolAlumno
            ? _noControlController.text.trim()
            : null,
        grupoId: _grupoIdSeleccionado,
        turno: _turnoSeleccionado,
      );

      if (!mounted) return;
      _mostrarExito();
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

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.exito,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Registro exitoso!',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu cuenta ha sido creada correctamente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppColors.textoGris,
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            texto: 'Iniciar sesión',
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Selector de rol ──
                Text(
                  'Registrarse como',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGris,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppConstants.rolAlumno,
                    AppConstants.rolPadre,
                  ].map((rol) {
                    final isSelected = _rolSeleccionado == rol;
                    final label =
                        rol == AppConstants.rolAlumno ? 'Alumno' : 'Padre';
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _rolSeleccionado = rol),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.vinoClaro
                                    : AppColors.vino)
                                : (isDark
                                    ? AppColors.grisMedio
                                    : AppColors.grisClaro),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
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

                const SizedBox(height: 24),

                // ── Campos generales ──
                CustomTextField(
                  label: 'Nombre(s)',
                  controller: _nombreController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.nombre,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Apellidos',
                  controller: _apellidoController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.apellido,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Correo electrónico',
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.correo,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Confirmar contraseña',
                  controller: _confirmarPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) =>
                      Validators.confirmarPassword(v, _passwordController.text),
                  textInputAction: TextInputAction.next,
                ),

                // ── Campos exclusivos de alumno ──
                if (_rolSeleccionado == AppConstants.rolAlumno) ...[
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'No. Control',
                    controller: _noControlController,
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.noControl,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Grupo',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.textoGris,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Selector de grupo ──
                  if (_cargandoGrupos)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textoGris.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cargando grupos...',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_grupos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textoGris.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: AppColors.advertencia,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No se encontraron grupos',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppColors.textoGris,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _cargarGrupos,
                            child: Icon(
                              Icons.refresh,
                              color:
                                  isDark ? AppColors.vinoClaro : AppColors.vino,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _grupoIdSeleccionado,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textoClaro
                            : AppColors.textoOscuro,
                      ),
                      dropdownColor:
                          isDark ? AppColors.grisOscuro : AppColors.blanco,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.group_outlined,
                          color: AppColors.textoGris,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: Text(
                        'Selecciona tu grupo',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppColors.textoGris,
                        ),
                      ),
                      items: _grupos.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(
                            '${g.nombre} — ${g.turno}',
                            style: GoogleFonts.montserrat(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _grupoIdSeleccionado = v;
                          final grupo = _grupos.firstWhere((g) => g.id == v);
                          _turnoSeleccionado = grupo.turno;
                        });
                      },
                    ),
                ],

                const SizedBox(height: 32),

                CustomButton(
                  texto: 'Crear cuenta',
                  onPressed: _registrar,
                  isLoading: _isLoading,
                  icono: Icons.person_add_outlined,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textoGris,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Inicia sesión',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.vinoClaro : AppColors.vino,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
