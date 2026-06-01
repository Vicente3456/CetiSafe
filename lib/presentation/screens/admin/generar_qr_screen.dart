import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/qr_service.dart';

class GenerarQrScreen extends StatefulWidget {
  const GenerarQrScreen({super.key});

  @override
  State<GenerarQrScreen> createState() => _GenerarQrScreenState();
}

class _GenerarQrScreenState extends State<GenerarQrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _tabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrData =
        _tabIndex == 0 ? QrService.qrEntradaContent : QrService.qrSalidaContent;
    final color = _tabIndex == 0 ? AppColors.exito : AppColors.error;
    final label = _tabIndex == 0 ? 'Entrada' : 'Salida';
    final icono = _tabIndex == 0 ? Icons.login_outlined : Icons.logout_outlined;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Generar QR'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.blanco,
          labelColor: AppColors.blanco,
          unselectedLabelColor: AppColors.blanco.withValues(alpha: 0.6),
          labelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.login_outlined),
              text: 'QR Entrada',
            ),
            Tab(
              icon: Icon(Icons.logout_outlined),
              text: 'QR Salida',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QrView(
            qrData: QrService.qrEntradaContent,
            color: AppColors.exito,
            label: 'Entrada',
            icono: Icons.login_outlined,
            isDark: isDark,
          ),
          _QrView(
            qrData: QrService.qrSalidaContent,
            color: AppColors.error,
            label: 'Salida',
            icono: Icons.logout_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _QrView extends StatelessWidget {
  final String qrData;
  final Color color;
  final String label;
  final IconData icono;
  final bool isDark;

  const _QrView({
    required this.qrData,
    required this.color,
    required this.label,
    required this.icono,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Badge tipo ──
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'QR de $label',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── QR Code ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.negro.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: AppColors.blanco,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color:
                          label == 'Entrada' ? AppColors.vino : AppColors.negro,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color:
                          label == 'Entrada' ? AppColors.vino : AppColors.negro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CETIS 131 — $label',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Instrucciones ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grisOscuro : AppColors.blanco,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrucciones',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? AppColors.textoClaro : AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Instruccion(
                    numero: '1',
                    texto: 'Muestra este QR en la pantalla o imprímelo.',
                    color: color,
                  ),
                  _Instruccion(
                    numero: '2',
                    texto: 'El alumno lo escanea con su app CetiSafe.',
                    color: color,
                  ),
                  _Instruccion(
                    numero: '3',
                    texto: 'El sistema registra la $label automáticamente.',
                    color: color,
                  ),
                  _Instruccion(
                    numero: '4',
                    texto: 'Los padres reciben notificación en tiempo real.',
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Instruccion extends StatelessWidget {
  final String numero;
  final String texto;
  final Color color;

  const _Instruccion({
    required this.numero,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                numero,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textoClaro.withValues(alpha: 0.8)
                    : AppColors.textoGris,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
