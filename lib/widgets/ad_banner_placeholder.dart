// lib/widgets/ad_banner_placeholder.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdBannerPlaceholder extends StatelessWidget {
  final double height;
  const AdBannerPlaceholder({super.key, this.height = 50.0}); // Altura padrão de banner

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity, // Ocupa toda a largura
      color: Colors.grey[800], // Cor de fundo distinta
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Text(
          'Espaço Reservado para Anúncio (Banner)',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            )
          ),
        ),
      ),
    );
  }
}