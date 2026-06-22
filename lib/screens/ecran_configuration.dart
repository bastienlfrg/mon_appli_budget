import 'dart:convert'; // Indispensable pour jsonEncode et jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Notre outil de sauvegarde
import '../models/frais_fixe.dart';

class EcranConfiguration extends StatefulWidget {
  const EcranConfiguration({super.key});

  @override
  State<EcranConfiguration> createState() => _EcranConfigurationState();
}

class _EcranConfigurationState extends State<EcranConfiguration> {
  // 1. Nos listes dynamiques
  List<FraisFixe> lesRevenusFixes = [];
  List<FraisFixe> lesChargesFixes = [];

  // Formulaires
  final TextEditingController _nomRevenuController = TextEditingController();
  final TextEditingController _montantRevenuController = TextEditingController();
  final TextEditingController _nomChargeController = TextEditingController();
  final TextEditingController _montantChargeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerDonneesLocales(); // On charge les listes dès que l'écran s'ouvre
  }

  // =========================================================
  // LOGIQUE DE SAUVEGARDE ET CHARGEMENT
  // =========================================================

  // Écriture des données sur le disque
  Future<void> _sauvegarderDonneesLocales() async {
    final prefs = await SharedPreferences.getInstance();

    // On transforme nos listes d'objets en listes de Maps, puis en chaînes JSON
    final String revenusJson = jsonEncode(lesRevenusFixes.map((r) => r.toJson()).toList());
    final String chargesJson = jsonEncode(lesChargesFixes.map((c) => c.toJson()).toList());

    await prefs.setString('revenus_fixes', revenusJson);
    await prefs.setString('charges_fixes', chargesJson);
  }

  // Lecture des données depuis le disque
  Future<void> _chargerDonneesLocales() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? revenusRaw = prefs.getString('revenus_fixes');
    final String? chargesRaw = prefs.getString('charges_fixes');

    setState(() {
      if (revenusRaw != null) {
        final List<dynamic> listeDecodee = jsonDecode(revenusRaw);
        lesRevenusFixes = listeDecodee.map((item) => FraisFixe.fromJson(item)).toList();
      }
      if (chargesRaw != null) {
        final List<dynamic> listeDecodee = jsonDecode(chargesRaw);
        lesChargesFixes = listeDecodee.map((item) => FraisFixe.fromJson(item)).toList();
      }
    });
  }

  // =========================================================
  // GESTION DES REVENUS
  // =========================================================
  void ajouterUnRevenu() {
    String nomSaisi = _nomRevenuController.text;
    double montantSaisi = double.tryParse(_montantRevenuController.text) ?? 0.0;

    if (nomSaisi.isNotEmpty && montantSaisi > 0) {
      setState(() {
        lesRevenusFixes.add(
          FraisFixe(
            id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
            nom: nomSaisi,
            montant: montantSaisi,
          ),
        );
      });
      _nomRevenuController.clear();
      _montantRevenuController.clear();
      FocusScope.of(context).unfocus();
      _sauvegarderDonneesLocales(); // Sauvegarde après ajout
    }
  }

  void supprimerUnRevenu(String idASupprimer) {
    setState(() {
      lesRevenusFixes.removeWhere((revenu) => revenu.id == idASupprimer);
    });
    _sauvegarderDonneesLocales(); // Sauvegarde après suppression
  }

  // =========================================================
  // GESTION DES CHARGES
  // =========================================================
  void ajouterUneCharge() {
    String nomSaisi = _nomChargeController.text;
    double montantSaisi = double.tryParse(_montantChargeController.text) ?? 0.0;

    if (nomSaisi.isNotEmpty && montantSaisi > 0) {
      setState(() {
        lesChargesFixes.add(
          FraisFixe(
            id: 'cha_${DateTime.now().millisecondsSinceEpoch}',
            nom: nomSaisi,
            montant: montantSaisi,
          ),
        );
      });
      _nomChargeController.clear();
      _montantChargeController.clear();
      FocusScope.of(context).unfocus();
      _sauvegarderDonneesLocales(); // Sauvegarde après ajout
    }
  }

  void supprimerUneCharge(String idASupprimer) {
    setState(() {
      lesChargesFixes.removeWhere((charge) => charge.id == idASupprimer);
    });
    _sauvegarderDonneesLocales(); // Sauvegarde après suppression
  }

  double calculerTotalRevenus() {
    double total = 0.0;
    for (var revenu in lesRevenusFixes) {
      total += revenu.montant;
    }
    return total;
  }

  double calculerTotalCharges() {
    double total = 0.0;
    for (var charge in lesChargesFixes) {
      total += charge.montant;
    }
    return total;
  }

  @override
  void dispose() {
    _nomRevenuController.dispose();
    _montantRevenuController.dispose();
    _nomChargeController.dispose();
    _montantChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du Profil'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SECTION 1 : REVENUS FIXES ---
                    const Text(
                      '1. Vos revenus fixes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _nomRevenuController,
                            decoration: const InputDecoration(labelText: 'Nom (ex: Salaire)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _montantRevenuController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder(), suffixText: '€'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.teal, size: 32),
                          onPressed: ajouterUnRevenu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (lesRevenusFixes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Aucun revenu fixe.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      )
                    else
                      ...lesRevenusFixes.map((revenu) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.arrow_upward, color: Colors.teal),
                              title: Text(revenu.nom),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('+ ${revenu.montant.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => supprimerUnRevenu(revenu.id)),
                                ],
                              ),
                            ),
                          )),

                    const Divider(height: 40, thickness: 2),

                    // --- SECTION 2 : CHARGES FIXES ---
                    const Text(
                      '2. Vos charges fixes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _nomChargeController,
                            decoration: const InputDecoration(labelText: 'Nom (ex: Loyer)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _montantChargeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder(), suffixText: '€'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.red, size: 32),
                          onPressed: ajouterUneCharge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (lesChargesFixes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Aucune charge fixe.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      )
                    else
                      ...lesChargesFixes.map((charge) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.arrow_downward, color: Colors.red),
                              title: Text(charge.nom),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('- ${charge.montant.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => supprimerUneCharge(charge.id)),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                double totalRevenus = calculerTotalRevenus();
                double totalCharges = calculerTotalCharges();
                double soldeCalcule = totalRevenus - totalCharges;

                Navigator.pop(context, soldeCalcule);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Sauvegarder et Initialiser', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
