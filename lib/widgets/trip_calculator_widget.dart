// lib/widgets/trip_calculator_widget.dart (Adicionados Logs de Debug)
import 'dart:async'; import 'dart:math'; import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carbon/models/vehicle_type_enum.dart'; // CONFIRME NOME PACOTE
import 'package:carbon/services/carbon_service.dart'; // CONFIRME NOME PACOTE
import 'package:carbon/widgets/indicator_card.dart';   // CONFIRME NOME PACOTE

class TripCalculatorWidget extends StatefulWidget { const TripCalculatorWidget({super.key}); @override State<TripCalculatorWidget> createState() => _TripCalculatorWidgetState(); }
class _TripCalculatorWidgetState extends State<TripCalculatorWidget> {
  final _formKey = GlobalKey<FormState>(); final _originController = TextEditingController(); final _destinationController = TextEditingController();
  String? _selectedVehicleDataString; bool _isLoading = false; bool _isCalculating = false; Map<String, dynamic>? _results;
  List<DropdownMenuItem<String>> _vehicleDropdownItems = []; bool _vehiclesLoading = true; final CarbonService _carbonService = CarbonService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override void initState() { super.initState(); if (_currentUser != null) {
    _fetchUserVehicles(_currentUser.uid);
  } else {
    setState(() => _vehiclesLoading = false);
  } }
  @override void dispose() { _originController.dispose(); _destinationController.dispose(); super.dispose(); }

  Future<void> _fetchUserVehicles(String userId) async {
    print("[TripCalculator] _fetchUserVehicles: Buscando veículos...");
    if (!mounted) return; setState(() => _vehiclesLoading = true ); try { final snapshot = await FirebaseFirestore.instance.collection('vehicles').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).get();
      final items = snapshot.docs.map((doc) { final data = doc.data(); final type = vehicleTypeFromString(data['type']); final label = '${data['make'] ?? '?'} ${data['model'] ?? '?'} (${type?.displayName ?? data['type'] ?? '?'})'; final valueString = '${doc.id}|${type?.name ?? ''}'; return DropdownMenuItem<String>( value: valueString, child: Text(label, overflow: TextOverflow.ellipsis) ); }).toList();
      if (mounted) setState(() { _vehicleDropdownItems = items; print("[TripCalculator] _fetchUserVehicles: ${items.length} veículos carregados."); }); } catch (e) { print("!!! ERRO fetch Calc vehicles: $e"); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao carregar veículos.'))); } finally { if (mounted) setState(() => _vehiclesLoading = false); }
  }

