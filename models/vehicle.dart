enum VehicleType { electric, combustion }

class Vehicle {
  final String id; // Gerado pelo backend ou localmente
  final String userId;
  final String make; // Marca
  final String model; // Modelo
  final int year;
  final VehicleType type;
  final String? licensePlate; // Placa (opcional)
  // Adicionar outros campos relevantes (ex: ID único do veículo - VIN)

  Vehicle({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    this.licensePlate,
  });

  // Métodos para converter para/de JSON (para comunicação com backend)
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      userId: json['userId'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      type: VehicleType.values.firstWhere((e) => e.toString() == 'VehicleType.${json['type']}'),
      licensePlate: json['licensePlate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'make': make,
      'model': model,
      'year': year,
      'type': type.toString().split('.').last, // Envia 'electric' ou 'combustion'
      'licensePlate': licensePlate,
    };
  }
}
