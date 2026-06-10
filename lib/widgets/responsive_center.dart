import 'package:flutter/material.dart';

/// Membungkus konten agar tetap nyaman dibaca di layar lebar (tablet),
/// dengan membatasi lebar maksimum dan menempatkannya di tengah.
/// Di layar ponsel (lebih sempit dari [maxWidth]) tidak berefek apa pun.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Helper untuk skala nilai berdasarkan lebar layar, dengan batas min/max.
/// Berguna untuk padding/font/ukuran ikon agar proporsional di semua
/// ukuran layar Android (ponsel kecil hingga tablet).
double responsiveValue(
  BuildContext context, {
  required double base,
  double min = 0,
  double max = double.infinity,
  double referenceWidth = 390,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final scaled = base * (width / referenceWidth);
  return scaled.clamp(min, max);
}
