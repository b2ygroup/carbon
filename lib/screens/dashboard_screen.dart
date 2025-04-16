// lib/screens/dashboard_screen.dart (Versão MÍNIMA)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userEmail = userProvider.userEmail ?? '-';

    return Scaffold(
      appBar: AppBar( title: const Text('Dashboard (Base)'), actions: [
          IconButton( icon: const Icon(Icons.logout), tooltip: 'Sair',
            onPressed: () async {
              Provider.of<UserProvider>(context, listen: false).clearUserDataOnLogout();
              await FirebaseAuth.instance.signOut();
            }, ) ], ),
      body: Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Login Bem-Sucedido!', style: TextStyle(fontSize: 24)), const SizedBox(height: 20),
            Text('Email: $userEmail'), const SizedBox(height: 40),
            const Text('(Dashboard funcional virá aqui)'),
          ], ), ), );
  }
}