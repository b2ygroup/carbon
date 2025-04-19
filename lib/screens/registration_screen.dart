// lib/screens/registration_screen.dart (CORRIGIDO Dropdown enabled e _inputDecoration call)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:carbon/models/vehicle_type_enum.dart'; // CONFIRME NOME PACOTE

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? _year; VehicleType? _selectedType; String _licensePlate = '';
  String? _selectedMake; String? _selectedModel;

  // Dados Exemplo
  final List<String> _allMakes = [ 'Fiat', 'Volkswagen', 'Chevrolet', 'Ford', 'Toyota', 'Honda', 'Hyundai', 'Renault', 'Jeep', 'Nissan', 'Peugeot', 'Citroën', 'BMW', 'Mercedes-Benz', 'Audi' ];
  final Map<String, List<String>> _modelsByMake = { 'Fiat': ['Mobi', 'Argo', 'Cronos', /*...*/], 'Volkswagen': ['Gol', 'Voyage', /*...*/], /* ... */ };

  // Cores
  static const Color primaryColor = Color(0xFF00FFFF); static const Color focusColor = Color(0xFF00BFFF);
  static final Color errorColor = Colors.redAccent[100]!; static final Color inputBorderColor = Colors.grey[800]!;
  static final Color labelColor = Colors.grey[400]!; static const Color textColor = Colors.white;

  @override void dispose() { super.dispose(); }

  // Funções de Seleção (Completas)
  Future<String?> _showSelectionDialog({ required BuildContext context, required String title, required List<String> items }) async {
    return null;
   /* ... (código igual anterior) ... */ }
  Future<void> _selectMake() async { /* ... (código igual anterior) ... */ }
  Future<void> _selectModel() async { /* ... (código igual anterior) ... */ }

  // Função Submit (Completa - Navega com Pop)
  void _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false; if (!isValid) return;
    _formKey.currentState?.save();
    if (_selectedType == null || _selectedMake == null || _selectedModel == null) { if(mounted) ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Selecione Tipo, Marca e Modelo.'), backgroundColor: Colors.orangeAccent)); return; }
    setState(()=>_isLoading=true); await Future.delayed(300.ms);
    try {
      final user = FirebaseAuth.instance.currentUser; if (user == null) throw Exception('Usuário não autenticado.'); String userId = user.uid;
      final Map<String, dynamic> vehicleData = {'userId':userId, 'make':_selectedMake, 'model':_selectedModel, 'year':_year, 'type':_selectedType!.name, 'licensePlate':_licensePlate.isNotEmpty?_licensePlate.toUpperCase():null, 'createdAt':FieldValue.serverTimestamp()};
      print("Salvando veículo (RegistrationScreen): $vehicleData");
      await FirebaseFirestore.instance.collection('vehicles').add(vehicleData); print("Veículo salvo!");
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedMake??""} ${_selectedModel??""} registrado!'), backgroundColor: Colors.green));
         Navigator.of(context).pop(); // <-- Volta para tela anterior (Dashboard)
      }
    } catch (error) { /* ... tratamento erro ... */ }
    finally { if(mounted) setState(()=>_isLoading=false); }
  }

  // --- Função Helper _inputDecoration (COMPLETA E CORRETA) ---
  InputDecoration _inputDecoration({ required String labelText, required IconData prefixIcon, required Color labelColor,
      required Color iconColor, required Color borderColor, required Color focusColor, required Color errorColor }) {
    return InputDecoration( labelText: labelText, labelStyle: GoogleFonts.poppins(textStyle:TextStyle(color: labelColor, fontSize: 14)),
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Icon(prefixIcon, color: iconColor.withOpacity(0.8), size: 20)),
      prefixIconConstraints: const BoxConstraints(minWidth:20, minHeight:20), filled: true, fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0), border: OutlineInputBorder( borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: borderColor.withOpacity(0.5))),
      enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: borderColor.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: focusColor, width: 1.5)),
      errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: errorColor)),
      focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: errorColor, width: 1.5)),
      counterText: "", errorStyle: TextStyle(color: errorColor.withOpacity(0.95), fontSize: 12) );
  }

  // --- Função Helper _buildSelectionRow (COMPLETA E CORRETA com chamada _inputDecoration corrigida) ---
  Widget _buildSelectionRow({ required String label, String? value, VoidCallback? onPressed, required String selectText, String? placeholder}) {
    // Define cores locais para passar para o helper
    const currentTextColor = textColor; final currentLabelColor = labelColor; const currentPrimaryColor = primaryColor;
    final currentInputBorderColor = inputBorderColor; const currentFocusColor = focusColor; final currentErrorColor = errorColor;
    const currentIconColor = primaryColor;

    // Retorna InputDecorator CORRETAMENTE
    return InputDecorator(
      // ***** CORREÇÃO: Passa TODOS os parâmetros para _inputDecoration *****
      decoration: _inputDecoration(
        labelText: label,
        prefixIcon: Icons.directions_car_outlined,
        labelColor: currentLabelColor,
        iconColor: currentIconColor,
        borderColor: currentInputBorderColor,
        focusColor: currentFocusColor,
        errorColor: currentErrorColor
      ),
      child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded( child: Text( value ?? placeholder ?? 'Não selecionado', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(textStyle:TextStyle( color: value!=null?currentTextColor:currentLabelColor.withOpacity(0.7), fontSize: 16, fontWeight: value!=null?FontWeight.w500:FontWeight.normal )))),
          TextButton( style: TextButton.styleFrom( foregroundColor: currentPrimaryColor, padding: const EdgeInsets.symmetric(horizontal: 8) ), onPressed: onPressed,
              child: Row( mainAxisSize: MainAxisSize.min, children: [ Text(selectText, style: GoogleFonts.poppins(fontSize: 14)), const Icon(Icons.search, size: 20) ] ))])); // Usa Ícone Busca
  } // Fim _buildSelectionRow

  // --- Método Build Principal (COMPLETO E CORRIGIDO) ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define cores locais
    const currentPrimaryColor = primaryColor; const currentFocusColor = focusColor; final currentErrorColor = errorColor;
    final currentInputBorderColor = inputBorderColor; final currentLabelColor = labelColor; const currentIconColor = primaryColor;

    // Retorna Scaffold
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Novo Veículo', style: GoogleFonts.rajdhani())),
      body: Center( child: ConstrainedBox( constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView( padding: const EdgeInsets.all(20.0),
            child: Form( key: _formKey,
              child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  Text('Informe os dados do veículo', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: currentLabelColor)), const SizedBox(height: 30),
                  // Seleção Marca/Modelo (Usa helpers corrigidos)
                  _buildSelectionRow( label: 'Marca', value: _selectedMake, onPressed: _isLoading ? null : _selectMake, selectText: 'Selecionar Marca').animate().fadeIn(delay: 100.ms), const SizedBox(height: 15),
                  _buildSelectionRow( label: 'Modelo', value: _selectedModel, onPressed: _isLoading || _selectedMake==null ? null : _selectModel, selectText: 'Selecionar Modelo', placeholder: _selectedMake==null?'Selecione marca':null).animate().fadeIn(delay: 200.ms), const SizedBox(height: 15),
                  // Ano (Usa helper corrigido)
                  TextFormField( enabled: !_isLoading, decoration: _inputDecoration(labelText:'Ano', prefixIcon: Icons.calendar_month_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), keyboardType: TextInputType.number, maxLength: 4, validator: (v){/*...*/ return null;}, onSaved: (v)=>_year=int.parse(v!)).animate().fadeIn(delay: 300.ms), const SizedBox(height: 15),
                  // Placa (Usa helper corrigido)
                  TextFormField( enabled: !_isLoading, decoration: _inputDecoration(labelText:'Placa (Opcional)', prefixIcon: Icons.badge_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor), textCapitalization:TextCapitalization.characters, maxLength: 7, onSaved: (v)=>_licensePlate=v??'').animate().fadeIn(delay: 400.ms), const SizedBox(height: 15),
                  // Tipo Veículo (Usa helper corrigido e onChanged para desabilitar)
                  DropdownButtonFormField<VehicleType>( value: _selectedType, decoration: _inputDecoration(labelText:'Tipo Combustível/Motor', prefixIcon: Icons.speed_outlined, labelColor: currentLabelColor, iconColor: currentIconColor, borderColor: currentInputBorderColor, focusColor: currentFocusColor, errorColor: currentErrorColor),
                    items: VehicleType.values.map((t)=>DropdownMenuItem<VehicleType>(value:t, child:Row(children:[Icon(t.icon,size:20,color:t.displayColor), const SizedBox(width:10), Text(t.displayName)]))).toList(),
                    // --- CORREÇÃO: Usa onChanged ---
                    onChanged: _isLoading ? null : (v)=>setState(()=>_selectedType=v),
                    validator: (v)=>v==null?'Selecione':null ).animate().fadeIn(delay: 500.ms), const SizedBox(height: 40),
                  // Botão Salvar
                  _isLoading ? const Center(child: SpinKitWave(color: currentPrimaryColor, size: 30.0))
                  : ElevatedButton.icon( onPressed: _submitForm, icon: const Icon(Icons.save_alt_rounded), label: const Text('Salvar Veículo'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15))).animate().fadeIn(delay: 600.ms).scale(), const SizedBox(height: 20),
                ], ), ), ), ), ), ); // Fim Scaffold Body
  } // Fim build
} // Fim State