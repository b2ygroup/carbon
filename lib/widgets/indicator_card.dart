// lib/widgets/indicator_card.dart (Ajuste Final Overflow Interno)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const IndicatorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBackgroundColor = theme.cardTheme.color ?? Colors.grey[850]!;
    final cardElevation = theme.cardTheme.elevation ?? 1.5;
    final textColorOnCard = theme.textTheme.bodyMedium?.color ?? Colors.white70;

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.all(10), // Padding pequeno
      decoration: BoxDecoration(
        gradient: LinearGradient( colors: [ cardBackgroundColor, Color.lerp(cardBackgroundColor, color, 0.1)! ], begin: Alignment.topLeft, end: Alignment.bottomRight ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
        boxShadow: cardElevation > 0 ? [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)) ] : null
      ),
      child: Column( // Coluna principal do Card
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, // Alinha no topo
        // ***** CORREÇÃO: Garante altura mínima do conteúdo *****
        mainAxisSize: MainAxisSize.min,
        children: [
          Row( // Ícone e Título
            children: [
              Icon(icon, size: 16, color: color), // Ícone pequeno
              const SizedBox(width: 6),
              Expanded( // Título pode quebrar se for muito longo (raro)
                child: Text( title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins( textStyle: theme.textTheme.labelSmall?.copyWith(fontSize: 10, // Fonte menor
                      color: textColorOnCard.withOpacity(0.8), letterSpacing: 0.5, fontWeight: FontWeight.w500))),
              ),
            ],
          ),
          // ***** CORREÇÃO: Espaçamento mínimo entre título e valor *****
          const SizedBox(height: 4), // Espaço mínimo
          // Valor (sem Padding extra desnecessário)
          Text( value, maxLines: 1, overflow: TextOverflow.ellipsis, // Ellipsis se for muito grande
            style: GoogleFonts.rajdhani( textStyle: theme.textTheme.headlineSmall?.copyWith( fontSize: 18, // Fonte valor menor
                fontWeight: FontWeight.w600, color: color, letterSpacing: 0.3)),
          ),
        ],
      ), // ***** FIM DA CORREÇÃO *****
    ).animate().fadeIn(duration: 200.ms); // Animação rápida
  }
}