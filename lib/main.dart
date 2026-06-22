import 'package:flutter/material.dart';
import 'screens/ecran_solo.dart'; // <-- On importe notre écran isolé !

void main() {
  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EcranSolo(), // C'est lui qui prend les commandes au démarrage
    );
  }
}
