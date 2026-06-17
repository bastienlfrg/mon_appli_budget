import 'dart:convert'; // Indispensable pour jsonEncode et jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Notre outil de sauvegarde
import 'ecran_configuration.dart';
import '../models/operation.dart';

class EcranSolo extends StatefulWidget {
  const EcranSolo({super.key});

  @override
  State<EcranSolo> createState() => _EcranSoloState();
}

class _EcranSoloState extends State<EcranSolo> {
  double solde = 0.0;
  List<Operation> lesOperations = [];

  // --- DONNÉE PARTAGÉE (Simulation de la compagne) ---
  double resteAVivreCompagne = 450.0; // Valeur simulée par défaut

  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerDonneesPrincipales(); // Chargement auto des opérations, du solde et de la compagne au démarrage
  }

  // =========================================================
  // LOGIQUE DE SAUVEGARDE ET CHARGEMENT (ÉCRAN PRINCIPAL)
  // =========================================================

  Future<void> _sauvegarderDonneesPrincipales() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Sauvegarde du solde numérique
    await prefs.setDouble('solde_courant', solde);

    // 2. Sauvegarde du reste à vivre simulé de la compagne (pratique pour vos tests)
    await prefs.setDouble('reste_a_vivre_compagne', resteAVivreCompagne);

    // 3. Sauvegarde de la liste des opérations convertie en JSON string
    final String operationsJson =
        jsonEncode(lesOperations.map((op) => op.toJson()).toList());
    await prefs.setString('historique_operations', operationsJson);
  }

  Future<void> _chargerDonneesPrincipales() async {
    final prefs = await SharedPreferences.getInstance();

    final double? soldeStocke = prefs.getDouble('solde_courant');
    final double? compagneStocke = prefs.getDouble('reste_a_vivre_compagne');
    final String? operationsRaw = prefs.getString('historique_operations');

    setState(() {
      if (soldeStocke != null) {
        solde = soldeStocke;
      }
      if (compagneStocke != null) {
        resteAVivreCompagne = compagneStocke;
      }
      if (operationsRaw != null) {
        final List<dynamic> listeDecodee = jsonDecode(operationsRaw);
        lesOperations =
            listeDecodee.map((item) => Operation.fromJson(item)).toList();
      }
    });
  }

  // =========================================================
  // LOGIQUE DES OPÉRATIONS MANUELLES
  // =========================================================
  void validerOperation(bool estUnCredit) {
    String titreSaisi = _titreController.text;
    double montantSaisi = double.tryParse(_montantController.text) ?? 0.0;

    if (montantSaisi > 0) {
      if (titreSaisi.isEmpty) {
        titreSaisi = estUnCredit ? 'Apport manuel' : 'Dépense manuelle';
      }

      setState(() {
        solde = estUnCredit ? solde + montantSaisi : solde - montantSaisi;

        lesOperations.insert(
          0,
          Operation(
            id: 'op_${DateTime.now().millisecondsSinceEpoch}',
            text: titreSaisi, // Remplacé 'titre' par 'text' si ton modèle utilise 'text', ou vice-versa
            titre: titreSaisi,
            montant: montantSaisi,
            estUnCredit: estUnCredit,
            date: DateTime.now(),
          ),
        );
      });

      _titreController.clear();
      _montantController.clear();
      FocusScope.of(context).unfocus();

      _sauvegarderDonneesPrincipales(); // On sauvegarde tout après une opération
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color couleurSolde = solde < 0 ? Colors.red : Colors.teal;
    double resteAVivreGlobal = solde + resteAVivreCompagne;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte Solo'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuration Profil',
            onPressed: () async {
              final double? nouveauSoldeDeBase = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EcranConfiguration()),
              );

              if (nouveauSoldeDeBase != null) {
                setState(() {
                  solde = nouveauSoldeDeBase;
                  lesOperations.clear(); 
                });
                _sauvegarderDonneesPrincipales();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. EN-TÊTE GLOBAL : RESTE À VIVRE DU FOYER ---
            Card(
              elevation: 4,
              color: Colors.blueGrey[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Reste à vivre global du Foyer',
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${resteAVivreGlobal.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. MON COMPTE PERSO (DÉTAILLÉ) ---
            Card(
              elevation: 2,
              color: solde < 0 ? Colors.red[50] : Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Mon Reste à vivre personnel',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      '${solde.toStringAsFixed(2)} €',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: couleurSolde),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. ESPACE PARTAGÉ : COMPAGNE (SÉCURISÉ - CHIFFRE SEUL) ---
            Card(
              elevation: 2,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Reste à vivre (Compagne) :',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    // Un InkWell discret pour vous permettre de modifier la valeur de test directement en cliquant sur le chiffre !
                    InkWell(
                      onTap: () async {
                        // Petit prompt de test rapide pour changer sa valeur à la volée pendant vos essais
                        double? nouvelleValeur = await _afficherDialogueTestCompagne();
                        if (nouvelleValeur != null) {
                          setState(() {
                            resteAVivreCompagne = nouvelleValeur;
                          });
                          _sauvegarderDonneesPrincipales();
                        }
                      },
                      child: Text(
                        '${resteAVivreCompagne.toStringAsFixed(2)} €',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- FORMULAIRE : NOUVELLE OPÉRATION ---
            const Text('Nouvelle opération manuelle :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: 'Nom (ex: Courses)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _montantController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*[\.,]?\d*'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => validerOperation(true),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => validerOperation(false),
                    icon: const Icon(Icons.remove),
                    label: const Text('Soustraire'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- HISTORIQUE DES OPÉRATIONS ---
            const Text('Historique des opérations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: lesOperations.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune opération enregistrée.',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    )
                  : ListView.builder(
                      itemCount: lesOperations.length,
                      itemBuilder: (context, index) {
                        final op = lesOperations[index];
                        final Color couleurOp =
                            op.estUnCredit ? Colors.teal : Colors.red;
                        final String signe = op.estUnCredit ? '+' : '-';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: couleurOp.withOpacity(0.1),
                              child: Icon(
                                op.estUnCredit
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: couleurOp,
                              ),
                            ),
                            title: Text(op.titre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(
                                '${op.date.day}/${op.date.month} à ${op.date.hour}h${op.date.minute.toString().padLeft(2, '0')}'),
                            trailing: Text(
                              '$signe ${op.montant.toStringAsFixed(2)} €',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: couleurOp,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PETIT OUTIL DE TEST : Boîte de dialogue pour modifier le solde fictif de la compagne ---
  Future<double?> _afficherDialogueTestCompagne() {
    final TextEditingController testController = TextEditingController(text: resteAVivreCompagne.toString());
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simuler le Reste à Vivre de ta compagne'),
        content: TextField(
          controller: testController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: '€', labelText: 'Montant fictif'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, double.tryParse(testController.text) ?? 0.0),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}