  // --- CORREÇÃO: Logs Detalhados ---
  Future<void> _calculateTrip() async {
    print("--- [TripCalculator] Iniciando _calculateTrip ---");
    final isValid = _formKey.currentState?.validate() ?? false;
    print("[TripCalculator] Formulário válido: $isValid");
    FocusScope.of(context).unfocus();
    if (!isValid) { print("[TripCalculator] Formulário inválido. Abortando."); return; }

    print("[TripCalculator] Veículo selecionado string: $_selectedVehicleDataString");
    if (_selectedVehicleDataString == null) {
      print("[TripCalculator] Nenhum veículo selecionado. Abortando.");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um veículo.')));
      return;
    }

    setState(() { print("[TripCalculator] Definindo _isCalculating = true"); _isCalculating = true; _results = null; });
    await Future.delayed(100.ms); // Pequeno delay para UI atualizar

    final originText = _originController.text.trim(); final destinationText = _destinationController.text.trim();
    final parts = _selectedVehicleDataString!.split('|'); final vehicleId = parts[0]; final vehicleType = vehicleTypeFromString(parts.length > 1 ? parts[1] : null);
    print("[TripCalculator] Dados extraídos: Origin='$originText', Dest='$destinationText', VehID='$vehicleId', VehType=$vehicleType");

    if (vehicleType == null) {
       print("!!! ERRO: Tipo de veículo inválido ou não encontrado no enum a partir de '$_selectedVehicleDataString'. Abortando. !!!");
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro interno: tipo de veículo inválido.')));
       if(mounted) setState(()=>_isCalculating=false); return;
    }

    try {
      print("[TripCalculator] Iniciando simulação de distância e cálculo de impacto...");
      // SIMULAÇÃO API
      await Future.delayed(1200.ms);
      final randomDistance = 50.0 + Random().nextDouble() * 500.0;
      double distanceKm = double.parse(randomDistance.toStringAsFixed(1));
      print("[TripCalculator] Distância simulada: $distanceKm km");

      final impact = _carbonService.calculateTripImpact( distanceKm: distanceKm, vehicleType: vehicleType );
      print("[TripCalculator] Impacto calculado: $impact");

      const double carbonPricePerTon = 55.50; // Preço Placeholder
      double carbonKg = impact['carbonKg'] ?? 0.0;
      double monetaryValue = -(carbonKg / 1000.0) * carbonPricePerTon;
      print("[TripCalculator] Valor monetário calculado: $monetaryValue");

      if(mounted) {
        setState(() {
          print("[TripCalculator] Atualizando estado com resultados...");
          _results = { 'distance': distanceKm, 'carbon': carbonKg, 'carbonPrice': carbonPricePerTon, 'value': monetaryValue, 'isElectric': vehicleType == VehicleType.electric || vehicleType == VehicleType.hybrid, 'origin': originText, 'destination': destinationText, 'vehicleId': vehicleId, 'vehicleType': vehicleType, };
        });
        print("[TripCalculator] Estado atualizado com sucesso.");
      }
    } catch (e, s) {
      print("!!! ERRO GERAL durante cálculo/simulação: $e\n$s");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao calcular rota.'), backgroundColor: Colors.redAccent));
    } finally {
      print("--- [TripCalculator] Finalizando _calculateTrip (finally) ---");
      if(mounted) {
        setState(() { _isCalculating = false; });
      }
    }
  } // Fim _calculateTrip

