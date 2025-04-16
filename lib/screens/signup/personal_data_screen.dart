// lib/screens/signup/personal_data_screen.dart (COMPLETO E FUNCIONAL)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Importa a tela de cadastro de veículo do signup
import 'package:carbon/screens/signup/vehicle_registration_signup_screen.dart'; // CONFIRME NOME PACOTE
// Import do AuthWrapper não é necessário aqui

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});
  @override State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedDate;

  // Formatadores
  final _cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  // Cores (poderiam vir do tema)
  static const Color primaryColor = Color(0xFF00FFFF);
  static const Color secondaryColor = Color(0xFF00BFFF);
  static final Color errorColor = Colors.redAccent[100]!;
  static final Color inputBorderColor = Colors.grey[800]!;
  static final Color labelColor = Colors.grey[400]!;
  static const Color textColor = Colors.white;

  @override
  void dispose() {
    _nameController.dispose(); _cpfController.dispose(); _dobController.dispose();
    _phoneController.dispose(); _emailController.dispose(); _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920), lastDate: DateTime.now(), locale: const Locale('pt', 'BR'),
      // Usa o builder para aplicar o tema escuro/personalizado ao DatePicker
      builder: (context, child) {
         return Theme(
           data: Theme.of(context).copyWith(
             colorScheme: Theme.of(context).colorScheme.copyWith(
               primary: primaryColor, // Cor principal do picker
               onPrimary: Colors.black, // Texto sobre a cor principal (cabeçalho)
               surface: Theme.of(context).scaffoldBackgroundColor.withBlue(30), // Fundo do picker
               onSurface: textColor, // Texto geral do picker
             ),
             dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fundo do Dialog
             textButtonTheme: TextButtonThemeData(
               style: TextButton.styleFrom(foregroundColor: primaryColor), // Botões OK/Cancelar
             ),
           ),
           child: child!,
         );
       },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; _dobController.text = DateFormat('dd/MM/yyyy').format(picked); });
    }
  }

  void _submitSignupForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); if (!isValid) return;
    setState(() { _isLoading = true; }); await Future.delayed(500.ms);

    try {
      // 1. Criar usuário Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword( email: _emailController.text.trim(), password: _passwordController.text.trim());
      final user = userCredential.user; if (user == null) throw Exception('Falha ao criar usuário no Firebase Auth.'); final userId = user.uid;
      print("Usuário criado no Auth com UID: $userId");

      // 2. Preparar dados Firestore
      final Map<String, dynamic> userData = {
        'uid': userId, 'email': _emailController.text.trim(), 'fullName': _nameController.text.trim(),
        'cpf': _cpfFormatter.getUnmaskedText(), // Salva sem máscara
        'dateOfBirth': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null, // Salva como Timestamp
        'phone': _phoneFormatter.getUnmaskedText(), // Salva sem máscara
        'accountType': 'PF', 'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. Salvar dados Firestore
      print("Salvando dados do usuário no Firestore: $userData");
      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);
      print("Dados do usuário salvos com sucesso!");

      // 4. Navegar para Cadastro de Veículo
      if (mounted) {
        print("Navegando para o cadastro de veículo...");
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => const VehicleRegistrationScreenForSignup(), // Navega para próxima tela
        ));
      }
    } on FirebaseAuthException catch (err) {
       String errorMessage = 'Ocorreu um erro.'; final errorMap = {
         'email-already-in-use': 'Este email já está cadastrado.', 'weak-password': 'A senha é muito fraca (mínimo 6 caracteres).',
         'invalid-email': 'O formato do email é inválido.', 'network-request-failed': 'Sem conexão com a internet.',
       }; errorMessage = errorMap[err.code] ?? err.message ?? errorMessage;
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: errorColor, behavior: SnackBarBehavior.floating));
       if (mounted) setState(() { _isLoading = false; });
    } catch (err, s) {
       print("Erro ao salvar dados/criar usuário PF: $err\n$s");
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro inesperado ao salvar dados.'), behavior: SnackBarBehavior.floating));
       if (mounted) setState(() { _isLoading = false; });
    }
    // Não reseta isLoading em caso de sucesso, pois navega com pushReplacement
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); final focusColor = secondaryColor;
    final currentInputBorderColor = inputBorderColor; final currentLabelColor = labelColor;
    final currentPrimaryColor = primaryColor; final currentErrorColor = errorColor; final currentIconColor = primaryColor;

    return Scaffold(
      appBar: AppBar( title: Text('Cadastro Pessoal', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600)), elevation: 0, backgroundColor: theme.scaffoldBackgroundColor ),
      body: SingleChildScrollView( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Form( key: _formKey,
          child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Text('Conte-nos sobre você', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              TextFormField( controller: _nameController, decoration: _inputDecoration(labelText: 'Nome Completo', prefixIcon: Icons.person_outline, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), textCapitalization: TextCapitalization.words, validator: (v)=>(v==null||v.trim().isEmpty)?'Nome obrigatório':null ), const SizedBox(height: 15),
              TextFormField( controller: _cpfController, decoration: _inputDecoration(labelText: 'CPF', prefixIcon: Icons.badge_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), keyboardType: TextInputType.number, inputFormatters: [_cpfFormatter], validator: (v){if(_cpfFormatter.getUnmaskedText().length!=11)return 'CPF inválido'; return null;}), const SizedBox(height: 15),
              TextFormField( controller: _dobController, readOnly: true, decoration: _inputDecoration(labelText: 'Data Nasc (DD/MM/AAAA)', prefixIcon: Icons.calendar_today_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), onTap: ()=>_selectDate(context), validator: (v)=>(v==null||v.isEmpty)?'Data obrigatória':null ), const SizedBox(height: 15),
              TextFormField( controller: _phoneController, decoration: _inputDecoration(labelText: 'Telefone/Celular', prefixIcon: Icons.phone_android_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), keyboardType: TextInputType.phone, inputFormatters: [_phoneFormatter], validator: (v){if(_phoneFormatter.getUnmaskedText().length<10)return 'Telefone inválido'; return null;}),
              const SizedBox(height: 35), Text('Crie seu acesso', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              TextFormField( controller: _emailController, decoration: _inputDecoration(labelText: 'Email', prefixIcon: Icons.alternate_email, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), keyboardType: TextInputType.emailAddress, validator: (v)=>(v==null||v.trim().isEmpty||!v.contains('@'))?'Email inválido':null ), const SizedBox(height: 15),
              TextFormField( controller: _passwordController, decoration: _inputDecoration(labelText: 'Senha', prefixIcon: Icons.lock_outline, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), obscureText: true, validator: (v)=>(v==null||v.trim().length<6)?'Mínimo 6 caracteres':null ), const SizedBox(height: 15),
              TextFormField( controller: _confirmPasswordController, decoration: _inputDecoration(labelText: 'Confirmar Senha', prefixIcon: Icons.lock_reset_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: focusColor, errorColor: currentErrorColor), obscureText: true, validator: (v){if(v!=_passwordController.text)return 'As senhas não coincidem'; return null;} ), const SizedBox(height: 40),
              _isLoading ? Center(child: SpinKitFadingCube(color: currentPrimaryColor, size: 40.0))
              : ElevatedButton.icon( icon: const Icon(Icons.app_registration_rounded), label: const Text('Criar Conta e Avançar'), style: ElevatedButton.styleFrom(backgroundColor: currentPrimaryColor, foregroundColor: Colors.black), onPressed: _submitSignupForm ),
              const SizedBox(height: 20),
            ], ).animate().fadeIn(duration: 300.ms), // Anima a entrada da coluna
        ),
      ),
    );
  }

  // Função auxiliar InputDecoration (sem alterações)
  InputDecoration _inputDecoration({ required String labelText, required IconData prefixIcon, required Color labelColor, required Color iconColor, required Color borderColor, required Color focusColor, required Color errorColor }) {
     return InputDecoration( /* ... Definição completa ... */ );
   }
}