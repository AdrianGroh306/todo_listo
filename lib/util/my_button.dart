import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double borderRadius;

  MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
        ),
        child: MaterialButton(
          elevation: 0,
          onPressed: onPressed,
          textColor: textColor,
          child: Text(text),
          color: Colors.transparent,
        ),
      ),
    );





  }
}
