import 'package:flutter/material.dart';
import 'package:assujtiapp/model/boutique.dart';
import 'package:assujtiapp/services/DatabaseHelper.dart';
import '../widgets/custom_textfield.dart';

class AddBoutiqueScreen extends StatefulWidget {
  const AddBoutiqueScreen({super.key});

  @override
  State<AddBoutiqueScreen> createState() => _AddBoutiqueScreenState();
}

class _AddBoutiqueScreenState extends State<AddBoutiqueScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _proprietaireController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _employesController = TextEditingController();

  String _selectedQuartier = 'Mulekera';
  String _selectedTypeCommerce = 'Alimentation';
  DateTime _dateOuverture = DateTime.now();

  // Liste des quartiers de Beni
  final List<String> _quartiers = [
    'Mulekera',
    'Mwanga',
    'Bungulu',
    'Mususa',
    'Bovota',
    'Other'
  ];

  // Liste des types de commerce
  final List<String> _typesCommerce = [
    'Alimentation',
    'Vêtements',
    'Électronique',
    'Pharmacie',
    'Restaurant',
    'Coiffure',
    'Quincaillerie',
    'Autre'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOuverture,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOuverture) {
      setState(() {
        _dateOuverture = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    // Simulation de la localisation (à remplacer par un vrai service GPS)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Localisation récupérée')),
    );
  }

  Future<void> _saveBoutique() async {
    if (_formKey.currentState!.validate()) {
      try {
        final boutique = Boutique(
          nom: _nomController.text,
          proprietaire: _proprietaireController.text,
          telephone: _telephoneController.text,
          adresse: _adresseController.text,
          quartier: _selectedQuartier,
          typeCommerce: _selectedTypeCommerce,
          dateOuverture: _dateOuverture,
          nombreEmployes: int.parse(_employesController.text),
          latitude: 0.0, // À remplacer par les vraies coordonnées GPS
          longitude: 0.0,
          dateRecensement: DateTime.now(),
        );

        await _databaseHelper.insertBoutique(boutique);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Boutique enregistrée avec succès!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Boutique'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBoutique,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nomController,
                label: 'Nom de la boutique',
                icon: Icons.store,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de la boutique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _proprietaireController,
                label: 'Nom du propriétaire',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du propriétaire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _telephoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _adresseController,
                label: 'Adresse précise',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quartier
              DropdownButtonFormField<String>(
                value: _selectedQuartier,
                decoration: const InputDecoration(
                  labelText: 'Quartier',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: _quartiers.map((String quartier) {
                  return DropdownMenuItem<String>(
                    value: quartier,
                    child: Text(quartier),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedQuartier = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Type de commerce
              DropdownButtonFormField<String>(
                value: _selectedTypeCommerce,
                decoration: const InputDecoration(
                  labelText: 'Type de commerce',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _typesCommerce.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeCommerce = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Date d'ouverture
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'ouverture',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_dateOuverture.day}/${_dateOuverture.month}/${_dateOuverture.year}',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _employesController,
                label: 'Nombre d\'employés',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre d\'employés';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Bouton localisation
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Obtenir la localisation GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _proprietaireController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _employesController.dispose();
    super.dispose();
  }
}