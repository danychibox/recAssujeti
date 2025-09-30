import 'package:flutter/material.dart';
import 'package:assujtiapp/model/boutique.dart';
import 'package:assujtiapp/services/DatabaseHelper.dart';
import 'package:assujtiapp/widgets/boutique_card.dart';

class ListBoutiqueScreen extends StatefulWidget {
  const ListBoutiqueScreen({super.key});

  @override
  State<ListBoutiqueScreen> createState() => _ListBoutiqueScreenState();
}

class _ListBoutiqueScreenState extends State<ListBoutiqueScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Boutique> _boutiques = [];
  List<Boutique> _filteredBoutiques = [];
  bool _isLoading = true;

  String _selectedQuartier = 'Tous';
  String _selectedType = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quartiers = [
    'Tous',
    'Mulekera',
    'Mwanga',
    'Bungulu',
    'Mususa',
    'Bovota',
    'Other'
  ];

  final List<String> _types = [
    'Tous',
    'Alimentation',
    'Vêtements',
    'Électronique',
    'Pharmacie',
    'Restaurant',
    'Coiffure',
    'Quincaillerie',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadBoutiques();
  }

  Future<void> _loadBoutiques() async {
    setState(() {
      _isLoading = true;
    });
    
    final boutiques = await _databaseHelper.getBoutiques();
    setState(() {
      _boutiques = boutiques;
      _filteredBoutiques = boutiques;
      _isLoading = false;
    });
  }

  void _filterBoutiques() {
    List<Boutique> filtered = _boutiques;

    if (_selectedQuartier != 'Tous') {
      filtered = filtered.where((b) => b.quartier == _selectedQuartier).toList();
    }

    if (_selectedType != 'Tous') {
      filtered = filtered.where((b) => b.typeCommerce == _selectedType).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((b) =>
        b.nom.toLowerCase().contains(searchLower) ||
        b.proprietaire.toLowerCase().contains(searchLower) ||
        b.adresse.toLowerCase().contains(searchLower)
      ).toList();
    }

    setState(() {
      _filteredBoutiques = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les boutiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedQuartier,
              decoration: const InputDecoration(labelText: 'Quartier'),
              items: _quartiers.map((quartier) {
                return DropdownMenuItem<String>(
                  value: quartier,
                  child: Text(quartier),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuartier = value!;
                });
                _filterBoutiques();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type de commerce'),
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                _filterBoutiques();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedQuartier = 'Tous';
                _selectedType = 'Tous';
                _searchController.clear();
              });
              _filterBoutiques();
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Boutiques'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                 hintText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.search),
                 filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterBoutiques();
                  },
                ),
              ),
              onChanged: (value) => _filterBoutiques(),
            ),
          ),
          
          // Indicateurs de filtre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (_selectedQuartier != 'Tous')
                  Chip(
                    label: Text('Quartier: $_selectedQuartier'),
                    onDeleted: () {
                      setState(() {
                        _selectedQuartier = 'Tous';
                      });
                      _filterBoutiques();
                    },
                  ),
                if (_selectedType != 'Tous')
                  Chip(
                    label: Text('Type: $_selectedType'),
                    onDeleted: () {
                      setState(() {
                        _selectedType = 'Tous';
                      });
                      _filterBoutiques();
                    },
                  ),
              ],
            ),
          ),
          
          // Compteur
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_filteredBoutiques.length} boutique(s) trouvée(s)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          
          // Liste des boutiques
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBoutiques.isEmpty
                    ? const Center(
                        child: Text('Aucune boutique trouvée'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredBoutiques.length,
                        itemBuilder: (context, index) {
                          final boutique = _filteredBoutiques[index];
                          return BoutiqueCard(
                            boutique: boutique,
                            onDelete: () async {
                              await _databaseHelper.deleteBoutique(boutique.id!);
                              _loadBoutiques();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}