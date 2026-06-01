import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaModel {
  final String id;
  final String alumnoUid;
  final String alumnoNombre;
  final String noControl;
  final String grupoId;
  final String grupoNombre;
  final String tipo;
  final String estado;
  final DateTime fecha;
  final String horaRegistro;

  AsistenciaModel({
    required this.id,
    required this.alumnoUid,
    required this.alumnoNombre,
    required this.noControl,
    required this.grupoId,
    required this.grupoNombre,
    required this.tipo,
    required this.estado,
    required this.fecha,
    required this.horaRegistro,
  });

  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  factory AsistenciaModel.fromMap(Map<String, dynamic> map) {
    return AsistenciaModel(
      id: map['id'] ?? '',
      alumnoUid: map['alumnoUid'] ?? '',
      alumnoNombre: map['alumnoNombre'] ?? '',
      noControl: map['noControl'] ?? '',
      grupoId: map['grupoId'] ?? '',
      grupoNombre: map['grupoNombre'] ?? '',
      tipo: map['tipo'] ?? '',
      estado: map['estado'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      horaRegistro: map['horaRegistro'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alumnoUid': alumnoUid,
      'alumnoNombre': alumnoNombre,
      'noControl': noControl,
      'grupoId': grupoId,
      'grupoNombre': grupoNombre,
      'tipo': tipo,
      'estado': estado,
      'fecha': Timestamp.fromDate(fecha),
      'horaRegistro': horaRegistro,
    };
  }
}
