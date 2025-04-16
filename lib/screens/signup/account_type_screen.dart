// lib/screens/signup/account_type_screen.dart (Navegação PJ Corrigida)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:carbon/screens/signup/personal_data_screen.dart'; // CONFIRME NOME PACOTE
// --- CORREÇÃO: Importa a tela de dados da empresa ---
import 'package:carbon/screens/signup/company_data_screen.dart'; // CONFIRME NOME PACOTE

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tipo de Conta', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600)),
        leading: IconButton( icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop(), ), // Botão Voltar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text( 'Para começar, selecione seu tipo de conta:', textAlign: TextAlign.center, style: GoogleFonts.poppins(textStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600))
              ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
              const SizedBox(height: 50),

              // Botão Pessoa Física (Navega para PersonalDataScreen)
              ElevatedButton.icon( icon: const Icon(Icons.person_outline_rounded, size: 32), label: Padding( padding: const EdgeInsets.symmetric(vertical: 18.0), child: Text('Uso Pessoal\n(Pessoa Física)', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, height: 1.3))),
                style: ElevatedButton.styleFrom( backgroundColor: colorScheme.primary.withOpacity(0.15), foregroundColor: colorScheme.primary, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15), side: BorderSide(color: colorScheme.primary, width: 1.5)), elevation: 0),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalDataScreen())),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.5),
              const SizedBox(height: 25),

              // Botão Pessoa Jurídica (Navega para CompanyDataScreen)
              ElevatedButton.icon( icon: const Icon(Icons.business_center_outlined, size: 32), label: Padding( padding: const EdgeInsets.symmetric(vertical: 18.0), child: Text('Uso Empresarial\n(Pessoa Jurídica)', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, height: 1.3))),
                 style: ElevatedButton.styleFrom( backgroundColor: colorScheme.secondary.withOpacity(0.15), foregroundColor: colorScheme.secondary, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15), side: BorderSide(color: colorScheme.secondary, width: 1.5)), elevation: 0),
                 // --- CORREÇÃO: Navega para CompanyDataScreen ---
                 onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyDataScreen()));
                 },
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}