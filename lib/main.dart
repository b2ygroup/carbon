import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Exemplo com Provider
import 'screens/auth_screen.dart'; // Supondo uma tela de autenticação inicial
import 'screens/dashboard_screen.dart';
import 'providers/user_provider.dart'; // Exemplo de provider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usar MultiProvider para gerenciar o estado globalmente
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Adicionar outros providers (VehicleProvider, TripProvider, etc.)
      ],
      child: MaterialApp(
        title: 'App Carbono Zero',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Lógica inicial: Verifica se está logado, senão vai pra AuthScreen
        home: Consumer<UserProvider>(
          builder: (ctx, userProvider, _) {
            // Exemplo simplificado: Precisa de lógica de autenticação real
            return userProvider.isLoggedIn ? DashboardScreen() : AuthScreen();
          },
        ),
        routes: {
          // Definir rotas para outras telas se necessário
          // RegistrationScreen.routeName: (ctx) => RegistrationScreen(),
        },
      ),
    );
  }
}
