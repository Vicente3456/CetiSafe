import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/asistencia_model.dart';
import '../models/alumno_model.dart';

class NotificacionService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── INICIALIZAR ──────────────────────────────────────────
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@android/ic_notification_important',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  // ── NOTIFICACIÓN LOCAL ───────────────────────────────────
  Future<void> mostrarNotificacion({
    required String titulo,
    required String mensaje,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cetisafe_channel',
      'CetiSafe',
      channelDescription: 'Notificaciones de asistencia CetiSafe',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@android/ic_notification_important',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, titulo, mensaje, details);
  }

  // ── NOTIFICAR A PADRES ───────────────────────────────────
  Future<void> notificarPadres({
    required AsistenciaModel asistencia,
    required AlumnoModel alumno,
  }) async {
    final tipo = asistencia.tipo == 'entrada' ? 'llegó' : 'salió';
    final titulo =
        'CetiSafe — ${asistencia.tipo == 'entrada' ? 'Llegada' : 'Salida'}';
    final mensaje =
        '${alumno.nombreCompleto} $tipo al CETIS 131 a las ${asistencia.horaRegistro}.';

    // Guardar en Firestore para cada padre vinculado
    for (final padreUid in alumno.padresUid) {
      await _db.collection('notificaciones').add({
        'padreUid': padreUid,
        'alumnoUid': alumno.uid,
        'alumnoNombre': alumno.nombreCompleto,
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': asistencia.tipo,
        'leida': false,
        'fecha': Timestamp.fromDate(DateTime.now()),
      });
    }

    // Intentar mostrar notificación local sin crashear
    try {
      await mostrarNotificacion(
        titulo: titulo,
        mensaje:
            'Registro de ${asistencia.tipo} exitoso a las ${asistencia.horaRegistro}.',
      );
    } catch (_) {
      // Si falla la notificación local no afecta el registro
    }
  }

  // ── ALERTA DE AUSENCIA ───────────────────────────────────
  Future<void> alertarAusencia({
    required AlumnoModel alumno,
    required String horaEsperada,
  }) async {
    const titulo = 'CetiSafe — Ausencia';
    final mensaje = '${alumno.nombreCompleto} aún no ha llegado al CETIS 131. '
        'Se esperaba a las $horaEsperada.';

    for (final padreUid in alumno.padresUid) {
      await _db.collection('notificaciones').add({
        'padreUid': padreUid,
        'alumnoUid': alumno.uid,
        'alumnoNombre': alumno.nombreCompleto,
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': 'ausencia',
        'leida': false,
        'fecha': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // ── OBTENER NOTIFICACIONES DE UN PADRE ──────────────────
  Stream<QuerySnapshot> getNotificacionesPadre(String padreUid) {
    return _db
        .collection('notificaciones')
        .where('padreUid', isEqualTo: padreUid)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // ── MARCAR NOTIFICACIÓN COMO LEÍDA ──────────────────────
  Future<void> marcarLeida(String notificacionId) async {
    await _db
        .collection('notificaciones')
        .doc(notificacionId)
        .update({'leida': true});
  }

  // ── ENVIAR AVISO GENERAL ─────────────────────────────────
  Future<void> enviarAvisoGeneral({
    required String titulo,
    required String mensaje,
    required String adminUid,
  }) async {
    await _db.collection(AppConstants.colAvisos).add({
      'titulo': titulo,
      'mensaje': mensaje,
      'adminUid': adminUid,
      'fecha': Timestamp.fromDate(DateTime.now()),
    });

    try {
      await mostrarNotificacion(titulo: titulo, mensaje: mensaje);
    } catch (_) {}
  }

  // ── OBTENER AVISOS GENERALES ─────────────────────────────
  Stream<QuerySnapshot> getAvisosGenerales() {
    return _db
        .collection(AppConstants.colAvisos)
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}
