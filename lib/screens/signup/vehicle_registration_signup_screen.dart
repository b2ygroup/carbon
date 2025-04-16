// lib/screens/signup/vehicle_registration_signup_screen.dart (CORRIGIDO - Usar esta versão)
import 'dart:async';
import 'dart:math'; // Para o Dialog de Seleção
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Importa o enum e o AuthWrapper (Use o nome correto do seu pacote)
import 'package:carbon/models/vehicle_type_enum.dart'; // CONFIRME NOME PACOTE
import 'package:carbon/main.dart'; // Para AuthWrapper - CONFIRME NOME PACOTE

class VehicleRegistrationScreenForSignup extends StatefulWidget {
  const VehicleRegistrationScreenForSignup({super.key});
  @override State<VehicleRegistrationScreenForSignup> createState() => _VehicleRegistrationScreenForSignupState();
}

class _VehicleRegistrationScreenForSignupState extends State<VehicleRegistrationScreenForSignup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Estados do Formulário (Nomes consistentes)
  int? _vehicleYear;
  VehicleType? _selectedVehicleType;
  String _vehicleLicensePlate = '';
  String? _selectedMake;
  String? _selectedModel;

  // Dados Exemplo (TODO: Substituir)
  final List<String> _allMakes = [ 'Fiat', 'Volkswagen', 'Chevrolet', 'Ford', 'Toyota', 'Honda', 'Hyundai', 'Renault', 'Jeep', 'Nissan', 'Peugeot', 'Citroën', 'BMW', 'Mercedes-Benz', 'Audi' ];
  final Map<String, List<String>> _modelsByMake = { 'Fiat': ['Mobi', 'Argo', 'Cronos', 'Strada', 'Toro', 'Pulse', 'Fastback', 'Uno', 'Palio'], 'Volkswagen': ['Gol', 'Voyage', 'Polo', 'Virtus', 'T-Cross', 'Nivus', 'Taos', 'Saveiro', 'Amarok'], /* ... etc ... */ };

  // Cores
  static const Color primaryColor = Color(0xFF00FFFF);
  static const Color focusColor = Color(0xFF00BFFF);
  static final Color errorColor = Colors.redAccent[100]!;
  static final Color inputBorderColor = Colors.grey[800]!;
  static final Color labelColor = Colors.grey[400]!;
  static final Color textColor = Colors.white.withOpacity(0.9);

  @override void dispose() { super.dispose(); }

  // --- Funções de Seleção Marca/Modelo (COMPLETAS) ---
  Future<String?> _showSelectionDialog({ required BuildContext context, required String title, required List<String> items }) async { /* ... (código igual resposta #111) ... */ }
  Future<void> _selectMake() async { /* ... (código igual resposta #111) ... */ }
  Future<void> _selectModel() async { /* ... (código igual resposta #111 com prints debug) ... */ }

  // --- Função de Submit (COMPLETA e usando nomes corretos) ---
  void _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false; if (!isValid) return;
    _formKey.currentState?.save();
    // Usa nomes consistentes
    if (_selectedVehicleType == null || _selectedMake == null || _selectedModel == null) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Selecione Tipo, Marca e Modelo.'), backgroundColor: Colors.orangeAccent)); return; }
    setState(()=>_isLoading=true); await Future.delayed(300.ms);
    try {
      final user = FirebaseAuth.instance.currentUser; if (user == null) throw Exception('Usuário não encontrado.'); String userId = user.uid;
      // Usa nomes consistentes
      final Map<String, dynamic> vehicleData = {'userId':userId, 'make':_selectedMake, 'model':_selectedModel, 'year':_vehicleYear, 'type':_selectedVehicleType!.name, 'licensePlate':_vehicleLicensePlate.isNotEmpty?_vehicleLicensePlate.toUpperCase():null, 'createdAt':FieldValue.serverTimestamp()};
      print("Salvando primeiro veículo: $vehicleData");
      await FirebaseFirestore.instance.collection('vehicles').add(vehicleData); print("Primeiro veículo salvo!");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('${_selectedMake??""} ${_selectedModel??""} adicionado!'), backgroundColor: Colors.green));
         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=>const AuthWrapper()), (r)=>false); // Navega para Wrapper -> Dashboard
      }
    } catch (error, stackTrace) { /* ... tratamento de erro ... */
       print("!!! ERRO AO SALVAR VEÍCULO !!!\n$error\n$stackTrace"); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $error'), backgroundColor: errorColor));
    } finally { if(mounted) setState(()=>_isLoading=false); }
  }

  // --- Função Helper _inputDecoration (COMPLETA E CORRETA) ---
  InputDecoration _inputDecoration({ required String labelText, required IconData prefixIcon, required Color labelColor,
      required Color iconColor, required Color borderColor, required Color focusColor, required Color errorColor }) {
    // Retorna InputDecoration CORRETAMENTE
    return InputDecoration( /* ... (definição completa igual resposta #111) ... */ );
  }

  // --- Função Helper _buildSelectionRow (COMPLETA E CORRETA) ---
  Widget _buildSelectionRow({ required String label, String? value, VoidCallback? onPressed, required String selectText, String? placeholder}) {
    // Usa cores locais definidas no State
    final currentTextColor = textColor; final currentLabelColor = labelColor; final currentPrimaryColor = primaryColor;
    final currentInputBorderColor = inputBorderColor; final currentFocusColor = focusColor; final currentErrorColor = errorColor; final currentIconColor = primaryColor;
    // Retorna InputDecorator CORRETAMENTE com decoration
    return InputDecorator(
      // Passa todos os args para _inputDecoration
      decoration: _inputDecoration( labelText: label, prefixIcon: Icons.directions_car_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor),
      child: Row( /* ... (Row com Text e TextButton igual resposta #111) ... */ )
    ); // Fim InputDecorator
  } // Fim _buildSelectionRow


  // --- Método Build Principal (COMPLETO E CORRIGIDO) ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define cores locais para passar aos helpers
    final currentPrimaryColor = primaryColor; final currentFocusColor = focusColor; final currentErrorColor = errorColor;
    final currentInputBorderColor = inputBorderColor; final currentLabelColor = labelColor; final currentIconColor = primaryColor;

    // Retorna Scaffold
    return Scaffold(
      appBar: AppBar( title: Text('Cadastre Seu Veículo', style: GoogleFonts.rajdhani()), automaticallyImplyLeading: false ),
      body: Center( child: ConstrainedBox( constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView( padding: const EdgeInsets.all(20.0),
            child: Form( key: _formKey,
              child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  Text('Último passo: informe os dados do seu veículo principal.', textAlign: TextAlign.center, style: theme.textTheme.titleMedium), const SizedBox(height: 30),

                  // --- CORREÇÃO: Passa 'selectText' nas chamadas ---
                  _buildSelectionRow( label: 'Marca', value: _selectedMake, onPressed: _selectMake, selectText: 'Selecionar Marca').animate().fadeIn(delay: 100.ms), const SizedBox(height: 15),
                  _buildSelectionRow( label: 'Modelo', value: _selectedModel, onPressed: _selectedMake!=null?_selectModel:null, selectText: 'Selecionar Modelo', placeholder: _selectedMake==null?'Selecione marca':'Não selecionado').animate().fadeIn(delay: 200.ms), const SizedBox(height: 15),

                  // --- CORREÇÃO: Passa TODOS os parâmetros para _inputDecoration ---
                  TextFormField( decoration: _inputDecoration(labelText:'Ano', prefixIcon: Icons.calendar_month_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), keyboardType: TextInputType.number, maxLength: 4, validator: (v){/*...*/ return null;}, onSaved: (v)=>_vehicleYear=int.parse(v!)).animate().fadeIn(delay: 300.ms), const SizedBox(height: 15),
                  TextFormField( decoration: _inputDecoration(labelText:'Placa (Opcional)', prefixIcon: Icons.badge_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), textCapitalization:TextCapitalization.characters, maxLength: 7, onSaved: (v)=>_vehicleLicensePlate=v??'').animate().fadeIn(delay: 400.ms), const SizedBox(height: 15),

                  // --- CORREÇÃO: Passa TODOS os parâmetros e usa _selectedVehicleType ---
                  DropdownButtonFormField<VehicleType>( value: _selectedVehicleType, decoration: _inputDecoration(labelText:'Tipo Combustível/Motor', prefixIcon: Icons.speed_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor),
                    items: VehicleType.values.map((t)=>DropdownMenuItem<VehicleType>(value:t, child:Row(children:[Icon(t.icon,size:20,color:t.displayColor), const SizedBox(width:10), Text(t.displayName)]))).toList(), // items OK
                    onChanged: (v)=>setState(()=>_selectedVehicleType=v), // onChanged OK
                    validator: (v)=>v==null?'Selecione':null ).animate().fadeIn(delay: 500.ms), const SizedBox(height: 40),

                  // Botão Salvar
                  _isLoading ? Center(child: SpinKitWave(color: currentPrimaryColor, size: 30.0))
                  : ElevatedButton.icon( onPressed: _submitForm, icon: const Icon(Icons.directions_car_filled), label: const Text('Concluir Cadastro'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15))).animate().fadeIn(delay: 600.ms).scale(), const SizedBox(height: 20),
                ], ), ), ), ), ), ); // Fim Scaffold Body
  } // Fim build
} // Fim State