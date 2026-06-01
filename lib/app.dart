import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/alumno/alumno_home_screen.dart';
import 'presentation/screens/padre/padre_home_screen.dart';
import 'presentation/screens/admin/admin_home_screen.dart';
import 'data/models/user_model.dart';

class CetiSafeApp extends StatelessWidget {
  const CetiSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const _AuthWrapper(),
        );
      },
    );
  }
}

// ── Wrapper que detecta si hay sesión activa ────────────────
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // No hay sesión activa
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Hay sesión activa — obtener datos del usuario
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(AppConstants.colUsuarios)
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const LoginScreen();
            }

            final user = UserModel.fromMap(
                userSnap.data!.data() as Map<String, dynamic>);

            // Navegar según rol
            switch (user.rol) {
              case AppConstants.rolAlumno:
                return AlumnoHomeScreen(user: user);
              case AppConstants.rolPadre:
                return PadreHomeScreen(user: user);
              case AppConstants.rolAdmin:
                return AdminHomeScreen(user: user);
              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

// ── Theme Provider ──────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
