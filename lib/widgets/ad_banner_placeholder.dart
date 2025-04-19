// lib/widgets/ad_banner_placeholder.dart (Simulando Carrossel)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdBannerPlaceholder extends StatefulWidget {
  final double height;
  const AdBannerPlaceholder({super.key, this.height = 50.0});

  @override
  State<AdBannerPlaceholder> createState() => _AdBannerPlaceholderState();
}

class _AdBannerPlaceholderState extends State<AdBannerPlaceholder> {
  int _currentIndex = 0;
  Timer? _timer;
  final List<String> _adTexts = [
    "Anúncio: Economize com Carro Elétrico!",
    "Anúncio: Seguro Auto com Desconto para EV.",
    "Anúncio: Instale seu Carregador Residencial.",
    "Anúncio: Viaje e Ganhe Créditos de Carbono!",
  ];

  @override
  void initState() {
    super.initState();
    // Inicia timer para trocar anúncio a cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _adTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      color: Colors.grey[850], // Cor de fundo um pouco diferente
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: AnimatedSwitcher( // Anima a transição entre textos
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
            // Ou: return SlideTransition(position: Tween<Offset>(begin: Offset(0.0, 0.5), end: Offset.zero).animate(animation), child: child);
          },
          child: Text(
            _adTexts[_currentIndex],
            key: ValueKey<int>(_currentIndex), // Chave para o AnimatedSwitcher funcionar
            style: GoogleFonts.poppins(
              textStyle: TextStyle( color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic )
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}