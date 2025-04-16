import 'package:flutter/material.dart';
import '../models/vehicle.dart';
// Importar services e providers necessários

class RegistrationScreen extends StatefulWidget {
  static const routeName = '/register-vehicle'; // Para navegação por rotas

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _make = '';
  String _model = '';
  int? _year;
  VehicleType _selectedType = VehicleType.electric; // Default
  String _licensePlate = '';

  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Sai se o formulário for inválido
    }
    _formKey.currentState!.save(); // Salva os valores dos campos

    setState(() {
      _isLoading = true;
    });

    try {
      // --- LÓGICA DE ENVIO PARA O BACKEND ---
      // Obter o ID do usuário logado (ex: via Provider)
      // String userId = Provider.of<UserProvider>(context, listen: false).userId;

      // Criar objeto Vehicle
      final newVehicle = Vehicle(
        id: DateTime.now().toString(), // ID temporário, backend deve gerar
        userId: "user_id_placeholder", // Substituir pelo ID real
        make: _make,
        model: _model,
        year: _year!,
        type: _selectedType,
        licensePlate: _licensePlate.isNotEmpty ? _licensePlate : null,
      );

      // Chamar um serviço para salvar o veículo no backend
      // await Provider.of<VehicleProvider>(context, listen: false).addVehicle(newVehicle);
      print('Veículo a ser registrado: ${newVehicle.toJson()}');
      // Simular chamada de API
      await Future.delayed(Duration(seconds: 2));

      // Navegar para outra tela (ex: Dashboard) ou mostrar sucesso
      Navigator.of(context).pop(); // Volta para a tela anterior

    } catch (error) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar veículo: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Veículo')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView( // Para evitar overflow em telas pequenas
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Marca'),
                        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                        onSaved: (value) => _make = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Modelo'),
                        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                        onSaved: (value) => _model = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Ano'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Campo obrigatório';
                          if (int.tryParse(value) == null) return 'Ano inválido';
                          if (int.parse(value) < 1950 || int.parse(value) > DateTime.now().year + 1) return 'Ano irreal';
                          return null;
                        },
                        onSaved: (value) => _year = int.parse(value!),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Placa (Opcional)'),
                        onSaved: (value) => _licensePlate = value!,
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<VehicleType>(
                        value: _selectedType,
                        decoration: InputDecoration(labelText: 'Tipo de Veículo'),
                        items: VehicleType.values.map((VehicleType type) {
                          return DropdownMenuItem<VehicleType>(
                            value: type,
                            child: Text(type == VehicleType.electric ? 'Elétrico' : 'Combustão'),
                          );
                        }).toList(),
                        onChanged: (VehicleType? newValue) {
                          setState(() {
                            _selectedType = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Registrar Veículo'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
