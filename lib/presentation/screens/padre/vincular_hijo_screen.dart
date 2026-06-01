import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class VincularHijoScreen extends StatefulWidget {
  final UserModel user;
  const VincularHijoScreen({super.key, required this.user});

  @override
  State<VincularHijoScreen> createState() => _VincularHijoScreenState();
}

class _VincularHijoScreenState extends State<VincularHijoScreen> {
  final _noControlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _buscando = false;
  bool _vinculando = false;
  Map<String, dynamic>? _alumnoEncontrado;
  String? _alumnoDocId;

  @override
  void dispose() {
    _noControlController.dispose();
    super.dispose();
  }

  Future<void> _buscarAlumno() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _buscando = true;
      _alumnoEncontrado = null;
      _alumnoDocId = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.colAlumnos)
          .where('noControl',
              isEqualTo: _noControlController.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se encontró ningún alumno con ese No. Control.',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        setState(() {
          _alumnoDocId = snapshot.docs.first.id;
          _alumnoEncontrado = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.montserrat(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _vincularAlumno() async {
    if (_alumnoDocId == null) return;
    setState(() => _vinculando = true);

    try {
      final padresUid = List<String>.from(
          _alumnoEncontrado!['padresUid'] ?? []);

      if (padresUid.contains(widget.user.uid)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ya estás vinculado con este alumno.',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            backgroundColor: AppColors.advertencia,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      padresUid.add(widget.user.uid);

      await FirebaseFirestore.instance
          .collection(AppConstants.colAlumnos)
          .doc(_alumnoDocId)
          .update({'padresUid': padresUid});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Vinculación exitosa.',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          backgroundColor: AppColors.exito,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.montserrat(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _vinculando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Vincular hijo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Instrucción ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? AppColors.vinoClaro : AppColors.vino,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ingresa el No. Control de tu hijo para vincularte y recibir notificaciones de su asistencia.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textoClaro
                            : AppColors.textoOscuro,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'No. Control del alumno',
                    controller: _noControlController,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Ingresa el No. Control'
                        : null,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _buscarAlumno(),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    texto: 'Buscar alumno',
                    icono: Icons.search_outlined,
                    onPressed: _buscarAlumno,
                    isLoading: _buscando,
                    variant: ButtonVariant.outline,
                  ),
                ],
              ),
            ),

            // ── Resultado ──
            if (_alumnoEncontrado != null) ...[
              const SizedBox(height: 24),
              Text(
                'Alumno encontrado',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textoClaro : AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.exito.withValues(alpha: 0.3),
                  ),
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
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.exito.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (_alumnoEncontrado!['nombre'] as String)
                                  .isNotEmpty
                                  ? (_alumnoEncontrado!['nombre'] as String)[0]
                                      .toUpperCase()
                                  : '?',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.exito,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_alumnoEncontrado!['nombre']} ${_alumnoEncontrado!['apellido']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'No. Control: ${_alumnoEncontrado!['noControl']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: AppColors.textoGris,
                                ),
                              ),
                              Text(
                                'Turno: ${_alumnoEncontrado!['turno']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: AppColors.textoGris,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      texto: 'Vincularme con este alumno',
                      icono: Icons.link_outlined,
                      onPressed: _vincularAlumno,
                      isLoading: _vinculando,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}