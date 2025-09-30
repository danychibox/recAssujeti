class Boutique {
  int? id;
  String nom;
  String proprietaire;
  String telephone;
  String adresse;
  String quartier;
  String typeCommerce;
  DateTime dateOuverture;
  int nombreEmployes;
  double latitude;
  double longitude;
  DateTime dateRecensement;

  Boutique({
    this.id,
    required this.nom,
    required this.proprietaire,
    required this.telephone,
    required this.adresse,
    required this.quartier,
    required this.typeCommerce,
    required this.dateOuverture,
    required this.nombreEmployes,
    required this.latitude,
    required this.longitude,
    required this.dateRecensement,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'proprietaire': proprietaire,
      'telephone': telephone,
      'adresse': adresse,
      'quartier': quartier,
      'typeCommerce': typeCommerce,
      'dateOuverture': dateOuverture.toIso8601String(),
      'nombreEmployes': nombreEmployes,
      'latitude': latitude,
      'longitude': longitude,
      'dateRecensement': dateRecensement.toIso8601String(),
    };
  }

  factory Boutique.fromMap(Map<String, dynamic> map) {
    return Boutique(
      id: map['id'],
      nom: map['nom'],
      proprietaire: map['proprietaire'],
      telephone: map['telephone'],
      adresse: map['adresse'],
      quartier: map['quartier'],
      typeCommerce: map['typeCommerce'],
      dateOuverture: DateTime.parse(map['dateOuverture']),
      nombreEmployes: map['nombreEmployes'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      dateRecensement: DateTime.parse(map['dateRecensement']),
    );
  }
}