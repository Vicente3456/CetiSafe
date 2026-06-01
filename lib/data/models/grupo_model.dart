import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo para el horario de un día específico
class HorarioDia {
  final String dia; // lunes, martes, miercoles, jueves, viernes
  final String horaEntrada; // formato HH:mm ej: "07:00"
  final String horaSalida; // formato HH:mm ej: "13:30"

  HorarioDia({
    required this.dia,
    required this.horaEntrada,
    required this.horaSalida,
  });

  factory HorarioDia.fromMap(Map<String, dynamic> map) {
    return HorarioDia(
      dia: map['dia'] ?? '',
      horaEntrada: map['horaEntrada'] ?? '00:00',
      horaSalida: map['horaSalida'] ?? '00:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
    };
  }

  HorarioDia copyWith({
    String? dia,
    String? horaEntrada,
    String? horaSalida,
  }) {
    return HorarioDia(
      dia: dia ?? this.dia,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
    );
  }
}

// Modelo principal del grupo
class GrupoModel {
  final String id;
  final String nombre; // ej: "6°A"
  final String semestre; // ej: "6"
  final String turno; // matutino, vespertino
  final List<HorarioDia> horarios; // horario por cada día
  final DateTime createdAt;

  GrupoModel({
    required this.id,
    required this.nombre,
    required this.semestre,
    required this.turno,
    required this.horarios,
    required this.createdAt,
  });

  // Obtener horario de un día específico
  HorarioDia? getHorarioDia(String dia) {
    try {
      return horarios.firstWhere(
        (h) => h.dia.toLowerCase() == dia.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // Días de la semana con horario registrado
  static const List<String> diasSemana = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
  ];

  factory GrupoModel.fromMap(Map<String, dynamic> map) {
    return GrupoModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      semestre: map['semestre'] ?? '',
      turno: map['turno'] ?? '',
      horarios: (map['horarios'] as List<dynamic>? ?? [])
          .map((h) => HorarioDia.fromMap(h as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'semestre': semestre,
      'turno': turno,
      'horarios': horarios.map((h) => h.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GrupoModel copyWith({
    String? id,
    String? nombre,
    String? semestre,
    String? turno,
    List<HorarioDia>? horarios,
    DateTime? createdAt,
  }) {
    return GrupoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      semestre: semestre ?? this.semestre,
      turno: turno ?? this.turno,
      horarios: horarios ?? this.horarios,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
