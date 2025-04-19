// lib/screens/signup/personal_data_screen.dart (Revisado e Completo)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:carbon/screens/signup/vehicle_registration_signup_screen.dart'; // CONFIRME NOME PACOTE
// Para AuthWrapper - CONFIRME NOME PACOTE

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key}); // Key Adicionada

  // createState CORRETO
  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>(); bool _isLoading = false;
  final _nameController = TextEditingController(); final _cpfController = TextEditingController();
  final _dobController = TextEditingController(); final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); DateTime? _selectedDate;
  final _cpfFormatter = MaskTextInputFormatter(mask:'###.###.###-##', filter:{"#":RegExp(r'[0-9]')});
  final _phoneFormatter = MaskTextInputFormatter(mask:'(##) #####-####', filter:{"#":RegExp(r'[0-9]')});
  final _dobFormatter = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  // Cores (Estilo PJ)
  static const Color primaryColor = Color(0xFF00BFFF); static const Color secondaryColor = Color(0xFF00FFFF);
  static final Color errorColor = Colors.redAccent[100]!; static final Color inputBorderColor = Colors.grey[800]!;
  static final Color labelColor = Colors.grey[400]!; static const Color textColor = Colors.white;

  @override void dispose() { /* ... dispose controllers ... */ super.dispose(); }

  Future<void> _selectDate(BuildContext context) async {
    print("[_selectDate] Iniciando..."); FocusScope.of(context).unfocus(); try { print("[_selectDate] Chamando showDatePicker...");
      final DateTime? picked = await showDatePicker( context: context, initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365*18)), firstDate: DateTime(1920), lastDate: DateTime.now());
      print("[_selectDate] Retornou: $picked"); if (picked != null && picked != _selectedDate) { if (mounted) setState(() { _selectedDate = picked; _dobController.text = DateFormat('dd/MM/yyyy').format(picked); print("[_selectDate] Estado Atualizado: ${_dobController.text}"); }); }
    } catch (e, s) { print("[_selectDate] ERRO: $e\n$s"); }
  }

  String? _validateConfirmPassword(String? value) { if (value == null || value.isEmpty) return 'Confirme'; if (value != _passwordController.text) return 'Senhas não coincidem'; return null; }

  void _submitSignupForm() async {
    print("--- Iniciando _submitSignupForm (PF) ---"); final isValid = _formKey.currentState?.validate() ?? false; print("Form válido: $isValid"); FocusScope.of(context).unfocus(); if (!isValid) return; _formKey.currentState?.save(); setState(() => _isLoading = true); await Future.delayed(500.ms); User? createdUser;
    try { print("Passo 1: Criando Auth User..."); final cr = await FirebaseAuth.instance.createUserWithEmailAndPassword( email: _emailController.text.trim(), password: _passwordController.text.trim()); createdUser=cr.user; if(createdUser==null) throw Exception('Falha Auth'); final uid=createdUser.uid; print("Auth criado: $uid"); print("Passo 2: Preparando Firestore..."); final Map<String, dynamic> userData = {'uid':uid,'email':_emailController.text.trim(),'fullName':_nameController.text.trim(),'cpf':_cpfFormatter.getUnmaskedText(),'dateOfBirth':_selectedDate!=null?Timestamp.fromDate(_selectedDate!):null,'phone':_phoneFormatter.getUnmaskedText(),'accountType':'PF','createdAt':FieldValue.serverTimestamp()}; print("Dados User: $userData"); print("Passo 3: Salvando Firestore..."); await FirebaseFirestore.instance.collection('users').doc(uid).set(userData); print("Salvo Firestore!");
      if (mounted) { print("Passo 4: Navegando p/ Veículo..."); Navigator.pushReplacement(context, MaterialPageRoute( builder: (_) => const VehicleRegistrationScreenForSignup())); } // Navegação CORRETA
    } on FirebaseAuthException catch (err) { print("!!! ERRO AUTH (PF): ${err.code} !!!"); String msg; switch(err.code){ case 'email-already-in-use': msg='Email já cadastrado.'; break; case 'weak-password': msg='Senha fraca.';break; default: msg=err.message ?? 'Erro Auth.'; } if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: errorColor));
    } catch (err, s) { print("!!! ERRO GERAL (PF): $err\n$s"); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro inesperado.'))); }
    finally { print("--- Finalizando _submitSignupForm (PF) ---"); if (mounted) { setState(() { _isLoading = false; }); } }
  }

  // ***** BUILD COMPLETO E VERIFICADO *****
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); const currentFocusColor = secondaryColor; final currentInputBorderColor = inputBorderColor;
    final currentLabelColor = labelColor; const currentPrimaryColor = primaryColor; final currentErrorColor = errorColor; const currentIconColor = primaryColor;

    return Scaffold(
      appBar: AppBar( title: Text('Cadastro Pessoal', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Form( key: _formKey,
          child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Text('Conte-nos sobre você', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              TextFormField(controller: _nameController, decoration: _inputDecoration(labelText: 'Nome Completo', prefixIcon: Icons.person_outline), textCapitalization: TextCapitalization.words, validator: (v)=>(v==null||v.isEmpty)?'Obrigatório':null ), const SizedBox(height: 15),
              TextFormField(controller: _cpfController, decoration: _inputDecoration(labelText: 'CPF', prefixIcon: Icons.badge_outlined), keyboardType: TextInputType.number, inputFormatters: [_cpfFormatter], validator: (v){if(_cpfFormatter.getUnmaskedText().length!=11)return 'Inválido'; return null;}), const SizedBox(height: 15),
              TextFormField( controller: _dobController, readOnly: false, decoration: _inputDecoration(labelText: 'Data Nasc (DD/MM/AAAA)', prefixIcon: Icons.calendar_today_outlined), keyboardType: TextInputType.datetime, inputFormatters: [_dobFormatter], onTap: ()=>_selectDate(context), validator: (v){if(v==null||v.isEmpty){ if (_selectedDate==null) return'Obrigatória';} else {if(v.length!=10)return'Formato'; try{DateFormat('dd/MM/yyyy').parseStrict(v);}catch(e){return'Inválida';}} return null;} ), const SizedBox(height: 15),
              TextFormField(controller: _phoneController, decoration: _inputDecoration(labelText: 'Telefone/Celular', prefixIcon: Icons.phone_android_outlined), keyboardType: TextInputType.phone, inputFormatters: [_phoneFormatter], validator: (v){if(_phoneFormatter.getUnmaskedText().length<10)return 'Inválido'; return null;}),
              const SizedBox(height: 35), Text('Crie seu acesso', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              TextFormField(controller: _emailController, decoration: _inputDecoration(labelText: 'Email', prefixIcon: Icons.alternate_email), keyboardType: TextInputType.emailAddress, validator: (v)=>(v==null||v.isEmpty||!v.contains('@'))?'Inválido':null ), const SizedBox(height: 15),
              TextFormField(controller: _passwordController, decoration: _inputDecoration(labelText: 'Senha', prefixIcon: Icons.lock_outline), obscureText: true, validator: (v)=>(v==null||v.length<6)?'Min 6 chars':null ), const SizedBox(height: 15),
              TextFormField(controller: _confirmPasswordController, decoration: _inputDecoration(labelText: 'Confirmar Senha', prefixIcon: Icons.lock_reset_outlined), obscureText: true, validator: _validateConfirmPassword ), const SizedBox(height: 40),
              _isLoading ? const Center(child: SpinKitFadingCube(color: currentPrimaryColor, size: 40.0)) : ElevatedButton.icon( icon: const Icon(Icons.app_registration_rounded), label: const Text('Criar Conta e Avançar'), style: ElevatedButton.styleFrom(backgroundColor: currentPrimaryColor, foregroundColor: Colors.white), onPressed: _submitSignupForm ), const SizedBox(height: 20),
            ], ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    ); // Fim Scaffold
  } // Fim build

  // ***** _inputDecoration COMPLETO E CORRIGIDO *****
  InputDecoration _inputDecoration({ required String labelText, required IconData prefixIcon }) {
     final currentLabelColor = labelColor; const currentIconColor = primaryColor; final currentBorderColor = inputBorderColor;
     const currentFocusColor = secondaryColor; final currentErrorColor = errorColor;
     // Retorna InputDecoration
     return InputDecoration(
        labelText: labelText, labelStyle: GoogleFonts.poppins(textStyle:TextStyle(color: currentLabelColor, fontSize: 14)),
        prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Icon(prefixIcon, color: currentIconColor.withOpacity(0.8), size: 20)),
        prefixIconConstraints: const BoxConstraints(minWidth:20, minHeight:20), filled: true, fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: currentBorderColor.withOpacity(0.5))),
        enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: currentBorderColor.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: currentFocusColor, width: 2.0)),
        errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: currentErrorColor)),
        focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: currentErrorColor, width: 1.5)),
        errorStyle: TextStyle(color: currentErrorColor.withOpacity(0.95), fontSize: 12)
    );
  } // Fim _inputDecoration
} // Fim State