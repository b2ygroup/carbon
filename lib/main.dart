// lib/main.dart (MÍNIMO - CORRIGIDO com nome pacote 'carbon')
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import correto

// ***** CORREÇÃO: Usando 'carbon' como nome do pacote *****
import 'package:carbon/firebase_options.dart';
import 'package:carbon/screens/splash_screen.dart';
import 'package:carbon/screens/auth_screen.dart';
import 'package:carbon/screens/dashboard_screen.dart';
import 'package:carbon/providers/user_provider.dart';
// *********************************************************

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // DefaultFirebaseOptions vem de firebase_options.dart importado acima
    await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform );
    runApp(const MyApp());
  } catch (e) { print("ERRO FATAL INIT: $e"); runApp(ErrorApp(e.toString())); }
}

class MyApp extends StatelessWidget { const MyApp({super.key});
  @override Widget build(BuildContext context) {
    // UserProvider vem de user_provider.dart importado
    return MultiProvider( providers: [ ChangeNotifierProvider(create: (_) => UserProvider()) ],
      child: MaterialApp( title: 'B2Y Carbon (Base)',
        theme: ThemeData( brightness: Brightness.dark, primarySwatch: Colors.green, useMaterial3: true, inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
        // Global...Localizations vem de flutter_localizations importado
        localizationsDelegates: const [ GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate ],
        supportedLocales: const [ Locale('pt', 'BR') ], locale: const Locale('pt', 'BR'),
        // SplashScreen vem de splash_screen.dart importado
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false ) ); }
}

// AuthWrapper (AuthScreen e DashboardScreen devem ser encontrados agora)
class AuthWrapper extends StatelessWidget { const AuthWrapper({super.key});
  @override Widget build(BuildContext context) { return StreamBuilder<User?>( stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError) return Scaffold(body: Center(child: Text("Erro AuthWrapper: ${snapshot.error}")));
        // UserProvider importado
        if (snapshot.hasData) { WidgetsBinding.instance.addPostFrameCallback((_) { if (ctx.mounted) Provider.of<UserProvider>(ctx, listen: false).loadUserData(snapshot.data!.uid); }); return const DashboardScreen(); } // DashboardScreen importada
        else { WidgetsBinding.instance.addPostFrameCallback((_) { if (ctx.mounted) Provider.of<UserProvider>(ctx, listen: false).clearUserDataOnLogout(); }); return const AuthScreen(); } // AuthScreen importada
      } ); }
}
class ErrorApp extends StatelessWidget { final String error; const ErrorApp(this.error, {super.key}); @override Widget build(BuildContext context) => MaterialApp(home: Scaffold(body: Center(child: Text("Erro:\n$error", style: const TextStyle(color: Colors.red))))); }