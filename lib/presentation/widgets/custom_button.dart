import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icono;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icono,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = isDark ? AppColors.vinoClaro : AppColors.vino;
        textColor = AppColors.blanco;
        break;
      case ButtonVariant.secondary:
        bgColor = isDark ? AppColors.grisMedio : AppColors.grisClaro;
        textColor = isDark ? AppColors.textoClaro : AppColors.textoOscuro;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.vinoClaro : AppColors.vino;
        border = Border.all(
          color: isDark ? AppColors.vinoClaro : AppColors.vino,
          width: 1.5,
        );
        break;
      case ButtonVariant.danger:
        bgColor = AppColors.error;
        textColor = AppColors.blanco;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: onPressed == null
                ? AppColors.textoGris.withValues(alpha: 0.3)
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: variant == ButtonVariant.primary && onPressed != null
                ? [
                    BoxShadow(
                      color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icono != null) ...[
                        Icon(icono, color: textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        texto,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onPressed == null
                              ? AppColors.textoGris
                              : textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
