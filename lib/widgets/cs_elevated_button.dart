import 'package:flutter/material.dart';

class CsElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CsElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Cor de fundo
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 40,
        ), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Borda arredondada
        ),
        elevation: 5, // Elevação do botão (sombra)
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 18, // Tamanho da fonte
        ),
      ),
    );
  }
}
