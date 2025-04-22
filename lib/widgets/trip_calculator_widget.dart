// lib/widgets/trip_calculator_widget.dart (CORRIGIDO Parâmetro Indicador)
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carbon/models/vehicle_type_enum.dart'; // CONFIRME NOME PACOTE
import 'package:carbon/services/carbon_service.dart'; // CONFIRME NOME PACOTE
import 'package:carbon/widgets/indicator_card.dart';   // CONFIRME NOME PACOTE

class TripCalculatorWidget extends StatefulWidget {
  const TripCalculatorWidget({super.key});
  @override State<TripCalculatorWidget> createState() => _TripCalculatorWidgetState();
}

class _TripCalculatorWidgetState extends State<TripCalculatorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  String? _selectedVehicleDataString; // Guarda "vehicleId|vehicleTypeName"
  bool _isLoading = false; // Usado para salvar
  bool _isCalculating = false; // Usado para calcular
  Map<String, dynamic>? _results; // Armazena os resultados do cálculo para exibição
  List<DropdownMenuItem<String>> _vehicleDropdownItems = [];
  bool _vehiclesLoading = true;
  final CarbonService _carbonService = CarbonService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _fetchUserVehicles(_currentUser!.uid);
    } else {
      if (mounted) setState(() => _vehiclesLoading = false);
      print("[TripCalculator] Usuário não logado no initState.");
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserVehicles(String userId) async {
    print("[TripCalculator] _fetchUserVehicles: Buscando veículos...");
    if (!mounted) return;
    setState(() => _vehiclesLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        final type = vehicleTypeFromString(data['type'] as String?);
        final label = '${data['make'] ?? '?'} ${data['model'] ?? '?'} (${type?.displayName ?? data['type'] ?? 'Tipo Desconhecido'})';
        final valueString = '${doc.id}|${type?.name ?? ''}';
        return DropdownMenuItem<String>(
          value: valueString,
          child: Text(label, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _vehicleDropdownItems = items;
          print("[TripCalculator] _fetchUserVehicles: ${items.length} veículos carregados.");
        });
      }
    } catch (e) {
      print("!!! ERRO fetch Calc vehicles: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar veículos.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _vehiclesLoading = false);
    }
  }

  Future<void> _calculateTrip() async {
    print("--- [TripCalculator] Iniciando _calculateTrip ---");
    final isValid = _formKey.currentState?.validate() ?? false;
    print("[TripCalculator] Formulário válido: $isValid");
    FocusScope.of(context).unfocus();
    if (!isValid) {
      print("[TripCalculator] Formulário inválido. Abortando.");
      return;
    }

    print("[TripCalculator] Veículo selecionado string: $_selectedVehicleDataString");
    if (_selectedVehicleDataString == null) {
      print("[TripCalculator] Nenhum veículo selecionado. Abortando.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um veículo.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() {
      print("[TripCalculator] Definindo _isCalculating = true");
      _isCalculating = true;
      _results = null;
    });
    await Future.delayed(100.ms);

    final originText = _originController.text.trim();
    final destinationText = _destinationController.text.trim();
    final parts = _selectedVehicleDataString!.split('|');
    final vehicleId = parts[0];
    final vehicleType = vehicleTypeFromString(parts.length > 1 ? parts[1] : null);
    print("[TripCalculator] Dados extraídos: Origin='$originText', Dest='$destinationText', VehID='$vehicleId', VehType Enum=$vehicleType");

    if (vehicleType == null) {
      print("!!! ERRO: Tipo de veículo inválido ($parts[1]). Abortando. !!!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro interno: tipo de veículo inválido.'), backgroundColor: Colors.red),
        );
        setState(() => _isCalculating = false);
      }
      return;
    }

    try {
      print("[TripCalculator] Iniciando simulação de distância e cálculo de impacto...");
      // === SIMULAÇÃO DE DISTÂNCIA ===
      await Future.delayed(1200.ms);
      final randomDistance = 50.0 + Random().nextDouble() * 500.0;
      double distanceKm = double.parse(randomDistance.toStringAsFixed(1));
      print("[TripCalculator] Distância simulada: $distanceKm km");
      // ============================

      print("[TripCalculator] Chamando _carbonService.getTripCalculationResults...");
      final Map<String, double> impactResults = await _carbonService.getTripCalculationResults(
        distanceKm: distanceKm,
        vehicleType: vehicleType,
      );
      print("[TripCalculator] Resultados recebidos do serviço: $impactResults");

      final double carbonKg = impactResults['carbonKg'] ?? 0.0;
      final double co2SavedKg = impactResults['co2SavedKg'] ?? 0.0;
      final double creditsEarned = impactResults['creditsEarned'] ?? 0.0;
      final double carbonValue = impactResults['carbonValue'] ?? 0.0;

      if (mounted) {
        setState(() {
          print("[TripCalculator] Atualizando estado com resultados...");
          _results = {
            'distance': distanceKm,
            'carbonKg': carbonKg,
            'co2SavedKg': co2SavedKg,
            'creditsEarned': creditsEarned,
            'carbonValue': carbonValue,
            'isElectric': vehicleType == VehicleType.electric || vehicleType == VehicleType.hybrid,
            'origin': originText,
            'destination': destinationText,
            'vehicleId': vehicleId,
            'vehicleType': vehicleType,
          };
          print("[TripCalculator] Estado atualizado com: $_results");
        });
        print("[TripCalculator] Estado atualizado com sucesso.");
      }
    } catch (e, s) {
      print("!!! ERRO GERAL durante cálculo/simulação: $e\n$s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao calcular rota.'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      print("--- [TripCalculator] Finalizando _calculateTrip (finally) ---");
      if (mounted) {
        setState(() { _isCalculating = false; });
      }
    }
  } // Fim _calculateTrip

  Future<void> _saveManualTrip() async {
    print("--- [TripCalculator] Iniciando _saveManualTrip ---");
    if (_results == null) {
      print("[TripCalculator] _saveManualTrip: Nenhum resultado para salvar.");
      return;
    }
    if (_currentUser == null) {
      print("[TripCalculator] _saveManualTrip: Usuário nulo.");
      return;
    }
    if (!mounted) return;

    setState(() { _isLoading = true; });
    await Future.delayed(200.ms);

    try {
      final Map<String, dynamic> tripData = {
        'userId': _currentUser!.uid,
        'vehicleId': _results!['vehicleId'],
        'vehicleType': (_results!['vehicleType'] as VehicleType).name,
        'origin': _results!['origin'],
        'destination': _results!['destination'],
        'distanceKm': _results!['distance'],
        'startTime': Timestamp.now(),
        'endTime': Timestamp.now(),
        'durationMinutes': 0,
        'co2SavedKg': _results!['co2SavedKg'],
        'creditsEarned': _results!['creditsEarned'],
        'calculatedCarbonKg': _results!['carbonKg'],
        'calculatedValue': _results!['carbonValue'],
        'processedForWallet': false,
        'createdAt': FieldValue.serverTimestamp(),
        'calculationMethod': 'manual_route',
      };

      print("[TripCalculator] Salvando viagem manual: $tripData");
      await FirebaseFirestore.instance.collection('trips').add(tripData);
      print("[TripCalculator] Viagem manual salva com sucesso!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viagem calculada registrada!'), backgroundColor: Colors.green),
        );
        _originController.clear();
        _destinationController.clear();
        setState(() {
          _results = null;
          _selectedVehicleDataString = null;
          print("[TripCalculator] Formulário limpo após salvar.");
        });
      }
    } catch (e, s) {
      print("!!! ERRO AO SALVAR VIAGEM MANUAL: $e\n$s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar registro.'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      print("--- [TripCalculator] Finalizando _saveManualTrip (finally) ---");
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  } // Fim _saveManualTrip

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define cores para os indicadores aqui, para fácil acesso
    final Color kmColor = Colors.blueAccent[100]!;
    final Color co2Color = Colors.greenAccent[400]!;
    final Color creditsColor = Colors.lightGreenAccent[400]!;
    final Color valueColorPositive = Colors.greenAccent[400]!; // Para valor > 0 (crédito)
    final Color valueColorNegative = Colors.redAccent[100]!;   // Para valor < 0 (custo)

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Calcular Rota e Impacto',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Dropdown Veículos
              if (_vehiclesLoading)
                const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator(strokeWidth: 2)))
              else if (_vehicleDropdownItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _currentUser == null
                        ? 'Faça login para ver seus veículos.'
                        : 'Nenhum veículo cadastrado.\nAdicione um na aba "Monitorar GPS".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedVehicleDataString,
                  items: _vehicleDropdownItems,
                  onChanged: _isCalculating ? null : (String? newValue) {
                      if (newValue != _selectedVehicleDataString && _results != null) {
                         setState(() => _results = null);
                      }
                      setState(() => _selectedVehicleDataString = newValue);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    isDense: true,
                    labelText: 'Selecione o Veículo *',
                    prefixIcon: Icon(Icons.directions_car_outlined, color: colorScheme.primary.withOpacity(0.8)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Selecione um veículo' : null,
                ),
              const SizedBox(height: 12),

              // Origem/Destino
              TextFormField(
                controller: _originController,
                enabled: !_isCalculating,
                decoration: InputDecoration(
                  labelText: 'Origem *',
                  hintText: 'Endereço ou local de partida',
                  prefixIcon: Icon(Icons.trip_origin, color: theme.hintColor),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationController,
                enabled: !_isCalculating,
                decoration: InputDecoration(
                  labelText: 'Destino *',
                  hintText: 'Endereço ou local de chegada',
                  prefixIcon: Icon(Icons.flag_outlined, color: theme.hintColor),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 20),

              // Botão Calcular/Loading
              _isCalculating
                ? Center(child: Padding(padding: const EdgeInsets.all(8.0), child: SpinKitPulse(color: colorScheme.primary, size: 30.0)))
                : ElevatedButton.icon(
                    onPressed: _calculateTrip,
                    icon: const Icon(Icons.calculate_outlined, size: 20),
                    label: const Text('Calcular Rota e Impacto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),

              // --- Área de Resultados ---
              AnimatedSize(
                duration: 300.ms,
                curve: Curves.easeInOut,
                child: _results != null
                  ? Column(
                      children: [
                        const Divider(height: 30, thickness: 0.5, indent: 20, endIndent: 20),
                        Text('Resultados Estimados:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            // --- Indicadores de Resultado ---
                            // (Usando o IndicatorCard estilo mockup)
                            IndicatorCard(
                              isLoading: _isCalculating, // Pode mostrar shimmer enquanto recalcula
                              title: 'DISTÂNCIA',
                              value: '${_results!['distance']?.toStringAsFixed(1) ?? 'N/A'} km',
                              icon: Icons.route_outlined,
                              accentColor: kmColor, // <<< CORREÇÃO PARÂMETRO
                            ),
                            IndicatorCard(
                              isLoading: _isCalculating,
                              title: _results!['isElectric'] ? 'CO₂ SALVO' : 'IMPACTO CO₂',
                              value: '${(_results!['isElectric'] ? _results!['co2SavedKg'] : _results!['carbonKg'])?.toStringAsFixed(2) ?? 'N/A'} kg',
                              icon: _results!['isElectric'] ? Icons.eco_outlined : Icons.co2, // Usa CO2 padrão
                              // Verde se salvou, cinza claro se emitiu
                              accentColor: (_results!['co2SavedKg'] ?? 0) > 0 ? co2Color : Colors.grey[400]!, // <<< CORREÇÃO PARÂMETRO
                            ),
                            IndicatorCard(
                              isLoading: _isCalculating,
                              title: 'CRÉDITOS GERADOS',
                              value: '${_results!['creditsEarned']?.toStringAsFixed(4) ?? 'N/A'}',
                              icon: Icons.toll_outlined,
                              accentColor: creditsColor, // <<< CORREÇÃO PARÂMETRO
                            ),
                            IndicatorCard(
                              isLoading: _isCalculating,
                              title: 'VALOR MONETÁRIO',
                              value: 'R\$ ${_results!['carbonValue']?.toStringAsFixed(2) ?? 'N/A'}',
                              icon: Icons.paid_outlined,
                              // Verde se positivo/zero (crédito), vermelho se negativo (custo)
                              accentColor: (_results!['carbonValue'] ?? 0) >= 0 ? valueColorPositive : valueColorNegative, // <<< CORREÇÃO PARÂMETRO
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (!_isLoading)
                          Center(
                            child: TextButton.icon(
                              onPressed: _saveManualTrip,
                              icon: const Icon(Icons.save_alt, size: 18),
                              label: const Text('Registrar Viagem Calculada'),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
                            )
                          )
                        else // Mostra loading para salvar
                          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                      ],
                    )
                  : const SizedBox.shrink(),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  } // Fim build
} // Fim classe State