import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdBannerPlaceholder extends StatefulWidget {
  final double height;
  const AdBannerPlaceholder({super.key, this.height = 60.0});

  @override
  State<AdBannerPlaceholder> createState() => _AdBannerPlaceholderState();
}

class _AdBannerPlaceholderState extends State<AdBannerPlaceholder> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Widget> _adContents = [
    _buildAd(
      title: "Faça o test drive no novo BYD",
      subtitle: "Recarregue grátis em nossos eletropostos",
      icon: Icons.electric_car,
      gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
    ),
    _buildAd(
      title: "Compense Carbono e Ganhe Recompensas!",
      subtitle: "A cada km verde, créditos na carteira",
      icon: Icons.eco_outlined,
      gradient: LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
    ),
    _buildAd(
      title: "Seguro Automotivo Verde? Confira!",
      subtitle: "Proteção com impacto reduzido",
      icon: Icons.shield_outlined,
      gradient: LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent]),
    ),
    _buildAd(
      title: "Postos parceiros com desconto!",
      subtitle: "Economize ao rodar limpo",
      icon: Icons.local_gas_station,
      gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]),
    ),
  ];

  static Widget _buildAd({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 1000.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {}, // Aqui você pode simular uma ação futura
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
            child: const Text("Saiba mais", style: TextStyle(fontSize: 10)),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_adContents.isNotEmpty) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _adContents.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 900),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Container(
          key: ValueKey(_currentIndex),
          child: _adContents[_currentIndex],
        ),
      ),
    );
  }
}
