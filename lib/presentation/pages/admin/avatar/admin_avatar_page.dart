import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_state.dart';

class AdminAvatarPage extends StatefulWidget {
  const AdminAvatarPage({super.key});

  @override
  State<AdminAvatarPage> createState() => _AdminAvatarPageState();
}

class _AdminAvatarPageState extends State<AdminAvatarPage> {
  // State untuk Filter dan Sort
  String _selectedRarity = 'All';
  String _sortBy = 'Lowest Price'; // Pilihan: 'Lowest Price', 'Highest Price'

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminAvatarBloc(
        context.read<AdminRepositoryImpl>(),
      )..add(LoadAvatarsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Avatar Management', 
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkAzure,
          elevation: 0,
        ),
        body: Column(
          children: [
            // --- BAGIAN FILTER & SORT BAR ---
            _buildControlBar(),
            
            // --- BAGIAN GRID ---
            Expanded(
              child: BlocBuilder<AdminAvatarBloc, AdminAvatarState>(
                builder: (context, state) {
                  if (state is AvatarLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
                  }
                  if (state is AvatarError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  if (state is AvatarLoaded) {
                    // Terapkan Logika Filter & Sort di sini
                    // NOTE: Jika Anda sudah menerapkan filter di Bloc (filteredAvatars), 
                    // gunakan state.filteredAvatars langsung.
                    // Tapi jika belum, kita filter manual di UI seperti kode Anda:
                    List<AvatarModel> sourceList = state.allAvatars; // Atau state.avatars tergantung nama di state
                    
                    // Logic Filter
                    List<AvatarModel> processedList = List.from(sourceList);
                    if (_selectedRarity != 'All') {
                       processedList = processedList.where((a) => a.rarity.toLowerCase() == _selectedRarity.toLowerCase()).toList();
                    }
                    
                    // Logic Sort
                    if (_sortBy == 'Lowest Price') {
                       processedList.sort((a, b) => a.price.compareTo(b.price));
                    } else {
                       processedList.sort((a, b) => b.price.compareTo(a.price));
                    }
                    
                    if (processedList.isEmpty) {
                      return const Center(child: Text("No avatars found for this category."));
                    }
                    
                    return _buildGrid(context, processedList);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        
        // FAB ADD AVATAR
        floatingActionButton: Builder(
          builder: (ctx) {
            final bloc = ctx.read<AdminAvatarBloc>();
            return FloatingActionButton.extended(
              onPressed: () => _showAvatarDialog(ctx, bloc: bloc),
              backgroundColor: AppColors.darkAzure,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("NEW AVATAR", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }

  // Barisan Filter dan Sortir
  Widget _buildControlBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Filter Rarity (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Common', 'Rare', 'Epic', 'Legendary'].map((rarity) {
                final isSelected = _selectedRarity == rarity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(rarity),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedRarity = rarity),
                    selectedColor: AppColors.darkAzure,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Sorting Harga
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sorting by:", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _sortBy = val),
                  child: Row(
                    children: [
                      Text(_sortBy, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure)),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.darkAzure),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Lowest Price', child: Text('Lowest Price')),
                    const PopupMenuItem(value: 'Highest Price', child: Text('Highest Price')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<AvatarModel> avatars) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 0.78,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) => _AvatarCard(avatar: avatars[index]),
    );
  }
}

// --- CARD WIDGET (DENGAN HOVER & DESIGN BERSIH) ---
class _AvatarCard extends StatefulWidget {
  final AvatarModel avatar;
  const _AvatarCard({required this.avatar});

  @override
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color rarityColor;
    switch (widget.avatar.rarity.toLowerCase()) {
      case 'rare': rarityColor = Colors.blue; break;
      case 'epic': rarityColor = Colors.purple; break;
      case 'legendary': rarityColor = Colors.orange; break;
      default: rarityColor = Colors.grey;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 25 : 12,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Image.network(
                          _getValidImageUrl(widget.avatar.imageUrl),
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Text Area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.avatar.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.confirmation_num_rounded, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text("Rp ${widget.avatar.price.toInt()}", 
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Hover Menu (Edit/Delete)
              Positioned(
                top: 15, right: 15,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.black54),
                      onSelected: (val) {
                        final bloc = context.read<AdminAvatarBloc>();
                        if (val == 'edit') _showAvatarDialog(context, avatar: widget.avatar, bloc: bloc);
                        if (val == 'toggle') bloc.add(ToggleAvatarEvent(widget.avatar.id));
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit")),
                        PopupMenuItem(value: 'toggle', child: Text(widget.avatar.isActive ? "Soft Delete" : "Restore")),
                      ],
                    ),
                  ),
                ),
              ),
              // Overlay Jika Deleted
              if (!widget.avatar.isActive)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: const Center(
                      child: Chip(label: Text("DELETED", style: TextStyle(color: Colors.red))),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getValidImageUrl(String url) {
    if (url.contains('dicebear.com') && url.contains('/svg')) {
      return url.replaceAll('/svg', '/png') + (url.contains('?') ? '&size=256' : '?size=256');
    }
    return url;
  }
}

// --- FUNGSI DIALOG ADD/EDIT (Helper) ---
void _showAvatarDialog(BuildContext context, {AvatarModel? avatar, required AdminAvatarBloc bloc}) {
  final isEdit = avatar != null;
  final nameCtrl = TextEditingController(text: isEdit ? avatar.name : '');
  final urlCtrl = TextEditingController(text: isEdit ? avatar.imageUrl : '');
  final priceCtrl = TextEditingController(text: isEdit ? avatar.price.toInt().toString() : '');
  String rarity = isEdit ? avatar.rarity : 'common';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isEdit ? "Update Avatar" : "New Avatar", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameCtrl, "Name", Icons.face_rounded),
              const SizedBox(height: 16),
              _buildField(urlCtrl, "Image URL", Icons.link_rounded, helper: "Supports Dicebear & GDrive"),
              const SizedBox(height: 16),
              _buildField(priceCtrl, "Price", Icons.monetization_on_rounded, isNumber: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: rarity,
                decoration: InputDecoration(
                  labelText: "Rarity",
                  prefixIcon: const Icon(Icons.star_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const ['common', 'rare', 'epic', 'legendary']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => rarity = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final price = double.tryParse(priceCtrl.text) ?? 0;
              if (isEdit) {
                bloc.add(EditAvatarEvent(avatar.id, nameCtrl.text, urlCtrl.text, price, rarity));
              } else {
                bloc.add(AddAvatarEvent(nameCtrl.text, urlCtrl.text, price, rarity));
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}

// Widget kecil untuk TextField
Widget _buildField(TextEditingController ctrl, String label, IconData icon, {String? helper, bool isNumber = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}