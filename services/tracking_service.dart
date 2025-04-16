import 'package:geolocator/geolocator.dart'; // Pacote para GPS
import 'dart:async';

// ATENÇÃO: Rastreamento em background é complexo!
// Requer permissões (Manifest/Info.plist), gerenciamento de bateria,
// e lógica robusta para detectar início/fim de forma confiável.
// Pacotes como `background_locator_2` ou `flutter_background_geolocation` podem ajudar,
// mas têm suas próprias complexidades e custos.

class TrackingService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  double _distanceAccumulated = 0.0;
  bool _isTracking = false;
  DateTime? _tripStartTime;

  // Função para ser chamada quando o usuário inicia uma viagem (ex: botão no Dashboard)
  Future<void> startTracking(Function(double distance) onUpdate) async {
    if (_isTracking) return;

    // 1. Verificar e Pedir Permissões de Localização (SEMPRE e EM USO/BACKGROUND)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desabilitado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
      // Instruir usuário a habilitar nas configurações
    }
     // Para background, idealmente pedir 'whileInUse' primeiro e depois 'always' se necessário.

    // 2. Configurar e Iniciar o Stream de Posições
    _distanceAccumulated = 0.0;
    _lastPosition = null;
    _isTracking = true;
    _tripStartTime = DateTime.now();

    // Configurações para balancear precisão e bateria
    LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high, // Ou .medium, .low
        distanceFilter: 10, // Notificar a cada 10 metros (ajustar!)
        // foregroundNotificationConfig: ForegroundNotificationConfig( // Necessário para background no Android
        //     notificationText: "Rastreando sua viagem para cálculo de carbono",
        //     notificationTitle: "App Carbono Zero Ativo",
        //     enableWakeLock: true,
        // ),
        // intervalDuration: const Duration(seconds: 5), // Opcional: intervalo mínimo
      );
      // Adicionar IOSSettings se necessário

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
          print('Nova posição: ${position.latitude}, ${position.longitude}');
          if (_lastPosition != null) {
            double distanceDelta = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            _distanceAccumulated += distanceDelta;
            onUpdate(_distanceAccumulated / 1000.0); // Envia atualização em KM
          }
          _lastPosition = position;
        });

     print('Rastreamento iniciado.');
  }

  // Função para ser chamada quando o usuário termina a viagem
  Future<Map<String, dynamic>?> stopTracking() async {
     if (!_isTracking) return null;

    await _positionStreamSubscription?.cancel(); // Para o stream
    _positionStreamSubscription = null;
    _isTracking = false;
    DateTime tripEndTime = DateTime.now();

    print('Rastreamento parado. Distância total: ${_distanceAccumulated / 1000.0} km');

    final tripData = {
      'distanceKm': _distanceAccumulated / 1000.0,
      'startTime': _tripStartTime,
      'endTime': tripEndTime,
      'duration': tripEndTime.difference(_tripStartTime!),
    };

    // Resetar estado para a próxima viagem
    _distanceAccumulated = 0.0;
    _lastPosition = null;
    _tripStartTime = null;

    return tripData;
  }

  bool get isTracking => _isTracking;
}
