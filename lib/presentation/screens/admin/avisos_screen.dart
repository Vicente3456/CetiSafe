import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/notificacion_service.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final NotificacionService _notificacionService;
  late final AuthService _authService;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _notificacionService = NotificacionService();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarAviso() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final uid = _authService.currentUser?.uid ?? '';
      await _notificacionService.enviarAvisoGeneral(
        titulo: _tituloController.text.trim(),
        mensaje: _mensajeController.text.trim(),
        adminUid: uid,
      );
      if (!mounted) return;
      _tituloController.clear();
      _mensajeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aviso enviado correctamente.',
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
          content:
              Text('Error: $e', style: GoogleFonts.montserrat(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Avisos generales'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Formulario nuevo aviso ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisOscuro : AppColors.blanco,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nuevo aviso',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Título',
                    controller: _tituloController,
                    prefixIcon: Icons.title_outlined,
                    validator: (v) => v == null || v.isEmpty
                        ? 'El título es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Mensaje',
                    controller: _mensajeController,
                    prefixIcon: Icons.message_outlined,
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty
                        ? 'El mensaje es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    texto: 'Enviar aviso',
                    icono: Icons.send_outlined,
                    onPressed: _enviarAviso,
                    isLoading: _enviando,
                  ),
                ],
              ),
            ),
          ),

          // ── Lista de avisos ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Avisos enviados',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notificacionService.getAvisosGenerales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay avisos enviados',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textoGris,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final fecha = (data['fecha'] as Timestamp).toDate();

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grisOscuro : AppColors.blanco,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.advertencia.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.campaign_outlined,
                              color: AppColors.advertencia,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['titulo'] ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['mensaje'] ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: AppColors.textoGris,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: AppColors.textoGris
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
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
