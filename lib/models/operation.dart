class Operation {
  final String id;
  final String titre;
  final double montant;
  final bool estUnCredit;
  final DateTime date;

  const Operation({
    required this.id,
    required this.titre,
    required this.montant,
    required this.estUnCredit,
    required this.date,
  });

  // Convertit l'opération en Map pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'montant': montant,
      'estUnCredit': estUnCredit,
      'date': date.toIso8601String(), // Transformation de la date en texte
    };
  }

  // Recrée l'opération à partir du dictionnaire extrait de la sauvegarde
  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] as String,
      titre: json['titre'] as String,
      montant: (json['montant'] as num).toDouble(),
      estUnCredit: json['estUnCredit'] as bool,
      date: DateTime.parse(
          json['date'] as String), // On reconstruit l'objet DateTime
    );
  }
}
