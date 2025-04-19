// lib/widgets/indicator_card.dart (Design Futurista)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color; // Cor de destaque principal

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
    // Cores baseadas no tema escuro, com ajustes
    final cardBgColor = Colors.grey[900]!.withOpacity(0.5); // Fundo semi-transparente
    final borderColor = color.withOpacity(0.6);
    final iconBgColor = color.withOpacity(0.15);
    final primaryTextColor = Colors.white.withOpacity(0.9);
    final secondaryTextColor = Colors.white.withOpacity(0.6);

    return Container(
      constraints: const BoxConstraints(minHeight: 80), // Garante altura mínima
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16), // Mais arredondado
        border: Border.all(color: borderColor, width: 1),
        // Sombra interna sutil para profundidade
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, spreadRadius: -3), // Sombra interna escura
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2)), // Brilho externo
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Padding interno
        child: Row( // Layout horizontal: Ícone | Título/Valor
          children: [
            // Ícone com fundo
            CircleAvatar(
              radius: 20,
              backgroundColor: iconBgColor,
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            // Coluna para Título e Valor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.orbitron( // Fonte Tech
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        color: secondaryTextColor,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w500,
                        fontSize: 10, // Título menor
                      )
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.rajdhani( // Fonte Tech/Display
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor, // Valor mais claro
                        letterSpacing: 0.5,
                        fontSize: 19, // Valor um pouco maior
                      )
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms).slideX(begin: 0.1, curve: Curves.easeOutCubic); // Animação
  }
}