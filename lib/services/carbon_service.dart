// lib/services/carbon_service.dart (Cálculo Atualizado com Fatores do Usuário)
import 'package:carbon/models/vehicle_type_enum.dart'; // CONFIRME NOME PACOTE

class CarbonService {

  // --- Fatores de Emissão (kg CO2e / litro) - BASEADO NO SEU CÓDIGO ---
  static const double _kgCO2e_per_Liter_GasolineUser = 0.75 * 0.82 * 3.7; // ~2.2755
  static const double _kgCO2e_per_Liter_EthanolUser = 0.75 * 0.82 * 1.5;   // ~0.9225 (Considerar ciclo de vida?)
  static const double _kgCO2e_per_Liter_DieselUser = 0.85 * 0.84 * 3.2;   // ~2.2848

  // --- Consumo Médio (km / litro) - PLACEHOLDERS (Manter?) ---
  // Estes ainda são necessários para calcular emissão por KM
  static const double _km_per_Liter_GasolineC = 12.0;
  static const double _km_per_Liter_Ethanol = 8.0;
  static const double _km_per_Liter_DieselS10 = 15.0;
  static const double _km_per_Liter_Flex_Avg = (_km_per_Liter_GasolineC + _km_per_Liter_Ethanol) / 2;

  // --- Fatores Elétrico/Híbrido ---
  static const double _gridEmissionFactorKgPerKWh = 0.07; // Manter Exemplo Brasil
  static const double _evConsumptionKWhPerKm = 0.15;    // Manter Exemplo EV

  // --- Preço Carbono (R$ / ton CO2e) - PLACEHOLDER ---
  static const double _carbonPricePerTon = 55.50; // Manter Exemplo

  // --- Linha Base Média para EV (kg CO2e / km) - RECALCULADO ---
  static final double _avgBaselineKgCO2ePerKm = _calculateAverageBaseline();

  static double _calculateAverageBaseline() {
    const gasKm = (_kgCO2e_per_Liter_GasolineUser / _km_per_Liter_GasolineC);   // ~0.1896
    const ethKm = (_kgCO2e_per_Liter_EthanolUser / _km_per_Liter_Ethanol);     // ~0.1153
    const dslKm = (_kgCO2e_per_Liter_DieselUser / _km_per_Liter_DieselS10);   // ~0.1523
    return (gasKm + ethKm + dslKm) / 3.0; // Média simples: ~0.1524 kg/km
  }

  /// Calcula o impacto de carbono (kg CO2e), valor monetário (R$) e créditos (kg CO2e * 0.1).
  Map<String, double> calculateTripImpact({
    required double distanceKm,
    required VehicleType vehicleType, // Usa nosso Enum existente
  }) {
    double carbonKg = 0;

    // Mapeia nosso Enum para a lógica baseada no seu código
    switch (vehicleType) {
      case VehicleType.gasoline:
        carbonKg = (distanceKm / _km_per_Liter_GasolineC) * _kgCO2e_per_Liter_GasolineUser;
        break;
      case VehicleType.alcohol:
        carbonKg = (distanceKm / _km_per_Liter_Ethanol) * _kgCO2e_per_Liter_EthanolUser;
        break;
      case VehicleType.diesel:
        carbonKg = (distanceKm / _km_per_Liter_DieselS10) * _kgCO2e_per_Liter_DieselUser;
        break;
      case VehicleType.flex:
        // Mantendo média simples com novos fatores
        double litersFlex = distanceKm / _km_per_Liter_Flex_Avg;
        double avgEmissionFactor = (_kgCO2e_per_Liter_GasolineUser + _kgCO2e_per_Liter_EthanolUser) / 2;
        carbonKg = litersFlex * avgEmissionFactor;
        break;
      case VehicleType.electric:
      case VehicleType.hybrid:
        double baselineEmissionsKg = distanceKm * _avgBaselineKgCO2ePerKm; // Usa nova linha base
        double gridEmissionsKg = distanceKm * _evConsumptionKWhPerKm * _gridEmissionFactorKgPerKWh;
        carbonKg = gridEmissionsKg - baselineEmissionsKg; // Negativo = Evitado
        break;
    }

    // Calcula valor monetário e créditos (conforme lógica do seu código)
    double carbonTonnes = carbonKg / 1000.0;
    double carbonValue = -carbonTonnes * _carbonPricePerTon; // Crédito (+) se carbonKg for negativo
    // Créditos: 10% da massa de CO2 (positivo se emitiu, negativo se evitou?)
    // Ajustar esta lógica se necessário - aqui calcula 10% do valor absoluto para simplificar
    double creditsEarned = carbonKg.abs() * 0.1;
    // Ou seria 10% do VALOR? double creditsEarned = carbonValue * 0.1; ? -> Fica negativo
    // Ou crédito só para EV? if (vehicleType == VehicleType.electric) creditsEarned = carbonKg.abs() * 0.1; else creditsEarned = 0;

    print('[CarbonService UserFactors] Calculado: ${distanceKm.toStringAsFixed(1)} km, Tipo: ${vehicleType.name}, Carbono: ${carbonKg.toStringAsFixed(3)} kg CO2e, Valor: R\$ ${carbonValue.toStringAsFixed(2)}, Creditos: ${creditsEarned.toStringAsFixed(4)}');

    return {
      'carbonKg': carbonKg,
      'carbonValue': carbonValue,
      'creditsEarned': creditsEarned, // Novo campo adicionado
    };
  }
}