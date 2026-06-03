class FraisFixe {
  final String id;
  final String nom;
  final double montant;

  const FraisFixe({
    required this.id,
    required this.nom,
    required this.montant,
  });

  // Convertit un FraisFixe en Map (Dictionnaire) pour le JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'montant': montant,
    };
  }

  // Recrée un FraisFixe à partir d'un Map (Dictionnaire) JSON
  factory FraisFixe.fromJson(Map<String, dynamic> json) {
    return FraisFixe(
      id: json['id'] as String,
      nom: json['nom'] as String,
      montant: (json['montant'] as num).toDouble(),
    );
  }
}
