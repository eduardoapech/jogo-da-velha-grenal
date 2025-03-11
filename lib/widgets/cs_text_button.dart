import 'package:flutter/material.dart';

class CsTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const CsTextButton({super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16, // Ajuste o tamanho da fonte conforme necessário
          color: Colors.black, // Altere a cor conforme necessário
        ),
      ),
    );
  }
}
