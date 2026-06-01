class AppConstants {
  // App
  static const String appName = 'CetiSafe';
  static const String adminEmail = 'admin@cetis131.edu.mx';
  static const String institucion = 'CETIS 131';

  // Rutas
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeAlumnoHome = '/alumno/home';
  static const String routePadreHome = '/padre/home';
  static const String routeAdminHome = '/admin/home';

  // Roles
  static const String rolAlumno = 'alumno';
  static const String rolPadre = 'padre';
  static const String rolAdmin = 'admin';

  // Asistencia
  static const String estadoAsistio = 'asistio';
  static const String estadoFalta = 'falta';
  static const String estadoRetardo = 'retardo';

  // Firestore colecciones
  static const String colUsuarios = 'usuarios';
  static const String colAlumnos = 'alumnos';
  static const String colGrupos = 'grupos';
  static const String colAsistencias = 'asistencias';
  static const String colAvisos = 'avisos';
}
