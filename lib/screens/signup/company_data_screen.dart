// lib/screens/signup/company_data_screen.dart (CORRIGIDO Nomes Controllers)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Importa a tela de cadastro de veículo do signup
import 'package:carbon/screens/signup/vehicle_registration_signup_screen.dart'; // CONFIRME NOME PACOTE
// Import do AuthWrapper (pode ser necessário se pular veículo)
import 'package:carbon/main.dart'; // CONFIRME NOME PACOTE

class CompanyDataScreen extends StatefulWidget {
  const CompanyDataScreen({super.key});
  @override State<CompanyDataScreen> createState() => _CompanyDataScreenState();
}

class _CompanyDataScreenState extends State<CompanyDataScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- CORREÇÃO: Nomes completos dos Controllers ---
  final _companyNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Formatadores
  final _cnpjFormatter = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  // Cores
  static const Color primaryColor = Color(0xFF00BFFF); // Azul elétrico para PJ
  static const Color secondaryColor = Color(0xFF00FFFF); // Ciano como secundário
  static final Color errorColor = Colors.redAccent[100]!;
  static final Color inputBorderColor = Colors.grey[800]!;
  static final Color labelColor = Colors.grey[400]!;
  static const Color textColor = Colors.white;

  @override
  void dispose() {
    // --- CORREÇÃO: Dispose com nomes completos ---
    _companyNameController.dispose(); _cnpjController.dispose(); _addressController.dispose();
    _phoneController.dispose(); _emailController.dispose(); _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitSignupFormPJ() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); if (!isValid) return;
    setState(() { _isLoading = true; }); await Future.delayed(500.ms);

    try {
      // 1. Criar usuário Auth (Usa controllers corretos)
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(), // Correto
        password: _passwordController.text.trim(), // Correto
      );
      final user = userCredential.user; if (user == null) throw Exception('Falha Auth.'); final userId = user.uid;
      print("Usuário (PJ) criado no Auth com UID: $userId");

      // 2. Preparar dados Firestore (Usa controllers corretos)
      final Map<String, dynamic> companyData = {
        'uid': userId, 'email': _emailController.text.trim(), // Correto
        'companyName': _companyNameController.text.trim(),   // <-- Nome Correto
        'cnpj': _cnpjFormatter.getUnmaskedText(),           // Usa Formatter correto
        'address': _addressController.text.trim(),         // <-- Nome Correto
        'phone': _phoneFormatter.getUnmaskedText(),         // Usa Formatter correto
        'accountType': 'PJ', 'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. Salvar dados Firestore
      print("Salvando dados da empresa: $companyData");
      await FirebaseFirestore.instance.collection('users').doc(userId).set(companyData);
      print("Dados da empresa salvos!");

      // 4. Navegar para Cadastro de Veículo
      if (mounted) {
        print("Navegando para o cadastro de veículo...");
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => const VehicleRegistrationScreenForSignup(),
        ));
      }

    } on FirebaseAuthException catch (err) { /* ... tratamento erro auth ... */
       String msg='Erro.'; final map={/*...*/}; msg=map[err.code]??err.message??msg;
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: errorColor));
    } catch (err, s) { /* ... tratamento erro geral ... */
       print("Erro Signup PJ: $err\n$s");
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro inesperado: ${err.toString()}')));
    } finally { if (mounted) { setState(() { _isLoading = false; }); } }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define cores locais
    final currentFocusColor = secondaryColor; final currentInputBorderColor = inputBorderColor;
    final currentLabelColor = labelColor; final currentPrimaryColor = primaryColor;
    final currentErrorColor = errorColor; final currentIconColor = primaryColor;

    return Scaffold(
      appBar: AppBar( title: Text('Cadastro Empresarial', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Form( key: _formKey,
          child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Text('Dados da Empresa', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              // --- CORREÇÃO: Usando Nomes Completos dos Controllers ---
              TextFormField(controller: _companyNameController, decoration: _inputDecoration(labelText:'Razão Social', prefixIcon: Icons.business_center, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), textCapitalization: TextCapitalization.words, validator: (v)=>(v==null||v.trim().isEmpty)?'Obrigatório':null), const SizedBox(height:15),
              TextFormField(controller: _cnpjController, decoration: _inputDecoration(labelText:'CNPJ', prefixIcon:Icons.badge_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), keyboardType:TextInputType.number, inputFormatters:[_cnpjFormatter], validator: (v){if(_cnpjFormatter.getUnmaskedText().length!=14)return 'Inválido'; return null;}), const SizedBox(height:15),
              TextFormField(controller: _addressController, decoration: _inputDecoration(labelText:'Endereço Completo', prefixIcon:Icons.location_city, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), maxLines: 2, validator: (v)=>(v==null||v.trim().isEmpty)?'Obrigatório':null), const SizedBox(height:15),
              TextFormField(controller: _phoneController, decoration: _inputDecoration(labelText:'Telefone Comercial', prefixIcon:Icons.phone_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), keyboardType:TextInputType.phone, inputFormatters:[_phoneFormatter], validator: (v){if(_phoneFormatter.getUnmaskedText().length<10)return 'Inválido'; return null;}),
              const SizedBox(height:35), Text('Crie o acesso principal', style: theme.textTheme.titleLarge?.copyWith(color: currentPrimaryColor)), const SizedBox(height: 25),
              TextFormField(controller: _emailController, decoration: _inputDecoration(labelText:'Email Contato/Login', prefixIcon: Icons.alternate_email, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), keyboardType: TextInputType.emailAddress, validator: (v)=>(v==null||v.trim().isEmpty||!v.contains('@'))?'Inválido':null ), const SizedBox(height: 15),
              TextFormField(controller: _passwordController, decoration: _inputDecoration(labelText:'Senha', prefixIcon: Icons.lock_outline, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), obscureText: true, validator: (v)=>(v==null||v.trim().length<6)?'Min 6 chars':null ), const SizedBox(height: 15),
              TextFormField(controller: _confirmPasswordController, decoration: _inputDecoration(labelText:'Confirmar Senha', prefixIcon: Icons.lock_reset_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), obscureText: true,
                  // --- CORREÇÃO: Usando nome completo do controller ---
                  validator: (v){if(v!=_passwordController.text)return 'Senhas não coincidem'; return null;}
              ), const SizedBox(height: 40),
              _isLoading ? Center(child: SpinKitFadingCube(color: currentPrimaryColor, size: 40.0))
              : ElevatedButton.icon( icon: const Icon(Icons.app_registration_rounded), label: const Text('Criar Conta Empresarial'), style: ElevatedButton.styleFrom(backgroundColor: currentPrimaryColor, foregroundColor: Colors.black87), onPressed: _submitSignupFormPJ ), const SizedBox(height: 20),
            ], ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }

  // Função auxiliar _inputDecoration (sem alterações na definição)
  InputDecoration _inputDecoration({ required String labelText, required IconData prefixIcon, required Color labelColor,
      required Color iconColor, required Color borderColor, required Color focusColor, required Color errorColor }) {
    return InputDecoration( labelText: labelText, labelStyle: GoogleFonts.poppins(textStyle:TextStyle(color: labelColor, fontSize: 14)),
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Icon(prefixIcon, color: iconColor, size: 20)),
      prefixIconConstraints: const BoxConstraints(minWidth:20, minHeight:20), contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: focusColor, width: 2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorColor)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorColor, width: 2.0)),
      errorStyle: TextStyle(color: errorColor.withOpacity(0.95), fontSize: 12));
  }
}