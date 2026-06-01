import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/asistencia_model.dart';

class PdfService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final PdfColor _vino = PdfColor.fromHex('#6D0E2A');
  static final PdfColor _vinoClaro = PdfColor.fromHex('#9B1540');
  static final PdfColor _grisClaro = PdfColor.fromHex('#F2F2F7');
  static final PdfColor _grisOscuro = PdfColor.fromHex('#1C1C1E');
  static final PdfColor _textoGris = PdfColor.fromHex('#8E8E93');
  static final PdfColor _exito = PdfColor.fromHex('#34C759');
  static final PdfColor _retardo = PdfColor.fromHex('#FF9500');
  static final PdfColor _falta = PdfColor.fromHex('#FF3B30');
  static final PdfColor _blanco = PdfColors.white;

  // ── CARGAR LOGO ──────────────────────────────────────────
  Future<pw.MemoryImage> _cargarLogo() async {
    final logoData = await rootBundle.load('assets/logo/logo.jpg');
    final logoBytes = logoData.buffer.asUint8List();
    return pw.MemoryImage(logoBytes);
  }

  // ── OBTENER ASISTENCIAS ──────────────────────────────────
  Future<List<AsistenciaModel>> _getAsistencias({
    required String campo,
    required String valor,
    required String periodo,
  }) async {
    final ahora = DateTime.now();
    late DateTime desde;
    if (periodo == 'semanal') {
      desde = ahora.subtract(Duration(days: ahora.weekday - 1));
      desde = DateTime(desde.year, desde.month, desde.day);
    } else {
      desde = DateTime(ahora.year, ahora.month, 1);
    }
    final snapshot = await _db
        .collection(AppConstants.colAsistencias)
        .where(campo, isEqualTo: valor)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .orderBy('fecha', descending: false)
        .get();
    return snapshot.docs.map((d) => AsistenciaModel.fromMap(d.data())).toList();
  }

  Future<List<AsistenciaModel>> _getTodasAsistencias({
    required String periodo,
  }) async {
    final ahora = DateTime.now();
    late DateTime desde;
    if (periodo == 'semanal') {
      desde = ahora.subtract(Duration(days: ahora.weekday - 1));
      desde = DateTime(desde.year, desde.month, desde.day);
    } else {
      desde = DateTime(ahora.year, ahora.month, 1);
    }
    final snapshot = await _db
        .collection(AppConstants.colAsistencias)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .orderBy('fecha', descending: false)
        .get();
    return snapshot.docs.map((d) => AsistenciaModel.fromMap(d.data())).toList();
  }

  // ── HEADER ───────────────────────────────────────────────
  pw.Widget _buildHeader({
    required pw.MemoryImage logo,
    required String titulo,
    required String subtitulo,
    required String periodo,
    required String fechaGenerado,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _vino,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(logo, width: 55, height: 55),
              ),
              pw.SizedBox(width: 14),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    AppConstants.appName,
                    style: pw.TextStyle(
                      color: _blanco,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    AppConstants.institucion,
                    style: pw.TextStyle(color: _blanco, fontSize: 11),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    titulo,
                    style: pw.TextStyle(
                      color: _blanco,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    subtitulo,
                    style: pw.TextStyle(color: _blanco, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _vinoClaro,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  periodo == 'semanal' ? 'Reporte Semanal' : 'Reporte Mensual',
                  style: pw.TextStyle(
                    color: _blanco,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generado: $fechaGenerado',
                style: pw.TextStyle(color: _blanco, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ESTADÍSTICAS ─────────────────────────────────────────
  pw.Widget _buildEstadisticas({
    required int total,
    required int asistencias,
    required int retardos,
    required int faltas,
  }) {
    return pw.Row(
      children: [
        _buildStatCard('Total', '$total', _vino),
        pw.SizedBox(width: 8),
        _buildStatCard('Asistencias', '$asistencias', _exito),
        pw.SizedBox(width: 8),
        _buildStatCard('Retardos', '$retardos', _retardo),
        pw.SizedBox(width: 8),
        _buildStatCard('Faltas', '$faltas', _falta),
      ],
    );
  }

  pw.Widget _buildStatCard(String label, String valor, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              valor,
              style: pw.TextStyle(
                color: _blanco,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              label,
              style: pw.TextStyle(color: _blanco, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ── TABLA ────────────────────────────────────────────────
  pw.Widget _buildTabla(List<AsistenciaModel> asistencias) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grisClaro, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _grisOscuro),
          children: [
            _buildCeldaHeader('Alumno'),
            _buildCeldaHeader('No. Control'),
            _buildCeldaHeader('Fecha'),
            _buildCeldaHeader('Hora'),
            _buildCeldaHeader('Estado'),
          ],
        ),
        ...asistencias.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final bgColor = i % 2 == 0 ? _blanco : _grisClaro;
          final estadoColor = a.estado == AppConstants.estadoAsistio
              ? _exito
              : a.estado == AppConstants.estadoRetardo
                  ? _retardo
                  : _falta;
          final estadoLabel = a.estado == AppConstants.estadoAsistio
              ? 'Asistió'
              : a.estado == AppConstants.estadoRetardo
                  ? 'Retardo'
                  : 'Falta';
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bgColor),
            children: [
              _buildCelda(a.alumnoNombre),
              _buildCelda(a.noControl),
              _buildCelda(a.fechaFormateada),
              _buildCelda(
                  '${a.tipo == 'entrada' ? '↓' : '↑'} ${a.horaRegistro}'),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: estadoColor,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    estadoLabel,
                    style: pw.TextStyle(
                      color: _blanco,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildCeldaHeader(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          color: _blanco,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildCelda(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        texto,
        style: pw.TextStyle(color: _grisOscuro, fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // ── FOOTER ───────────────────────────────────────────────
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _grisClaro, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${AppConstants.appName} — ${AppConstants.institucion}',
            style: pw.TextStyle(color: _textoGris, fontSize: 8),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(color: _textoGris, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ── GENERAR PDF ALUMNO ───────────────────────────────────
  Future<void> generarPdfAlumno({
    required String alumnoUid,
    required String alumnoNombre,
    required String noControl,
    required String periodo,
  }) async {
    final logo = await _cargarLogo();
    final asistencias = await _getAsistencias(
      campo: 'alumnoUid',
      valor: alumnoUid,
      periodo: periodo,
    );
    final total = asistencias.length;
    final asistio =
        asistencias.where((a) => a.estado == AppConstants.estadoAsistio).length;
    final retardo =
        asistencias.where((a) => a.estado == AppConstants.estadoRetardo).length;
    final falta =
        asistencias.where((a) => a.estado == AppConstants.estadoFalta).length;
    final ahora = DateTime.now();
    final fechaStr =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          children: [
            _buildHeader(
              logo: logo,
              titulo: 'Reporte de Asistencia',
              subtitulo: '$alumnoNombre — No. Control: $noControl',
              periodo: periodo,
              fechaGenerado: fechaStr,
            ),
            pw.SizedBox(height: 16),
            _buildEstadisticas(
              total: total,
              asistencias: asistio,
              retardos: retardo,
              faltas: falta,
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: _buildFooter,
        build: (context) => [
          if (asistencias.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Text(
                  'Sin registros en este período.',
                  style: pw.TextStyle(color: _textoGris, fontSize: 12),
                ),
              ),
            )
          else
            _buildTabla(asistencias),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'CetiSafe_${alumnoNombre.replaceAll(' ', '_')}_$periodo.pdf',
    );
  }

  // ── GENERAR PDF PADRE ────────────────────────────────────
  Future<void> generarPdfPadre({
    required String alumnoUid,
    required String alumnoNombre,
    required String noControl,
    required String periodo,
  }) async {
    await generarPdfAlumno(
      alumnoUid: alumnoUid,
      alumnoNombre: alumnoNombre,
      noControl: noControl,
      periodo: periodo,
    );
  }

  // ── GENERAR PDF ADMIN ────────────────────────────────────
  Future<void> generarPdfAdmin({
    required String? grupoId,
    required String grupoNombre,
    required String periodo,
  }) async {
    final logo = await _cargarLogo();
    final asistencias = grupoId != null
        ? await _getAsistencias(
            campo: 'grupoId',
            valor: grupoId,
            periodo: periodo,
          )
        : await _getTodasAsistencias(periodo: periodo);

    final total = asistencias.length;
    final asistio =
        asistencias.where((a) => a.estado == AppConstants.estadoAsistio).length;
    final retardo =
        asistencias.where((a) => a.estado == AppConstants.estadoRetardo).length;
    final falta =
        asistencias.where((a) => a.estado == AppConstants.estadoFalta).length;
    final ahora = DateTime.now();
    final fechaStr =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          children: [
            _buildHeader(
              logo: logo,
              titulo: 'Reporte General de Asistencia',
              subtitulo:
                  grupoId != null ? 'Grupo: $grupoNombre' : 'Todos los grupos',
              periodo: periodo,
              fechaGenerado: fechaStr,
            ),
            pw.SizedBox(height: 16),
            _buildEstadisticas(
              total: total,
              asistencias: asistio,
              retardos: retardo,
              faltas: falta,
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: _buildFooter,
        build: (context) => [
          if (asistencias.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Text(
                  'Sin registros en este período.',
                  style: pw.TextStyle(color: _textoGris, fontSize: 12),
                ),
              ),
            )
          else
            _buildTabla(asistencias),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'CetiSafe_Reporte_${grupoNombre.replaceAll(' ', '_')}_$periodo.pdf',
    );
  }
}
