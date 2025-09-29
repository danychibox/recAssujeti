// main.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

// -----------------------------
// MODELE : Assujetti
// -----------------------------
class Assujetti {
  int? id;
  String nom;
  String prenom;
  String adresse;
  String nif; // numéro d'identification fiscale
  String type; // ex: individuel / entreprise
  double montantDue;
  int isSynced; // 0 = non, 1 = oui
  String dateInscription;

  Assujetti({
    this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.nif,
    required this.type,
    required this.montantDue,
    this.isSynced = 0,
    required this.dateInscription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'nif': nif,
      'type': type,
      'montant_due': montantDue,
      'is_synced': isSynced,
      'date_inscription': dateInscription,
    };
  }

  factory Assujetti.fromMap(Map<String, dynamic> map) {
    return Assujetti(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      adresse: map['adresse'],
      nif: map['nif'],
      type: map['type'],
      montantDue: (map['montant_due'] as num).toDouble(),
      isSynced: map['is_synced'],
      dateInscription: map['date_inscription'],
    );
  }
}

// -----------------------------
// DATABASE HELPER (Singleton)
// -----------------------------
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taxes_recensement.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, filePath);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assujetti (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        adresse TEXT,
        nif TEXT,
        type TEXT,
        montant_due REAL,
        is_synced INTEGER DEFAULT 0,
        date_inscription TEXT
      )
    ''');
  }

  Future<int> insertAssujetti(Assujetti a) async {
    final db = await instance.database;
    return await db.insert('assujetti', a.toMap());
  }

  Future<List<Assujetti>> getAllAssujettis({String? query}) async {
    final db = await instance.database;
    final whereClause = (query != null && query.isNotEmpty)
        ? "WHERE nom LIKE ? OR prenom LIKE ? OR nif LIKE ?"
        : "";
    final args = (query != null && query.isNotEmpty)
        ? ['%$query%', '%$query%', '%$query%']
        : null;

    final result = (args != null)
        ? await db.rawQuery('SELECT * FROM assujetti $whereClause ORDER BY nom', args)
        : await db.query('assujetti', orderBy: 'nom');

    return result.map((m) => Assujetti.fromMap(m)).toList();
  }

  Future<int> updateAssujetti(Assujetti a) async {
    final db = await instance.database;
    return await db.update('assujetti', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> deleteAssujetti(int id) async {
    final db = await instance.database;
    return await db.delete('assujetti', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markAllSynced() async {
    final db = await instance.database;
    return await db.update('assujetti', {'is_synced': 1});
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// -----------------------------
// MAIN
// -----------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // initialize DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recensement - Taxes',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const LoginScreen(),
    );
  }
}

// -----------------------------
// LOGIN (simple demo)
// -----------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600)); // simulate auth
    if (_userCtrl.text == 'admin' && _passCtrl.text == 'admin') {
      if (!mounted) return;
      Navigator.of(context as BuildContext).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
    } else {
      setState(() {
        _error = 'Identifiants incorrects (utilise admin/admin)';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Connexion', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Utilisateur')),
                  const SizedBox(height: 8),
                  TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: _loading ? null : _login,
                      child: _loading ? const CircularProgressIndicator() : const Text('Se connecter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// DASHBOARD
// -----------------------------
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            tooltip: 'Se déconnecter',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2),
          children: [
            _TileCard(
              icon: Icons.people,
              title: 'Assujettis',
              subtitle: 'Liste & gestion',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AssujettiListScreen())),
            ),
            _TileCard(
              icon: Icons.add_box,
              title: 'Enregistrer paiement',
              subtitle: 'Ajouter un paiement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditAssujettiScreen())),
            ),
            _TileCard(
              icon: Icons.sync,
              title: 'Synchroniser',
              subtitle: 'Simuler envoi au serveur',
              onTap: () async {
                // simulate sync
                final count = await DatabaseHelper.instance.markAllSynced();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marqué $count enregistrements comme synchronisés')));
                }
              },
            ),
            _TileCard(
              icon: Icons.bar_chart,
              title: 'Rapports',
              subtitle: 'Statistiques rapides',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _TileCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon), radius: 26),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ])),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// LISTE DES ASSUJETTIS
// -----------------------------
class AssujettiListScreen extends StatefulWidget {
  const AssujettiListScreen({super.key});
  @override
  State<AssujettiListScreen> createState() => _AssujettiListScreenState();
}

class _AssujettiListScreenState extends State<AssujettiListScreen> {
  List<Assujetti> _items = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    setState(() => _loading = true);
    final list = await DatabaseHelper.instance.getAllAssujettis(query: _query.isEmpty ? null : _query);
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future _delete(int id) async {
    await DatabaseHelper.instance.deleteAssujetti(id);
    _load();
  }

  Future _toggleSync(Assujetti a) async {
    a.isSynced = a.isSynced == 1 ? 0 : 1;
    await DatabaseHelper.instance.updateAssujetti(a);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assujettis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Rafraîchir',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditAssujettiScreen())).then((_) => _load()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher par nom, prénom ou NIF'),
            onChanged: (v) {
              _query = v;
              _load();
            },
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            const Expanded(child: Center(child: Text('Aucun enregistrement')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final a = _items[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(a.nom.isNotEmpty ? a.nom[0].toUpperCase() : '?')),
                      title: Text('${a.nom} ${a.prenom}'),
                      subtitle: Text('NIF: ${a.nif} • Due: ${a.montantDue.toStringAsFixed(2)}'),
                      trailing: Wrap(spacing: 6, children: [
                        IconButton(
                          icon: Icon(a.isSynced == 1 ? Icons.cloud_done : Icons.cloud_upload),
                          onPressed: () => _toggleSync(a),
                          tooltip: a.isSynced == 1 ? 'Synchronisé' : 'Marquer comme synchronisé',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => AddEditAssujettiScreen(edit: a)))
                              .then((_) => _load()),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: const Text('Confirmer'),
                                      content: const Text('Supprimer cet enregistrement ?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
                                      ],
                                    ));
                            if (ok == true) _delete(a.id!);
                          },
                        )
                      ]),
                      onTap: () {
                        // Voir détail
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: Text('${a.nom} ${a.prenom}'),
                                  content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Adresse: ${a.adresse}'),
                                    const SizedBox(height: 6),
                                    Text('NIF: ${a.nif}'),
                                    const SizedBox(height: 6),
                                    Text('Type: ${a.type}'),
                                    const SizedBox(height: 6),
                                    Text('Montant dû: ${a.montantDue.toStringAsFixed(2)}'),
                                    const SizedBox(height: 6),
                                    Text('Synchronisé: ${a.isSynced == 1 ? 'Oui' : 'Non'}'),
                                  ]),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                                ));
                      },
                    ),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }
}

// -----------------------------
// FORMULAIRE AJOUT / EDIT
// -----------------------------
class AddEditAssujettiScreen extends StatefulWidget {
  final Assujetti? edit;
  const AddEditAssujettiScreen({this.edit, super.key});

  @override
  State<AddEditAssujettiScreen> createState() => _AddEditAssujettiScreenState();
}

class _AddEditAssujettiScreenState extends State<AddEditAssujettiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _adresse = TextEditingController();
  final _nif = TextEditingController();
  final _montant = TextEditingController();
  String _type = 'Individuel';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) {
      final a = widget.edit!;
      _nom.text = a.nom;
      _prenom.text = a.prenom;
      _adresse.text = a.adresse;
      _nif.text = a.nif;
      _montant.text = a.montantDue.toString();
      _type = a.type;
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _adresse.dispose();
    _nif.dispose();
    _montant.dispose();
    super.dispose();
  }

  Future _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now().toIso8601String();
    final a = Assujetti(
      id: widget.edit?.id,
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      adresse: _adresse.text.trim(),
      nif: _nif.text.trim(),
      type: _type,
      montantDue: double.tryParse(_montant.text.replaceAll(',', '.')) ?? 0.0,
      isSynced: widget.edit?.isSynced ?? 0,
      dateInscription: widget.edit?.dateInscription ?? now,
    );

    if (widget.edit == null) {
      await DatabaseHelper.instance.insertAssujetti(a);
    } else {
      await DatabaseHelper.instance.updateAssujetti(a);
    }

    if (!mounted) {
      Navigator.of(context as BuildContext).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.edit != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Modifier assujetti' : 'Ajouter assujetti')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              TextFormField(controller: _nom, decoration: const InputDecoration(labelText: 'Nom'), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _prenom, decoration: const InputDecoration(labelText: 'Prénom'), validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _adresse, decoration: const InputDecoration(labelText: 'Adresse')),
              const SizedBox(height: 8),
              TextFormField(controller: _nif, decoration: const InputDecoration(labelText: 'NIF')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Individuel', child: Text('Individuel')),
                  DropdownMenuItem(value: 'Entreprise', child: Text('Entreprise')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'Individuel'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _montant, decoration: const InputDecoration(labelText: 'Montant dû'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                    onPressed: _saving ? null : _save,
                    child: _saving ? const CircularProgressIndicator() : Text(editing ? 'Enregistrer' : 'Ajouter')),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// RAPPORTS SIMPLES
// -----------------------------
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _total = 0;
  double _sumDue = 0.0;
  int _synced = 0;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future _calc() async {
    final list = await DatabaseHelper.instance.getAllAssujettis();
    final total = list.length;
    final sum = list.fold<double>(0.0, (p, e) => p + e.montantDue);
    final synced = list.where((e) => e.isSynced == 1).length;
    setState(() {
      _total = total;
      _sumDue = sum;
      _synced = synced;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(
            child: ListTile(title: const Text('Total assujettis'), trailing: Text('$_total')),
          ),
          const SizedBox(height: 8),
          Card(child: ListTile(title: const Text('Montant total dû'), trailing: Text('${_sumDue.toStringAsFixed(2)}'))),
          const SizedBox(height: 8),
          Card(child: ListTile(title: const Text('Synchronisés'), trailing: Text('$_synced'))),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: _calc, child: const Text('Rafraîchir'))
        ]),
      ),
    );
  }
}
