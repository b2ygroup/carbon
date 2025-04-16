// lib/screens/auth_screen.dart (Navegando para Onboarding)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importa a tela de Onboarding para iniciar o fluxo de registro
import 'onboarding_screen.dart'; // Garanta que o arquivo acima exista

// Se quiser usar a UI mais elaborada depois, importe estes e adicione ao pubspec
// import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  void _submitLoginForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); if (!isValid) return;
    setState(() { _isLoading = true; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro desconhecido';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
         errorMessage = 'Email ou senha inválidos.';
      } else { errorMessage = e.message ?? errorMessage; }
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent));
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"))); }
    if(mounted) setState(() { _isLoading = false; });
  }

  // --- CORREÇÃO: Função para NAVEGAR para o fluxo de registro ---
  void _goToRegisterFlow() {
    print("Navegando para Onboarding...");
    // Usa push normal para permitir voltar ao Login se desistir
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => const OnboardingScreen(), // Chama a tela de Onboarding
    ));
  }
  // --- FIM DA CORREÇÃO ---

  @override
  Widget build(BuildContext context) {
    // Mantendo a UI MÍNIMA por enquanto
    return Scaffold(
      appBar: AppBar(title: const Text("Login B2Y Carbon")),
      body: Center( child: SingleChildScrollView( padding: const EdgeInsets.all(20),
        child: Form( key: _formKey, child: Column( mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_person_rounded, size: 70, color: Colors.greenAccent), // Ícone simples
              const SizedBox(height: 20),
              TextFormField( controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, validator: (v)=>(v==null || v.isEmpty)?'Obrigatório':null), const SizedBox(height: 10),
              TextFormField( controller: _passwordController, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()), obscureText: true, validator: (v)=>(v==null || v.length<6)?'Mínimo 6 chars':null), const SizedBox(height: 30),
              _isLoading ? const CircularProgressIndicator()
              // Botão Entrar continua chamando _submitLoginForm
              : ElevatedButton( onPressed: _submitLoginForm, style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)), child: const Text('Entrar') ),
              const SizedBox(height: 10),
              // Botão Registre-se agora chama _goToRegisterFlow CORRIGIDO
              TextButton( onPressed: _goToRegisterFlow, child: const Text('Não tem conta? Registre-se') )
            ], ), ), ), ), );
  }
}