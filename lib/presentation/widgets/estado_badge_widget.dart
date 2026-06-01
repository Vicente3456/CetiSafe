import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;
  final bool small;

  const EstadoBadge({
    super.key,
    required this.estado,
    this.small = false,
  });

  Color _getColor() {
    switch (estado) {
      case AppConstants.estadoAsistio:
        return AppColors.asistio;
      case AppConstants.estadoRetardo:
        return AppColors.retardo;
      case AppConstants.estadoFalta:
        return AppColors.falta;
      default:
        return AppColors.textoGris;
    }
  }

  String _getLabel() {
    switch (estado) {
      case AppConstants.estadoAsistio:
        return 'Asistió';
      case AppConstants.estadoRetardo:
        return 'Retardo';
      case AppConstants.estadoFalta:
        return 'Falta';
      default:
        return estado;
    }
  }

  IconData _getIcon() {
    switch (estado) {
      case AppConstants.estadoAsistio:
        return Icons.check_circle_outline;
      case AppConstants.estadoRetardo:
        return Icons.access_time_outlined;
      case AppConstants.estadoFalta:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            color: color,
            size: small ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: GoogleFonts.montserrat(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
