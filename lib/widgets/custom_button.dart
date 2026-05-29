import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 50,
    this.borderRadius = 10,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 8)],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: fullWidth
            ? Size(double.infinity, height)
            : Size(height, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
        padding: padding,
      ),
      child: buttonChild,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
