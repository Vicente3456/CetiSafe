class Validators {
  // Nombre
  static String? nombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio.';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    return null;
  }

  // Apellido
  static String? apellido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El apellido es obligatorio.';
    }
    if (value.trim().length < 2) {
      return 'El apellido debe tener al menos 2 caracteres.';
    }
    return null;
  }

  // Correo
  static String? correo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio.';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  // Contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // Confirmar contraseña
  static String? confirmarPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  // No. Control
  static String? noControl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El No. Control es obligatorio.';
    }
    if (value.trim().length < 9) {
      return 'El No. Control debe tener al menos 9 caracteres.';
    }
    return null;
  }

  // Campo genérico requerido
  static String? requerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return '$campo es obligatorio.';
    }
    return null;
  }
}
