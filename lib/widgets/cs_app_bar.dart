import 'package:flutter/material.dart';

class CsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CsAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppBarWaveClipper(),
      child: Container(
        height: preferredSize.height + 40, // Aumentei a altura do AppBar
        color: Colors.green,
        child: AppBar(
          title: Text(title, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100); // Altura maior
}

class AppBarWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // Desce mais a onda
    path.quadraticBezierTo(
      size.width / 4,
      size.height + 10, // Aumentei o ponto para descer mais
      size.width / 2,
      size.height - 30, // Ajustei a curva
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height - 60, // Onda mais profunda
      size.width,
      size.height - 30, // Ajustei o final da curva
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
