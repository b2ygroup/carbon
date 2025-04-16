// lib/screens/splash_screen.dart (Versão MÍNIMA)
import 'dart:async'; import 'package:flutter/material.dart';
import '../main.dart'; // Para AuthWrapper

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); _navigateToNextScreen(); }
  void _navigateToNextScreen() { Timer(const Duration(seconds: 2), () { if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper())); }); }
  @override Widget build(BuildContext context) { return const Scaffold( body: Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.energy_savings_leaf_outlined, size: 80, color: Colors.greenAccent), SizedBox(height: 20), Text("B2Y Carbon", style: TextStyle(fontSize: 24)), SizedBox(height: 30), CircularProgressIndicator() ]) ) ); }
}