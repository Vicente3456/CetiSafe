import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/alumno_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── REGISTRO ────────────────────────────────────────────
  Future<UserModel?> registrar({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required String rol,
    String? noControl,
    String? grupoId,
    String? turno,
  }) async {
    // Bloquear registro como admin con correo no autorizado
    if (rol == AppConstants.rolAdmin && correo != AppConstants.adminEmail) {
      throw Exception('No tienes permiso para registrarte como administrador.');
    }

    // Bloquear que alguien use el correo admin en otro rol
    if (correo == AppConstants.adminEmail && rol != AppConstants.rolAdmin) {
      throw Exception('Este correo está reservado para el administrador.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );

    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      rol: rol,
      createdAt: DateTime.now(),
    );

    // Guardar en colección usuarios
    await _db.collection(AppConstants.colUsuarios).doc(uid).set(user.toMap());

    // Si es alumno, guardar también en colección alumnos
    if (rol == AppConstants.rolAlumno) {
      final alumno = AlumnoModel(
        uid: uid,
        noControl: noControl ?? '',
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        grupoId: grupoId ?? '',
        turno: turno ?? '',
        padresUid: [],
        createdAt: DateTime.now(),
      );
      await _db
          .collection(AppConstants.colAlumnos)
          .doc(uid)
          .set(alumno.toMap());
    }

    return user;
  }

  // ── LOGIN ────────────────────────────────────────────────
  Future<UserModel?> login({
    required String correo,
    required String password,
    required String rolSeleccionado,
  }) async {
    // Validar acceso admin
    if (rolSeleccionado == AppConstants.rolAdmin &&
        correo != AppConstants.adminEmail) {
      throw Exception(
          'Solo el administrador puede iniciar sesión con este rol.');
    }

    if (correo == AppConstants.adminEmail &&
        rolSeleccionado != AppConstants.rolAdmin) {
      throw Exception(
          'Este correo solo puede iniciar sesión como administrador.');
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _db.collection(AppConstants.colUsuarios).doc(uid).get();

    if (!doc.exists) throw Exception('Usuario no encontrado.');

    final user = UserModel.fromMap(doc.data()!);

    // Verificar que el rol coincida
    if (user.rol != rolSeleccionado) {
      await _auth.signOut();
      throw Exception('El rol seleccionado no coincide con tu cuenta.');
    }

    return user;
  }

  // ── LOGOUT ───────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── OBTENER USUARIO ACTUAL ───────────────────────────────
  Future<UserModel?> getUserActual() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection(AppConstants.colUsuarios).doc(uid).get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // ── RECUPERAR CONTRASEÑA ─────────────────────────────────
  Future<void> recuperarPassword(String correo) async {
    await _auth.sendPasswordResetEmail(email: correo);
  }
}
