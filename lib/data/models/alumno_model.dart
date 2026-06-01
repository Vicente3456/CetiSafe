import 'package:cloud_firestore/cloud_firestore.dart';

class AlumnoModel {
  final String uid;
  final String noControl;
  final String nombre;
  final String apellido;
  final String correo;
  final String grupoId;
  final String turno;
  final String? fotoUrl;
  final List<String> padresUid;
  final DateTime createdAt;

  AlumnoModel({
    required this.uid,
    required this.noControl,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.grupoId,
    required this.turno,
    this.fotoUrl,
    required this.padresUid,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory AlumnoModel.fromMap(Map<String, dynamic> map) {
    return AlumnoModel(
      uid: map['uid'] ?? '',
      noControl: map['noControl'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      grupoId: map['grupoId'] ?? '',
      turno: map['turno'] ?? '',
      fotoUrl: map['fotoUrl'],
      padresUid: List<String>.from(map['padresUid'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'noControl': noControl,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'grupoId': grupoId,
      'turno': turno,
      'fotoUrl': fotoUrl,
      'padresUid': padresUid,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AlumnoModel copyWith({
    String? uid,
    String? noControl,
    String? nombre,
    String? apellido,
    String? correo,
    String? grupoId,
    String? turno,
    String? fotoUrl,
    List<String>? padresUid,
    DateTime? createdAt,
  }) {
    return AlumnoModel(
      uid: uid ?? this.uid,
      noControl: noControl ?? this.noControl,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      grupoId: grupoId ?? this.grupoId,
      turno: turno ?? this.turno,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      padresUid: padresUid ?? this.padresUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
