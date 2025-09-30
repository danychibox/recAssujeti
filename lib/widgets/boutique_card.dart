import 'package:flutter/material.dart';
import 'package:assujtiapp/model/boutique.dart';

class BoutiqueCard extends StatefulWidget {
  final Boutique boutique;
  final VoidCallback onDelete;

  const BoutiqueCard({
    super.key,
    required this.boutique,
    required this.onDelete,
  });

  @override
  State<BoutiqueCard> createState() => _BoutiqueCardState();
}

class _BoutiqueCardState extends State<BoutiqueCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _isPressed ? 2 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Transform.scale(
          scale: _isPressed ? 0.97 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Nom + menu)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.boutique.nom,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green[800],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Modifier'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Supprimer'),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') _showDeleteDialog(context);
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey, thickness: 1, height: 16),

                    // Infos boutique
                    _buildInfoRow(Icons.person, widget.boutique.proprietaire, Colors.blue),
                    _buildInfoRow(Icons.phone, widget.boutique.telephone, Colors.green),
                    _buildInfoRow(Icons.location_on,
                        '${widget.boutique.adresse}, ${widget.boutique.quartier}', Colors.red),
                    _buildInfoRow(Icons.business, widget.boutique.typeCommerce, Colors.orange),
                    _buildInfoRow(Icons.people,
                        '${widget.boutique.nombreEmployes} employé(s)', Colors.purple),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Ouvert le ${widget.boutique.dateOuverture.day}/${widget.boutique.dateOuverture.month}/${widget.boutique.dateOuverture.year}',
                      Colors.brown,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer la boutique "${widget.boutique.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
