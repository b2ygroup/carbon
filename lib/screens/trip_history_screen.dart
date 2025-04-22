// lib/screens/trip_history_screen.dart (NOVO ARQUIVO)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:carbon/models/vehicle_type_enum.dart'; // Para ícones e nomes dos veículos

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final subtleTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey[600]!;

    if (user == null) {
      // Caso o usuário seja nulo (não deveria acontecer se a navegação for protegida)
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico de Viagens')),
        body: const Center(child: Text('Erro: Usuário não autenticado.')),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Viagens'),
        elevation: 1.0, // Sombra sutil
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream para buscar as viagens do usuário logado
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true) // Ordena pelas mais recentes primeiro
            .snapshots(),
        builder: (context, snapshot) {
          // --- Estado de Carregamento ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Estado de Erro ---
          if (snapshot.hasError) {
            print("Erro ao carregar histórico: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
                  const SizedBox(height: 16),
                  const Text('Ocorreu um erro ao carregar o histórico.'),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          // --- Estado Sem Dados ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_outlined, color: subtleTextColor, size: 50),
                  const SizedBox(height: 16),
                  const Text('Nenhuma viagem registrada ainda.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Use a função "Monitorar GPS" para salvar suas viagens.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtleTextColor),
                  ),
                ],
              ),
            );
          }

          // --- Estado com Dados ---
          final tripDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0), // Espaçamento geral da lista
            itemCount: tripDocs.length,
            itemBuilder: (context, index) {
              final tripData = tripDocs[index].data() as Map<String, dynamic>;
              final tripId = tripDocs[index].id; // ID do documento, se precisar

              // Extrai e formata os dados da viagem
              final DateTime? startTime = (tripData['startTime'] as Timestamp?)?.toDate();
              final DateTime? endTime = (tripData['endTime'] as Timestamp?)?.toDate();
              final double distanceKm = (tripData['distanceKm'] as num?)?.toDouble() ?? 0.0;
              final double co2SavedKg = (tripData['co2SavedKg'] as num?)?.toDouble() ?? 0.0;
              final double creditsEarned = (tripData['creditsEarned'] as num?)?.toDouble() ?? 0.0;
              final int durationMinutes = (tripData['durationMinutes'] as num?)?.toInt() ?? 0;
              final String origin = tripData['origin'] ?? 'Não informado';
              final String destination = tripData['destination'] ?? 'Não informado';
              final String vehicleTypeStr = tripData['vehicleType'] ?? '';
              final VehicleType? vehicleType = vehicleTypeFromString(vehicleTypeStr); // Tenta converter string para enum

              // Formatação de Data e Hora
              final String formattedDate = startTime != null
                  ? DateFormat('dd/MM/yyyy').format(startTime)
                  : 'Data inválida';
              final String formattedTime = startTime != null
                  ? DateFormat('HH:mm').format(startTime)
                  : '--:--';
              final String durationStr = '$durationMinutes min';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha 1: Data, Hora e Duração
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: subtleTextColor),
                              const SizedBox(width: 6),
                              Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time, size: 16, color: subtleTextColor),
                              const SizedBox(width: 4),
                              Text(formattedTime),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(durationStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Linha 2: Origem e Destino
                      if(origin != 'Não informado' || destination != 'Não informado')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                             children: [
                                Icon(Icons.location_on_outlined, size: 18, color: subtleTextColor),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$origin  ➔  $destination', overflow: TextOverflow.ellipsis, style: TextStyle(color: subtleTextColor, fontSize: 13))),
                             ],
                          )
                        ),


                      // Linha 3: Veículo e Distância
                      Row(
                        children: [
                          Icon(vehicleType?.icon ?? Icons.directions_car, size: 20, color: vehicleType?.displayColor ?? theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(vehicleType?.displayName ?? vehicleTypeStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(), // Empurra a distância para a direita
                          Icon(Icons.route_outlined, size: 18, color: theme.primaryColor),
                          const SizedBox(width: 4),
                          Text('${distanceKm.toStringAsFixed(1)} km', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Linha 4: CO2 e Créditos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           // CO2
                           Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco, size: 18, color: Colors.green[600]),
                              const SizedBox(width: 6),
                              Text('${co2SavedKg.toStringAsFixed(2)} kg CO₂', style: TextStyle(color: Colors.green[800], fontSize: 13)),
                            ],
                           ),
                           // Créditos
                           Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Icon(Icons.toll, size: 18, color: Colors.amber[700]),
                               const SizedBox(width: 6),
                               Text('${creditsEarned.toStringAsFixed(4)} Créditos', style: TextStyle(color: Colors.amber[900], fontSize: 13)),
                            ],
                           )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}