  // --- CORREÇÃO: Logs Detalhados ---
  Future<void> _saveManualTrip() async {
     print("--- [TripCalculator] Iniciando _saveManualTrip ---");
     if (_results == null) { print("[TripCalculator] _saveManualTrip: Nenhum resultado para salvar."); return; }
     if (_currentUser == null) { print("[TripCalculator] _saveManualTrip: Usuário nulo."); return; }
     if (!mounted) return;

     setState(() { _isLoading = true; });
     await Future.delayed(200.ms);

      try {
        final Map<String, dynamic> tripData = {'userId':_currentUser.uid,'vehicleId':_results!['vehicleId'],'vehicleType':(_results!['vehicleType'] as VehicleType).name,'origin':_results!['origin'],'destination':_results!['destination'],'distanceKm':_results!['distance'],'startTime':Timestamp.now(),'endTime':Timestamp.now(),'durationMs':0,'calculatedCarbonKg':_results!['carbon'],'calculatedValue':_results!['value'],'processedForWallet':false,'createdAt':FieldValue.serverTimestamp(),'calculationMethod':'manual_route'};
        print("[TripCalculator] Salvando viagem manual: $tripData");
        await FirebaseFirestore.instance.collection('trips').add(tripData);
        print("[TripCalculator] Viagem manual salva com sucesso!");
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viagem calculada registrada!'), backgroundColor: Colors.green));
           _originController.clear(); _destinationController.clear();
           setState(() { _results = null; _selectedVehicleDataString = null; print("[TripCalculator] Formulário limpo após salvar."); }); }
      } catch (e, s) {
         print("!!! ERRO AO SALVAR VIAGEM MANUAL: $e\n$s");
         if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar registro.'), backgroundColor: Colors.redAccent)); }
      } finally {
         print("--- [TripCalculator] Finalizando _saveManualTrip (finally) ---");
         if (mounted) { setState(() { _isLoading = false; }); }
      }
  } // Fim _saveManualTrip

  // ***** BUILD COMPLETO E VERIFICADO *****
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Retorna Card
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8), // Margem vertical menor
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding( padding: const EdgeInsets.all(16.0),
        child: Form( key: _formKey,
          child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [ // mainAxisSize.min
               Text('Calcular Rota e Impacto', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary)), // Título Menor
               const SizedBox(height: 16),
               // Dropdown Veículos
               if (_vehiclesLoading) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator(strokeWidth: 2)))
               else if (_vehicleDropdownItems.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Cadastre um veículo primeiro.', textAlign: TextAlign.center,)))
               else DropdownButtonFormField<String>(
                  value: _selectedVehicleDataString, items: _vehicleDropdownItems,
                  onChanged: _isCalculating ? null : (String? newValue) { if (newValue != _selectedVehicleDataString && _results != null) setState(() => _results = null); setState(() => _selectedVehicleDataString = newValue); },
                  decoration: InputDecoration( contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), isDense: true, labelText: 'Selecione o Veículo', prefixIcon: Icon(Icons.directions_car_outlined, color: colorScheme.primary.withOpacity(0.8))),
                  validator: (v) => v == null ? 'Obrigatório' : null, ),
               const SizedBox(height: 12),
               // Origem/Destino
               TextFormField( controller: _originController, enabled: !_isCalculating, decoration: const InputDecoration(labelText: 'Origem', prefixIcon: Icon(Icons.trip_origin), isDense: true), validator: (v)=>(v==null||v.trim().isEmpty)?'Obrigatório':null, ).animate().fadeIn(delay: 100.ms),
               const SizedBox(height: 8),
               TextFormField( controller: _destinationController, enabled: !_isCalculating, decoration: const InputDecoration(labelText: 'Destino', prefixIcon: Icon(Icons.flag_outlined), isDense: true), validator: (v)=>(v==null||v.trim().isEmpty)?'Obrigatório':null, ).animate().fadeIn(delay: 150.ms),
               const SizedBox(height: 20),
               // Botão Calcular/Loading
               _isCalculating ? Center(child: Padding(padding: const EdgeInsets.all(8.0), child: SpinKitPulse(color: colorScheme.primary, size: 30.0)))
               : ElevatedButton.icon( onPressed: _calculateTrip, icon: const Icon(Icons.calculate_outlined, size: 20), label: const Text('Calcular Rota e Impacto'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)), ).animate().fadeIn(delay: 200.ms).scale(),
               // --- Área de Resultados ---
               // Anima a aparição da área de resultados
               AnimatedSize( duration: 300.ms, curve: Curves.easeInOut, child: _results != null ?
                 Column( children: [
                    const Divider(height: 30, thickness: 0.5, indent: 20, endIndent: 20),
                    Text('Resultados Estimados:', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 15),
                    Wrap( spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
                         IndicatorCard(title: 'DISTÂNCIA', value: '${_results!['distance'].toStringAsFixed(1)} km', icon: Icons.route_outlined, color: Colors.blue[300]!),
                         IndicatorCard(title: _results!['isElectric'] ? 'CARBONO EVITADO' : 'CO₂ EMITIDO', value: '${_results!['carbon'].toStringAsFixed(2)} kg', icon: _results!['isElectric'] ? Icons.eco_outlined : Icons.cloud_queue_outlined, color: _results!['carbon'] >= 0 ? Colors.grey[400]! : Colors.green[300]!),
                         IndicatorCard(title: _results!['isElectric'] ? 'CRÉDITO POTENCIAL' : 'CUSTO CARBONO', value: 'R\$ ${_results!['value'].abs().toStringAsFixed(2)}', icon: Icons.paid_outlined, color: _results!['value'] >= 0 ? Colors.green : Colors.redAccent[100]!),
                       ], ),
                    const SizedBox(height: 20),
                    if (!_isLoading) Center( child: TextButton.icon( onPressed: _saveManualTrip, icon: const Icon(Icons.save_alt, size: 18), label: const Text('Registrar Viagem Calculada'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary), ) )
                    else const Center(child: Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                 ],) : const SizedBox.shrink(), // Se não há resultados, não mostra nada
               ).animate().fadeIn(delay: 200.ms) // Anima entrada da área de resultados
            ],
          ), // Fim Column
        ), // Fim Form
      ), // Fim Padding
    ); // Fim Card
  } // Fim build
} // Fim classe State