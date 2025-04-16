// lib/models/vehicle_type_enum.dart (CORRIGIDO Const Colors e Icon)
import 'package:flutter/material.dart';

enum VehicleType {
  electric('Elétrico', Icons.electric_bolt_outlined, Colors.lightBlueAccent), // OK: MaterialAccentColor é const
  gasoline('Gasolina', Icons.local_gas_station_outlined, Colors.orangeAccent), // OK: MaterialAccentColor é const
  alcohol('Álcool', Icons.local_drink_outlined, const Color(0xFFE040FB)), // Roxo A200 (Valor Hex ARGB)
  diesel('Diesel', Icons.opacity_outlined, const Color(0xFFA0A0A0)),        // Cinza customizado
  flex('Flex (Álcool/Gasolina)', Icons.sync_alt_outlined, const Color(0xFFEEFF41)), // Amarelo Lima A200 (CORRIGIDO ÍCONE e COR)
  hybrid('Híbrido', Icons.settings_input_component_outlined, const Color(0xFF64FFDA)); // Teal A400

  // Construtor const é obrigatório para enum com campos final
  const VehicleType(this.displayName, this.icon, this.displayColor);
  final String displayName;
  final IconData icon;
  final Color displayColor;
}

// Helper para obter enum a partir de string (sem alterações)
VehicleType? vehicleTypeFromString(String? typeString) {
  if (typeString == null) return null;
  for (VehicleType type in VehicleType.values) {
    if (type.name == typeString) return type;
  }
  return null;
}