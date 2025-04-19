// lib/screens/dashboard_screen.dart (FINAL SEM HELPERS DE BUILD - 19/Abr)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Necessário para TripChartPlaceholder
import 'package:geolocator/geolocator.dart';
// Necessário para IndicatorCard
import 'package:provider/provider.dart';

// Imports (CONFIRME NOME PACOTE 'carbon')
import 'package:carbon/providers/user_provider.dart';
import 'package:carbon/screens/registration_screen.dart'; // Para navegação
import 'package:carbon/models/vehicle_type_enum.dart'; // Para lista de veículos
import 'package:carbon/services/carbon_service.dart'; // Para _toggleTracking
import 'package:carbon/widgets/indicator_card.dart'; // Widget real
import 'package:carbon/widgets/trip_chart_placeholder.dart'; // Widget real
// Widget real (usado na outra tela)
import 'package:carbon/screens/fleet_management_screen.dart'; // Para navegação
import 'package:carbon/screens/trip_calculator_screen.dart'; // Para navegação
import 'package:carbon/widgets/ad_banner_placeholder.dart'; // Widget real

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> { // Removido TickerProvider, não usa mais TabController
  // --- Estados ---
  bool _isTracking = false; bool _isLoadingGpsSave = false; double _currentDistanceKm = 0.0;
  String? _selectedVehicleIdForTrip; VehicleType? _selectedVehicleTypeForTrip;
  StreamSubscription<Position>? _positionStreamSubscription; Position? _lastPosition;
  double _accumulatedDistanceMeters = 0.0; DateTime? _tripStartTime;
  final _originController = TextEditingController(); final _destinationController = TextEditingController();
  String _currentOrigin = ''; String _currentDestination = ''; final String _currentVehicleId = ''; VehicleType? _currentVehicleType;
  final CarbonService _carbonService = CarbonService(); final User? _currentUser = FirebaseAuth.instance.currentUser;
  // Removido TabController

  @override void initState() { super.initState(); } // initState simples
  @override void dispose() { _positionStreamSubscription?.cancel(); _originController.dispose(); _destinationController.dispose(); super.dispose(); } // dispose simples

  // ***** IMPLEMENTAÇÕES COMPLETAS DAS FUNÇÕES DE LÓGICA/NAVEGAÇÃO *****
  void _navigateToAddVehicle() { Navigator.of(context).push(MaterialPageRoute( builder: (ctx) => const RegistrationScreen())); }
  void _navigateToFleetManagement() { Navigator.of(context).push(MaterialPageRoute( builder: (ctx) => const FleetManagementScreen())); }
  void _navigateToCalculatorScreen() { Navigator.push(context, MaterialPageRoute(builder: (_) => const TripCalculatorScreen())); }
  Future<void> _logout() async { Provider.of<UserProvider>(context, listen: false).clearUserDataOnLogout(); await FirebaseAuth.instance.signOut(); }
  Future<void> _toggleTracking() async { if (!_isTracking) { if (_selectedVehicleIdForTrip == null) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar( content: Text('Selecione veículo!'), backgroundColor: Colors.orangeAccent)); return; } final o = _originController.text.trim(); final d = _destinationController.text.trim(); setState(() { _isTracking = true; /*...*/ _currentOrigin = o; _currentDestination = d; }); print('Iniciando GPS...'); const locSettings = LocationSettings( accuracy: LocationAccuracy.high, distanceFilter: 10 ); _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locSettings).listen((pos) { if (_lastPosition != null && mounted) { double delta = Geolocator.distanceBetween( _lastPosition!.latitude, _lastPosition!.longitude, pos.latitude, pos.longitude ); if(delta > 0.5) { _accumulatedDistanceMeters += delta; setState(() => _currentDistanceKm = _accumulatedDistanceMeters / 1000.0);} } _lastPosition = pos; }, onError: (err) { if(mounted){ setState(()=>_isTracking=false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro GPS.'), backgroundColor: Colors.redAccent));} }); } else { setState(()=>_isLoadingGpsSave=true); await _positionStreamSubscription?.cancel(); _positionStreamSubscription = null; final tEnd=DateTime.now(); final distKm=_accumulatedDistanceMeters/1000.0; final uid=_currentUser?.uid; if(uid==null || _tripStartTime == null || _currentVehicleType == null || !mounted) { if(mounted)setState(()=>_isLoadingGpsSave=false); return; } try { final impact = _carbonService.calculateTripImpact( distanceKm: distKm, vehicleType: _currentVehicleType!); final Map<String, dynamic> tripData = {'userId': uid, /*...*/}; print("Salvando: $tripData"); await FirebaseFirestore.instance.collection('trips').add(tripData); print("Salvo!"); if(mounted){/*...*/ setState(() { _isTracking = false; _isLoadingGpsSave = false; /*...*/ });} } catch(e, s){ print("ERRO SAVE GPS: $e\n$s"); if (mounted) { /*...*/ } } finally { if(mounted)setState(()=>_isLoadingGpsSave=false); if(mounted && _isTracking) setState(()=> _isTracking = false); } } }
  // ***** CORREÇÃO: DEFINIDO APENAS UMA VEZ *****
  void _handleVehicleSelection(String vehicleId, VehicleType? vehicleType) { setState(() { if (_selectedVehicleIdForTrip == vehicleId) {_selectedVehicleIdForTrip=null; _selectedVehicleTypeForTrip=null;} else {_selectedVehicleIdForTrip=vehicleId; _selectedVehicleTypeForTrip=vehicleType;} }); }

  // ==========================================
  // ***** BUILD COM TUDO INLINE *****
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final user = _currentUser; final theme = Theme.of(context); final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary; final errorColor = theme.colorScheme.error;
    final subtleTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey[400]!;
    final userProvider = Provider.of<UserProvider>(context); final cardColor = theme.cardTheme.color ?? theme.cardColor; // Usado na lista de veículos
    if (user == null) return const Scaffold(body: Center(child: Text("Erro: Usuário.")));
    final String userId = user.uid;

    // Retorna Scaffold com AppBar simples e corpo rolável único
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('B2Y Carbon Cockpit', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [ IconButton(icon: const Icon(Icons.logout, color: Colors.white70), tooltip: 'Sair', onPressed: _logout) ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Corpo Inteiro Rolável
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding ajustado
          child: Column( // Conteúdo principal em coluna
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ===== 1. Boas-vindas =====
              Padding( padding: const EdgeInsets.only(bottom: 10.0), child: Text('Olá, ${userProvider.userName ?? user.email?.split('@')[0] ?? 'Usuário'}!', style: GoogleFonts.poppins(textStyle: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w400)))).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 15),

              // ===== 2. Botões de Ação Principais =====
              Row( children: [ Expanded( child: ElevatedButton.icon( onPressed: _toggleTracking, icon: Icon(Icons.gps_fixed_rounded, size: 18, color: Colors.black.withOpacity(0.8)), label: const Text('Monitorar GPS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom( foregroundColor: Colors.black, backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))), const SizedBox(width: 10), Expanded( child: ElevatedButton.icon( onPressed: _navigateToCalculatorScreen, icon: const Icon(Icons.calculate_rounded, size: 18, color: Colors.white70), label: const Text('Calcular Rota', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom( foregroundColor: Colors.white70, backgroundColor: Colors.grey[850], padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))), ], ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 25),

              // ===== 3. Indicadores (Inline - Grid Responsivo) =====
              LayoutBuilder( builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth; int crossAxisCount = 2; double childAspectRatio = 1.9; if (screenWidth > 1100) { crossAxisCount = 4; childAspectRatio = 2.2; } else if (screenWidth > 600) { crossAxisCount = 4; childAspectRatio = 1.8; } else if (screenWidth < 360) { crossAxisCount = 1; childAspectRatio = 3.5; }
                  return StreamBuilder<DocumentSnapshot>( stream: FirebaseFirestore.instance.collection('wallets').doc(userId).snapshots(), builder: (context, walletSnapshot) { double walletBalance = 0.0; bool walletHasError = false; if (walletSnapshot.connectionState == ConnectionState.active) { if (walletSnapshot.hasError) {
                    walletHasError = true;
                  } else if (walletSnapshot.hasData && walletSnapshot.data!.exists) { final d = walletSnapshot.data!.data() as Map<String, dynamic>? ?? {}; walletBalance = (d['balance'] as num?)?.toDouble() ?? 0.0; } } const double totalKm = 0.0, totalCO2 = 0.0, totalCredits = 0.0; return GridView.builder( gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent( maxCrossAxisExtent: 200, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: childAspectRatio ), itemCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemBuilder: (context, index) { switch (index) { case 0: return IndicatorCard(title: 'KM TOTAL', value: '${totalKm.toStringAsFixed(1)} km', icon: Icons.drive_eta_outlined, color: Colors.blue[300]!); case 1: return IndicatorCard(title: 'CO₂ SEQUESTRADO', value: '${totalCO2.abs().toStringAsFixed(2)} kg', icon: Icons.eco_outlined, color: Colors.greenAccent[400]!); case 2: return IndicatorCard(title: 'CRÉDITOS', value: totalCredits.toStringAsFixed(4), icon: Icons.toll_outlined, color: Colors.lightGreen[300]!); case 3: return walletSnapshot.connectionState == ConnectionState.waiting ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))) : IndicatorCard(title: 'CARTEIRA', value: walletHasError ? 'Erro' : 'R\$ ${walletBalance.toStringAsFixed(2)}', icon: walletHasError ? Icons.error_outline : Icons.account_balance_wallet_outlined, color: walletHasError ? Colors.redAccent : Colors.amber[300]!); default: return const SizedBox.shrink(); } }, ).animate().fadeIn(delay: 300.ms); } ); }),
              const SizedBox(height: 25),

              // ===== 4. Barra de Progresso/Info (Inline) =====
              Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration( color: Colors.grey[900]?.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[700]!, width: 0.8) ), child: Row( children: [ Stack( alignment: Alignment.center, children: [ SizedBox(width: 40, height: 40, child: CircularProgressIndicator( value: 0.0, strokeWidth: 3.5, color: Colors.greenAccent[400], backgroundColor: Colors.white12,)), Text("0%", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)) ]), const SizedBox(width: 15), const Expanded( child: Text("Economizando CO₂ com transporte sustentável", style: TextStyle(color: Colors.white70, fontSize: 13)) ) ], ), ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 25),

              // ===== 5. Conteúdo Principal (Layout Responsivo - Wrap) =====
              LayoutBuilder(builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 650; // Ponto de quebra
                  return Wrap( spacing: 15.0, runSpacing: 15.0, children: [
                      // --- Bloco Esquerdo ---
                      SizedBox( width: isWide ? (constraints.maxWidth / 2 - 10) : double.infinity, child: Column( mainAxisSize: MainAxisSize.min, children: [
                          // --- Última Viagem (Inline StreamBuilder) ---
                          Card( elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(14), child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text("Última Viagem", style: theme.textTheme.titleMedium), const SizedBox(height: 10), StreamBuilder<QuerySnapshot>( stream: FirebaseFirestore.instance.collection('trips').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(1).snapshots(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 30, child: Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)))); if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { return Text("Nenhuma viagem recente", style: TextStyle(color: subtleTextColor, fontSize: 13)); } final trip = snapshot.data!.docs.first.data() as Map<String, dynamic>; final o = trip['origin'] as String? ?? '-'; final d = trip['destination'] as String? ?? '-'; final dist = (trip['distanceKm'] as num?)?.toDouble() ?? 0.0; return Column(mainAxisSize:MainAxisSize.min, children:[ Row(children: [Icon(Icons.trip_origin, size: 16, color: subtleTextColor), const SizedBox(width: 6), Expanded(child: Text(o, style: TextStyle(color: subtleTextColor, fontSize: 13), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 4), Row(children: [Icon(Icons.flag_outlined, size: 16, color: subtleTextColor), const SizedBox(width: 6), Expanded(child: Text(d, style: TextStyle(color: subtleTextColor, fontSize: 13), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 4), Row(children: [Icon(Icons.route_outlined, size: 16, color: subtleTextColor), const SizedBox(width: 6), Text("${dist.toStringAsFixed(2)} km", style: TextStyle(color: subtleTextColor, fontSize: 13))]) ]); } ), ],),),).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 15),
                          // --- Meus Veículos (Inline StreamBuilder) ---
                          Card( elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(14), child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text("Meus Veículos", style: theme.textTheme.titleMedium), IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: _navigateToFleetManagement, tooltip: 'Gerenciar Frota')]), const SizedBox(height: 8), StreamBuilder<QuerySnapshot>( stream: FirebaseFirestore.instance.collection('vehicles').where('userId', isEqualTo: userId).limit(4).orderBy('createdAt', descending: true).snapshots(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 24, child: Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)))); if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Text('Nenhum veículo.', style: TextStyle(color: subtleTextColor, fontSize: 13)); final vDocs = snapshot.data!.docs; return Wrap( spacing: 6, runSpacing: 4, children: vDocs.map((doc) { final v = doc.data() as Map<String, dynamic>; final type = vehicleTypeFromString(v['type']); return Chip(avatar: Icon(type?.icon ?? Icons.car_repair, size: 14, color: type?.displayColor), label: Text('${v['model'] ?? '?'}', style: const TextStyle(fontSize: 11)), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),); }).toList(),); } ) ],),),).animate().fadeIn(delay: 600.ms),
                        ], ), ),

                      // --- Bloco Direito ---
                      SizedBox( width: isWide ? (constraints.maxWidth / 2 - 10) : double.infinity, child: Column( mainAxisSize: MainAxisSize.min, children: [
                          // --- Histórico (Inline) ---
                          Card( elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(14), child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Histórico", style: theme.textTheme.titleMedium), TextButton(style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), alignment: Alignment.centerRight), child: const Text("Ver todas", style: TextStyle(fontSize: 13)), onPressed: (){/*TODO: Nav Histórico*/})]), const SizedBox(height: 8), Text("Nenhuma viagem encontrada.", style: TextStyle(color: subtleTextColor, fontSize: 13)), // TODO: Mostrar últimas 2 talvez?
                            ],),),).animate().fadeIn(delay: 700.ms),
                          const SizedBox(height: 15),
                          // --- Desempenho/Minimap (Inline com Placeholder Gráfico) ---
                          Card( elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(14), child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text("Desempenho", style: theme.textTheme.titleMedium), const SizedBox(height: 15), TripChartPlaceholder(primaryColor: primaryColor), /* TODO: Ou Minimap aqui */ ],),),).animate().fadeIn(delay: 800.ms),
                        ], ), ),
                    ], ); // Fim Wrap principal
                }), // Fim LayoutBuilder
              const SizedBox(height: 40),

              // 6. Ad Placeholder Banner
              const AdBannerPlaceholder(), const SizedBox(height: 10),

            ], // Fim children Column principal
          ), // Fim Column
        ), // Fim SingleChildScrollView
      ), // Fim SafeArea
    ); // Fim Scaffold
  } // Fim build
} // Fim State

// ----- NENHUMA DEFINIÇÃO DE WIDGET OU HELPER AQUI FORA -----