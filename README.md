# CetiSafe 🛡️

Aplicación móvil de control de asistencia escolar para el CETIS 131.

## Descripción
CetiSafe es una app desarrollada en Flutter que permite registrar 
la asistencia de alumnos mediante códigos QR y notificar 
automáticamente a los padres de familia en tiempo real.

## Tecnologías utilizadas
- Flutter / Dart
- Firebase Authentication
- Cloud Firestore
- Flutter Local Notifications
- Mobile Scanner (QR)
- PDF / Printing

## Requisitos previos
- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio o VS Code
- Cuenta de Firebase

## Instalación
1. Clonar el repositorio:
   git clone https://github.com/TU_USUARIO/CetiSafe.git

2. Entrar a la carpeta:
   cd CetiSafe

3. Instalar dependencias:
   flutter pub get

4. Configurar Firebase:
   flutterfire configure

5. Ejecutar la app:
   flutter run

## Generar APK
   flutter build apk --release

## Estructura del proyecto
lib/
├── core/
│   ├── constants/    # Constantes de la app
│   ├── theme/        # Colores y temas
│   └── utils/        # Validadores
├── data/
│   ├── models/       # Modelos de datos
│   └── services/     # Servicios Firebase
└── presentation/
    ├── screens/      # Pantallas
    │   ├── admin/    # Pantallas del admin
    │   ├── alumno/   # Pantallas del alumno
    │   ├── auth/     # Login y registro
    │   └── padre/    # Pantallas del padre
    └── widgets/      # Widgets reutilizables

## Roles de usuario
- **Alumno:** Escanea QR, ve historial, exporta PDF
- **Padre:** Recibe notificaciones, ve historial del hijo
- **Admin:** Gestiona grupos, genera QR, ve estadísticas

## Credenciales de prueba
- Admin: admin@cetis131.edu.mx

## Institución
CETIS 131 — Centro de Estudios Tecnológicos 
Industrial y de Servicios No. 131
