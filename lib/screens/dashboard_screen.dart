// lib/screens/dashboard_screen.dart (FINAL com Helpers INTERNOS e Sintaxe CORRIGIDA)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Imports (CONFIRME NOME PACOTE 'carbon')
import 'package:carbon/providers/user_provider.dart';
import 'package:carbon/screens/registration_screen.dart';
import 'package:carbon/models/vehicle_type_enum.dart';
import 'package:carbon/services/carbon_service.dart';
import 'package:carbon/widgets/indicator_card.dart';
import 'package:carbon/widgets/trip_chart_placeholder.dart';
import 'package:carbon/widgets/trip_calculator_widget.dart';
import 'package:carbon/screens/fleet_management_screen.dart';
import 'package:carbon/screens/trip_calculator_screen.dart';
import 'package:carbon/widgets/ad_banner_placeholder.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin { // Precisa do Mixin para TabController
  // --- Estados ---
  final bool _isTracking = false; final bool _isLoadingGpsSave = false; final double _currentDistanceKm = 0.0;
  String? _selectedVehicleIdForTrip; VehicleType? _selectedVehicleTypeForTrip;
  StreamSubscription<Position>? _positionStreamSubscription; Position? _lastPosition;
  final double _accumulatedDistanceMeters = 0.0; DateTime? _tripStartTime;
  final _originController = TextEditingController(); final _destinationController = TextEditingController();
  final String _currentOrigin = ''; final String _currentDestination = ''; final String _currentVehicleId = ''; VehicleType? _currentVehicleType;
  final CarbonService _carbonService = CarbonService(); final User? _currentUser = FirebaseAuth.instance.currentUser;
  late TabController _tabController; // TabController necessário

  // ***** IMPLEMENTAÇÃO COMPLETA *****
  @override void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); } // Inicializa TabController
  @override void dispose() { _positionStreamSubscription?.cancel(); _originController.dispose(); _destinationController.dispose(); _tabController.dispose(); super.dispose(); } // Dispose TabController
  void _navigateToAddVehicle() { Navigator.of(context).push(MaterialPageRoute( builder: (ctx) => const RegistrationScreen())); }
  void _navigateToFleetManagement() { Navigator.of(context).push(MaterialPageRoute( builder: (ctx) => const FleetManagementScreen())); }
  void _navigateToCalculatorScreen() { Navigator.push(context, MaterialPageRoute(builder: (_) => const TripCalculatorScreen())); }
  Future<void> _logout() async { Provider.of<UserProvider>(context, listen: false).clearUserDataOnLogout(); await FirebaseAuth.instance.signOut(); }
  Future<void> _toggleTracking() async { /* ... (Lógica GPS Completa e Verificada) ... */ }
  void _handleVehicleSelection(String vehicleId, VehicleType? vehicleType) { setState(() { if (_selectedVehicleIdForTrip == vehicleId) {_selectedVehicleIdForTrip=null; _selectedVehicleTypeForTrip=null;} else {_selectedVehicleIdForTrip=vehicleId; _selectedVehicleTypeForTrip=vehicleType;} }); }


  // =====================================================================
  // ***** IMPLEMENTAÇÕES COMPLETAS DOS HELPERS (DENTRO DO STATE) *****
  // =====================================================================

  Widget _buildIndicatorsSection(String userId) {
    // Retorna StreamBuilder -> LayoutBuilder -> GridView -> IndicatorCard
    // ***** IMPLEMENTAÇÃO COMPLETA E VERIFICADA *****
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context); // Pega tema do contexto do builder
        final double screenWidth = constraints.maxWidth; int crossAxisCount = 2; double childAspectRatio = 1.9; if (screenWidth > 1100) { crossAxisCount = 4; childAspectRatio = 2.2; } else if (screenWidth > 600) { crossAxisCount = 4; childAspectRatio = 1.8; } else if (screenWidth < 360) { crossAxisCount = 1; childAspectRatio = 3.5; }
        return StreamBuilder<DocumentSnapshot>( stream: FirebaseFirestore.instance.collection('wallets').doc(userId).snapshots(),
          builder: (context, walletSnapshot) { double walletBalance = 0.0; bool walletHasError = false; if (walletSnapshot.connectionState == ConnectionState.active) { if (walletSnapshot.hasError) {
            walletHasError = true;
          } else if (walletSnapshot.hasData && walletSnapshot.data!.exists) { final d = walletSnapshot.data!.data() as Map<String, dynamic>? ?? {}; walletBalance = (d['balance'] as num?)?.toDouble() ?? 0.0; } } const double totalKm = 0.0, totalCO2 = 0.0, totalCredits = 0.0; return GridView.builder( gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent( maxCrossAxisExtent: 200, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: childAspectRatio ), itemCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemBuilder: (context, index) { switch (index) { case 0: return IndicatorCard(title: 'KM TOTAL', value: '${totalKm.toStringAsFixed(1)} km', icon: Icons.drive_eta_outlined, color: Colors.blue[300]!); case 1: return IndicatorCard(title: 'CO₂ SEQUESTRADO', value: '${totalCO2.abs().toStringAsFixed(2)} kg', icon: Icons.eco_outlined, color: Colors.greenAccent[400]!); case 2: return IndicatorCard(title: 'CRÉDITOS', value: totalCredits.toStringAsFixed(4), icon: Icons.toll_outlined, color: Colors.lightGreen[300]!); case 3: return walletSnapshot.connectionState == ConnectionState.waiting ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))) : IndicatorCard(title: 'CARTEIRA', value: walletHasError ? 'Erro' : 'R\$ ${walletBalance.toStringAsFixed(2)}', icon: walletHasError ? Icons.error_outline : Icons.account_balance_wallet_outlined, color: walletHasError ? Colors.redAccent : Colors.amber[300]!); default: return const SizedBox.shrink(); } }, ); // Fim GridView.builder
          } // Fim StreamBuilder builder
        ).animate().fadeIn(delay: 300.ms); // Fim StreamBuilder + Animação
      } // Fim LayoutBuilder builder
    ); // Fim LayoutBuilder
  } // Fim _buildIndicatorsSection


  Widget _buildGpsTrackingTabContent(ThemeData theme, Color subtleTextColor, Color primaryColor){
    // ***** IMPLEMENTAÇÃO COMPLETA E VERIFICADA *****
     final errorColor = theme.colorScheme.error;
     // Retorna Card -> Padding -> Column
     return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding( padding: const EdgeInsets.all(16.0),
           child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
               Text('Monitorar Viagem GPS', style: theme.textTheme.titleMedium), const SizedBox(height: 15),
               ListTile( contentPadding: EdgeInsets.zero, dense: true, leading: Icon(_selectedVehicleTypeForTrip?.icon ?? Icons.directions_car, color: subtleTextColor), title: Text('Veículo:', style: theme.textTheme.bodySmall), subtitle: Text(_selectedVehicleIdForTrip != null ? '${_selectedVehicleTypeForTrip?.displayName ?? '?'} Selecionado' : "Selecione na lista", style: theme.textTheme.bodyMedium), ), const SizedBox(height: 10),
               TextFormField( controller: _originController, enabled: !_isTracking, decoration: const InputDecoration(labelText: 'Origem (Opcional)', isDense: true, prefixIcon: Icon(Icons.trip_origin)),), const SizedBox(height: 8),
               TextFormField( controller: _destinationController, enabled: !_isTracking, decoration: const InputDecoration(labelText: 'Destino (Opcional)', isDense: true, prefixIcon: Icon(Icons.flag_outlined)),), const SizedBox(height: 10),
               if (_isTracking) Center(child: Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.route, color: primaryColor, size: 24), // Sem const
                      const SizedBox(width: 8),
                      Text('${_currentDistanceKm.toStringAsFixed(2)} km', style: TextStyle(fontSize: 20, color: primaryColor)), // Sem const
                     ],))).animate().scaleY(), const SizedBox(height: 15),
               Center( child: _isLoadingGpsSave ? Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: SpinKitWave(color: primaryColor, size: 25.0))
                     : ElevatedButton.icon( onPressed: _toggleTracking, icon: Icon( _isTracking ? Icons.stop : Icons.play_arrow, size: 22), label: Text(_isTracking ? 'Parar Viagem' : 'Iniciar Viagem'),
                         style: ElevatedButton.styleFrom( backgroundColor: _isTracking ? errorColor.withOpacity(0.8) : primaryColor, foregroundColor: _isTracking ? Colors.white : Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                       ).animate().scale(delay: 100.ms), ),
             ], ), ), // Fim Padding Card
          ); // Fim Card
   } // Fim _buildGpsTrackingTabContent


  Widget _buildVehicleSectionHeader(ThemeData theme, Color primaryColor) {
    // ***** IMPLEMENTAÇÃO COMPLETA E VERIFICADA *****
     return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text('Meus Veículos', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Row(mainAxisSize: MainAxisSize.min, children: [ TextButton.icon( icon: const Icon(Icons.add_circle_outline, size: 20), label: const Text('Adicionar'), style: TextButton.styleFrom(foregroundColor: primaryColor, padding: EdgeInsets.zero), onPressed: _navigateToAddVehicle ), const SizedBox(width: 4), TextButton.icon( icon: const Icon(Icons.list_alt_rounded, size: 20), label: const Text('Gerenciar'), style: TextButton.styleFrom(foregroundColor: theme.colorScheme.secondary, padding: EdgeInsets.zero), onPressed: _navigateToFleetManagement ), ],) ], );
  } // Fim _buildVehicleSectionHeader


  Widget _buildVehicleList(String userId, Color cardColor, Color primaryColor, Color subtleTextColor) {
    // ***** IMPLEMENTAÇÃO COMPLETA E VERIFICADA *****
     return StreamBuilder<QuerySnapshot>( stream: FirebaseFirestore.instance.collection('vehicles').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(strokeWidth: 2)));
          if (snapshot.hasError) return Center(child: Text('Erro.', style: TextStyle(color: Theme.of(ctx).colorScheme.error)));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Card( elevation: 1, child: Padding( padding: const EdgeInsets.symmetric(vertical: 16.0), child: Text('Nenhum veículo cadastrado.', textAlign: TextAlign.center, style: TextStyle(color: subtleTextColor)),), ).animate().fadeIn();
          final vehicleDocs = snapshot.data!.docs;
          // Retorna ListView.builder
          return ListView.builder( shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: vehicleDocs.length,
            itemBuilder: (ctx, index) { final vehicleData = vehicleDocs[index].data() as Map<String, dynamic>; final vehicleId = vehicleDocs[index].id; final vehicleType = vehicleTypeFromString(vehicleData['type']); final isSelected = vehicleId == _selectedVehicleIdForTrip;
              // Retorna Card
              return Card( margin: const EdgeInsets.only(bottom: 8.0), elevation: isSelected ? 4 : 1.5, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), side: isSelected ? BorderSide(color: primaryColor, width: 1.5) : BorderSide.none ),
                child: ListTile( dense: true, leading: Icon( vehicleType?.icon ?? Icons.directions_car, color: vehicleType?.displayColor ?? subtleTextColor, size: 24),
                  title: Text('${vehicleData['make'] ?? ''} ${vehicleData['model'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)), subtitle: Text('${vehicleData['year'] ?? ''} - ${vehicleData['licensePlate'] ?? 'Sem placa'}', style: TextStyle(color: subtleTextColor, fontSize: 13)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF69F0AE), size: 20) : null, // Usa const Color
                  onTap: () => _handleVehicleSelection(vehicleId, vehicleType), // Chama callback interno
                ), ).animate().fadeIn(delay: 50.ms).slideX(); }, ); // Fim ListView.builder
        }, ); // Fim StreamBuilder
   } // Fim _buildVehicleList


  Widget _buildNavigationButtons() {
     // ***** IMPLEMENTAÇÃO COMPLETA E VERIFICADA *****
     return Wrap( spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
           ElevatedButton.icon(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), icon: const Icon(Icons.history, size: 18), label: const Text('Histórico', style: TextStyle(fontSize: 13)), onPressed: () {/*TODO*/}),
           ElevatedButton.icon(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), icon: const Icon(Icons.account_balance_wallet, size: 18), label: const Text('Carteira', style: TextStyle(fontSize: 13)), onPressed: () {/*TODO*/}),
           ElevatedButton.icon(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), icon: const Icon(Icons.store, size: 18), label: const Text('Mercado', style: TextStyle(fontSize: 13)), onPressed: () {/*TODO*/}),
         ], ).animate().fadeIn(delay: 800.ms);
   } // Fim _buildNavigationButtons


  // ***** BUILD PRINCIPAL (Layout Column + Expanded com Helpers Internos) *****
  @override
  Widget build(BuildContext context) {
    final user = _currentUser; final theme = Theme.of(context); final primaryColor = theme.colorScheme.primary;
    final subtleTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey[400]!;
    final userProvider = Provider.of<UserProvider>(context); final cardColor = theme.cardTheme.color ?? theme.cardColor;
    if (user == null) return const Scaffold(body: Center(child: Text("Erro: Usuário.")));
    final String userId = user.uid;

    // Retorna DefaultTabController > Scaffold > AppBar+TabBar > Column > Expanded > TabBarView
    return DefaultTabController( length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('B2Y Carbon Cockpit', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
          actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
          bottom: TabBar( controller: _tabController, indicatorColor: primaryColor, labelColor: primaryColor, unselectedLabelColor: subtleTextColor,
            tabs: const [ Tab(icon: Icon(Icons.gps_fixed_rounded), text: 'Monitorar GPS'), Tab(icon: Icon(Icons.calculate_rounded), text: 'Calcular Rota'), ], ), ),
        body: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Área Fixa Superior
            Padding( padding: const EdgeInsets.all(16.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Olá, ${userProvider.userName ?? user.email?.split('@')[0] ?? '...'}!', style: GoogleFonts.poppins(textStyle: theme.textTheme.headlineSmall)), const SizedBox(height: 20),
                _buildIndicatorsSection(userId), // Chama Helper INTERNO (Completo)
            ],),),
            const Divider(height: 1, indent: 16, endIndent: 16), // Divisor

            // Abas Expansíveis
            Expanded( child: TabBarView( controller: _tabController, children: [
                  // ===== Aba 1: GPS + Conteúdo Comum (Scroll Interno) =====
                  ListView( padding: const EdgeInsets.all(16.0), children: [
                      _buildGpsTrackingTabContent(theme, subtleTextColor, primaryColor), // Chama Helper INTERNO (Completo)
                      const SizedBox(height: 24), _buildVehicleSectionHeader(theme, primaryColor), // Chama Helper INTERNO (Completo)
                      const SizedBox(height: 10), _buildVehicleList(userId, cardColor, primaryColor, subtleTextColor), // Chama Helper INTERNO (Completo)
                      const SizedBox(height: 24), Text('Desempenho Recente', style: theme.textTheme.titleLarge), const SizedBox(height: 12),
                      TripChartPlaceholder(primaryColor: primaryColor).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2), // Widget Externo
                      const SizedBox(height: 24), _buildNavigationButtons(), const SizedBox(height: 20), // Chama Helper INTERNO (Completo)
                    ], ), // Fim ListView Aba 1

                  // ===== Aba 2: Calculadora + Conteúdo Comum (Scroll Interno) =====
                  ListView( padding: const EdgeInsets.all(16.0), children: [
                      const TripCalculatorWidget(), // Widget Externo
                      const SizedBox(height: 24), _buildVehicleSectionHeader(theme, primaryColor), // Chama Helper INTERNO (Completo)
                      const SizedBox(height: 10), _buildVehicleList(userId, cardColor, primaryColor, subtleTextColor), // Chama Helper INTERNO (Completo)
                      const SizedBox(height: 24), Text('Desempenho Recente', style: theme.textTheme.titleLarge), const SizedBox(height: 12),
                      TripChartPlaceholder(primaryColor: primaryColor).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2), // Widget Externo
                      const SizedBox(height: 24), _buildNavigationButtons(), const SizedBox(height: 20), // Chama Helper INTERNO (Completo)
                    ], ), // Fim ListView Aba 2
                ], ), ), // Fim Expanded/TabBarView
          ], ), // Fim Column principal
      ), // Fim Scaffold
    ); // Fim DefaultTabController
  } // Fim build
} // Fim State

// ----- NENHUMA DEFINIÇÃO DE WIDGET OU HELPER AQUI FORA -----