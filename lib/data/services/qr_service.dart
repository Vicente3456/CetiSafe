import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/asistencia_model.dart';
import '../models/alumno_model.dart';
import '../models/grupo_model.dart';

class QrService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String qrEntradaContent = 'CETIS131_ENTRADA_2026';
  static const String qrSalidaContent = 'CETIS131_SALIDA_2026';

  // ── VERIFICAR QR ─────────────────────────────────────────
  String? verificarQr(String contenidoEscaneado) {
    if (contenidoEscaneado == qrEntradaContent) return 'entrada';
    if (contenidoEscaneado == qrSalidaContent) return 'salida';
    return null;
  }

  // ── REGISTRAR ASISTENCIA ─────────────────────────────────
  Future<AsistenciaModel> registrarAsistencia({
    required String alumnoUid,
    required String tipo,
  }) async {
    final alumnoDoc =
        await _db.collection(AppConstants.colAlumnos).doc(alumnoUid).get();

    if (!alumnoDoc.exists) throw Exception('Alumno no encontrado.');
    final alumno = AlumnoModel.fromMap(alumnoDoc.data()!);

    final grupoDoc =
        await _db.collection(AppConstants.colGrupos).doc(alumno.grupoId).get();

    final grupoNombre =
        grupoDoc.exists ? (grupoDoc.data()!['nombre'] ?? '') : '';

    final ahora = DateTime.now();
    final horaActual =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    String estado = AppConstants.estadoAsistio;

    if (grupoDoc.exists) {
      final grupo = GrupoModel.fromMap(grupoDoc.data()!);
      final diasSemana = [
        'lunes',
        'martes',
        'miercoles',
        'jueves',
        'viernes',
        'sabado',
        'domingo'
      ];
      final diaHoy = diasSemana[ahora.weekday - 1];
      final horarioDia = grupo.getHorarioDia(diaHoy);

      if (horarioDia != null) {
        if (tipo == 'entrada') {
          final minutosDesdeEntrada =
              _compararHoras(horaActual, horarioDia.horaEntrada);
          final minutosHastaSalida =
              _compararHoras(horarioDia.horaSalida, horaActual);

          if (minutosDesdeEntrada < -30) {
            // Llegó más de 30 min antes — asistió
            estado = AppConstants.estadoAsistio;
          } else if (minutosDesdeEntrada <= 30) {
            // Llegó dentro de 30 min después de la hora — asistió
            estado = AppConstants.estadoAsistio;
          } else if (minutosDesdeEntrada <= 120) {
            // Llegó entre 30 min y 2 horas tarde — retardo
            estado = AppConstants.estadoRetardo;
          } else if (minutosHastaSalida <= 60) {
            // Llegó cuando ya falta menos de 1 hora para salir — falta
            estado = AppConstants.estadoFalta;
          } else {
            // Llegó muy tarde — falta
            estado = AppConstants.estadoFalta;
          }
        } else if (tipo == 'salida') {
          // Para salida siempre es asistió
          estado = AppConstants.estadoAsistio;
        }
      }
    }

    final docRef = _db.collection(AppConstants.colAsistencias).doc();
    final asistencia = AsistenciaModel(
      id: docRef.id,
      alumnoUid: alumnoUid,
      alumnoNombre: alumno.nombreCompleto,
      noControl: alumno.noControl,
      grupoId: alumno.grupoId,
      grupoNombre: grupoNombre,
      tipo: tipo,
      estado: estado,
      fecha: DateTime(ahora.year, ahora.month, ahora.day),
      horaRegistro: horaActual,
    );

    await docRef.set(asistencia.toMap());
    return asistencia;
  }

  // ── OBTENER ASISTENCIAS DE UN ALUMNO ────────────────────
  Future<List<AsistenciaModel>> getAsistenciasAlumno({
    required String alumnoUid,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    Query query = _db
        .collection(AppConstants.colAsistencias)
        .where('alumnoUid', isEqualTo: alumnoUid)
        .orderBy('fecha', descending: true);

    if (desde != null) {
      query = query.where('fecha',
          isGreaterThanOrEqualTo: Timestamp.fromDate(desde));
    }
    if (hasta != null) {
      query =
          query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(hasta));
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            AsistenciaModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ── OBTENER ASISTENCIAS POR GRUPO ───────────────────────
  Future<List<AsistenciaModel>> getAsistenciasGrupo({
    required String grupoId,
    required DateTime fecha,
  }) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final snapshot = await _db
        .collection(AppConstants.colAsistencias)
        .where('grupoId', isEqualTo: grupoId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('fecha', isLessThan: Timestamp.fromDate(fin))
        .get();

    return snapshot.docs
        .map((doc) =>
            AsistenciaModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ── VERIFICAR FALTAS DEL DÍA ─────────────────────────────
  Future<void> verificarFaltasDelDia() async {
    final ahora = DateTime.now();
    final diasSemana = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo'
    ];
    final diaHoy = diasSemana[ahora.weekday - 1];

    // Obtener todos los grupos
    final gruposSnap = await _db.collection(AppConstants.colGrupos).get();

    for (final grupoDoc in gruposSnap.docs) {
      final grupo = GrupoModel.fromMap(grupoDoc.data());
      final horarioDia = grupo.getHorarioDia(diaHoy);
      if (horarioDia == null) continue;

      // Verificar si ya pasó la hora de entrada + 2 horas
      final minutosDesdeEntrada =
          _compararHoras(_horaActual(ahora), horarioDia.horaEntrada);
      if (minutosDesdeEntrada < 120) continue;

      // Obtener alumnos del grupo
      final alumnosSnap = await _db
          .collection(AppConstants.colAlumnos)
          .where('grupoId', isEqualTo: grupo.id)
          .get();

      for (final alumnoDoc in alumnosSnap.docs) {
        final alumno = AlumnoModel.fromMap(alumnoDoc.data());

        // Verificar si ya tiene registro hoy
        final inicio = DateTime(ahora.year, ahora.month, ahora.day);
        final fin = inicio.add(const Duration(days: 1));

        final asistenciaSnap = await _db
            .collection(AppConstants.colAsistencias)
            .where('alumnoUid', isEqualTo: alumno.uid)
            .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
            .where('fecha', isLessThan: Timestamp.fromDate(fin))
            .get();

        if (asistenciaSnap.docs.isEmpty) {
          // No tiene registro — registrar falta
          final docRef = _db.collection(AppConstants.colAsistencias).doc();
          final falta = AsistenciaModel(
            id: docRef.id,
            alumnoUid: alumno.uid,
            alumnoNombre: alumno.nombreCompleto,
            noControl: alumno.noControl,
            grupoId: grupo.id,
            grupoNombre: grupo.nombre,
            tipo: 'entrada',
            estado: AppConstants.estadoFalta,
            fecha: inicio,
            horaRegistro: _horaActual(ahora),
          );
          await docRef.set(falta.toMap());

          // Notificar a padres
          for (final padreUid in alumno.padresUid) {
            await _db.collection('notificaciones').add({
              'padreUid': padreUid,
              'alumnoUid': alumno.uid,
              'alumnoNombre': alumno.nombreCompleto,
              'titulo': '⚠️ CetiSafe — Falta',
              'mensaje':
                  '${alumno.nombreCompleto} no asistió al CETIS 131 el día de hoy.',
              'tipo': 'ausencia',
              'leida': false,
              'fecha': Timestamp.fromDate(ahora),
            });
          }
        }
      }
    }
  }

  // ── COMPARAR HORAS ───────────────────────────────────────
  int _compararHoras(String horaActual, String horaReferencia) {
    final partsActual = horaActual.split(':');
    final partsRef = horaReferencia.split(':');
    final minutosActual =
        int.parse(partsActual[0]) * 60 + int.parse(partsActual[1]);
    final minutosRef = int.parse(partsRef[0]) * 60 + int.parse(partsRef[1]);
    return minutosActual - minutosRef;
  }

  String _horaActual(DateTime ahora) {
    return '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
  }
}
