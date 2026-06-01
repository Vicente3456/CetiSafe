import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol; // alumno, padre, admin
  final String? fotoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
    this.fotoUrl,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      rol: map['rol'] ?? '',
      fotoUrl: map['fotoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'rol': rol,
      'fotoUrl': fotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? nombre,
    String? apellido,
    String? correo,
    String? rol,
    String? fotoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
