// lib/widgets/minimap_placeholder.dart (Placeholder Visual)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import animate

class MinimapPlaceholder extends StatelessWidget {
  final Color baseColor;
  const MinimapPlaceholder({super.key, this.baseColor = Colors.tealAccent}); // Cor base ajustável

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8, // Um pouco mais largo que alto
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
             colors: [ Colors.grey[850]!, Colors.grey[900]!.withOpacity(0.8) ],
             begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: baseColor.withOpacity(0.3))
        ),
        child: Stack( // Stack para ícones sobrepostos
          alignment: Alignment.center,
          children: [
            // Ícone de fundo maior
            Icon(Icons.map_outlined, size: 55, color: baseColor.withOpacity(0.1)),
            // Ícones menores simulando pontos
            Positioned(top: 30, left: 40, child: Icon(Icons.ev_station, size: 14, color: baseColor.withOpacity(0.7))),
            Positioned(bottom: 40, right: 50, child: Icon(Icons.ev_station, size: 14, color: baseColor.withOpacity(0.7))),
            Positioned(bottom: 60, left: 80, child: Icon(Icons.ev_station, size: 14, color: baseColor.withOpacity(0.7))),
            Positioned(top: 50, right: 90, child: Icon(Icons.ev_station, size: 14, color: baseColor.withOpacity(0.7))),
            // Texto placeholder
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5)
               ),
               child: Text( 'Mapa Eletropostos (Em Breve)',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[300]),
               ),
            ),
          ],
        ),
      ),
    ).animate().fade(); // Animação simples de fade
  }
}