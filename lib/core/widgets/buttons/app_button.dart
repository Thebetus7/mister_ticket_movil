import 'package:flutter/material.dart';

/// Botón primario reutilizable de la app.
/// Soporta: estado de carga, variante outlined, icono opcional, ancho personalizable.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(text),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: buttonChild)
        : ElevatedButton(onPressed: isLoading ? null : onPressed, child: buttonChild);

    return width != null ? SizedBox(width: width, child: button) : button;
  }
}
