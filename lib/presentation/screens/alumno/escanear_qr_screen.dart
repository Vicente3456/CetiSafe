import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/alumno_model.dart';
import '../../../data/services/qr_service.dart';
import '../../../data/services/notificacion_service.dart';

class EscanearQrScreen extends StatefulWidget {
  final UserModel user;
  const EscanearQrScreen({super.key, required this.user});

  @override
  State<EscanearQrScreen> createState() => _EscanearQrScreenState();
}

class _EscanearQrScreenState extends State<EscanearQrScreen> {
  final QrService _qrService = QrService();
  final NotificacionService _notificacionService = NotificacionService();
  MobileScannerController? _controller;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _procesarQr(String codigo) async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final tipo = _qrService.verificarQr(codigo);
    if (tipo == null) {
      _mostrarResultado(
        exito: false,
        mensaje: 'QR no válido. Usa el QR oficial del CETIS 131.',
      );
      setState(() => _procesando = false);
      return;
    }

    try {
      final asistencia = await _qrService.registrarAsistencia(
        alumnoUid: widget.user.uid,
        tipo: tipo,
      );

      final alumnoDoc = await FirebaseFirestore.instance
          .collection(AppConstants.colAlumnos)
          .doc(widget.user.uid)
          .get();

      if (alumnoDoc.exists) {
        final alumno = AlumnoModel.fromMap(alumnoDoc.data()!);
        await _notificacionService.notificarPadres(
          asistencia: asistencia,
          alumno: alumno,
        );
      }

      _mostrarResultado(
        exito: true,
        mensaje:
            '${tipo == 'entrada' ? '✅ Entrada' : '🚪 Salida'} registrada a las ${asistencia.horaRegistro}',
      );
    } catch (e) {
      _mostrarResultado(
        exito: false,
        mensaje: 'Error al registrar: $e',
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mostrarResultado({required bool exito, required String mensaje}) {
    _controller?.stop();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: exito ? AppColors.exito : AppColors.error,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              exito ? Icons.check_circle_outline : Icons.error_outline,
              color: AppColors.blanco,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              exito ? '¡Registro exitoso!' : 'Error',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blanco,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.blanco.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blanco,
                foregroundColor: exito ? AppColors.exito : AppColors.error,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _controller?.start();
              },
              child: Text(
                'Continuar',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escanear QR',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textoClaro
                        : AppColors.textoOscuro,
                  ),
                ),
                Text(
                  'Apunta la cámara al código QR del CETIS 131',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textoGris,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller!,
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty &&
                            barcodes.first.rawValue != null) {
                          _procesarQr(barcodes.first.rawValue!);
                        }
                      },
                    ),
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.vinoClaro
                                : AppColors.vino,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    if (_procesando)
                      Container(
                        color: AppColors.negro.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.blanco,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? AppColors.vinoClaro : AppColors.vino,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Escanea el QR de entrada al llegar y el de salida al irte.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}