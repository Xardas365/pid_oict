import 'package:flutter/material.dart';

class VehicleMapPlaceholderScreen extends StatelessWidget {
  const VehicleMapPlaceholderScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    // Temporary placeholder for seed 06, where the real vehicle map UI is added.
    return Scaffold(
      appBar: AppBar(title: const Text('Poloha vozidla')),
      body: Center(
        child: Text('Mapa vozidla $vehicleId bude doplnena v dalsim kroku.'),
      ),
    );
  }
}
