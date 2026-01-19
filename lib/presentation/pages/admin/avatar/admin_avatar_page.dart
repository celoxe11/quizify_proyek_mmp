import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  String _selectedRarity = 'All';
  String _sortBy = 'Lowest Price';

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
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkAzure,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildControlBar(),
            Expanded(
              child: BlocBuilder<AdminAvatarBloc, AdminAvatarState>(
                builder: (context, state) {
                  if (state is AvatarLoading) return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
                  if (state is AvatarError) return Center(child: Text("Error: ${state.message}"));
                  if (state is AvatarLoaded) {
                    final processedList = _applyFilterAndSort(state.allAvatars);
                    if (processedList.isEmpty) return const Center(child: Text("No avatars found."));
                    
                    // RESPONSIVE LAYOUT
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Desktop > 900px (4 Kolom), Tablet > 600px (3 Kolom), Mobile (2 Kolom)
                        int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
                        
                        return GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75, // Kartu lebih proporsional
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: processedList.length,
                          itemBuilder: (context, index) => _AvatarCard(avatar: processedList[index]),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            final bloc = ctx.read<AdminAvatarBloc>();
            return FloatingActionButton.extended(
              onPressed: () => _showAvatarDialog(ctx, bloc: bloc),
              backgroundColor: AppColors.darkAzure,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("NEW AVATAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Common', 'Rare', 'Epic', 'Legendary'].map((rarity) {
                final isSelected = _selectedRarity == rarity;
                // Warna Chip sesuai rarity
                Color chipColor = isSelected 
                    ? _getRarityColor(rarity) 
                    : Colors.grey[100]!;
                Color textColor = isSelected ? Colors.white : Colors.grey[600]!;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(rarity),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedRarity = rarity),
                    selectedColor: chipColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(color: textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
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

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.amber;
      default: return AppColors.darkAzure; // Common / All
    }
  }

  List<AvatarModel> _applyFilterAndSort(List<AvatarModel> list) {
    List<AvatarModel> filtered = List.from(list);
    if (_selectedRarity != 'All') {
      filtered = filtered.where((a) => a.rarity.toLowerCase() == _selectedRarity.toLowerCase()).toList();
    }
    if (_sortBy == 'Lowest Price') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    return filtered;
  }
}

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
      case 'legendary': rarityColor = Colors.amber; break;
      default: rarityColor = Colors.grey;
    }

    // Fix URL SVG->PNG
    final displayImageUrl = widget.avatar.imageUrl.replaceAll('/svg', '/png');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(_isHovered ? 0.2 : 0.05),
              blurRadius: _isHovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: _isHovered ? rarityColor.withOpacity(0.5) : Colors.transparent, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IMAGE AREA
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: rarityColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.network(
                              displayImageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // INFO AREA
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(widget.avatar.name, 
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(widget.avatar.rarity.toUpperCase(), 
                                  style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Text("Rp ${widget.avatar.price.toInt()}", 
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // ACTION MENU (Edit/Toggle)
              Positioned(
                top: 8, right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (val) {
                    final bloc = context.read<AdminAvatarBloc>();
                    if (val == 'edit') _showAvatarDialog(context, avatar: widget.avatar, bloc: bloc);
                    if (val == 'toggle') bloc.add(ToggleAvatarEvent(widget.avatar.id));
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(
                      value: 'toggle', 
                      child: Text(widget.avatar.isActive ? "Archive (Soft Delete)" : "Restore", 
                        style: TextStyle(color: widget.avatar.isActive ? Colors.red : Colors.green)),
                    ),
                  ],
                ),
              ),

              if (!widget.avatar.isActive)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: Chip(
                        label: Text("ARCHIVED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DIALOG FORM (MODERN STYLE) ---
void _showAvatarDialog(BuildContext context, {AvatarModel? avatar, required AdminAvatarBloc bloc}) {
  final isEdit = avatar != null;
  final nameCtrl = TextEditingController(text: isEdit ? avatar.name : '');
  final urlCtrl = TextEditingController(text: isEdit ? avatar.imageUrl : '');
  final priceCtrl = TextEditingController(text: isEdit ? avatar.price.toInt().toString() : '');
  String rarity = isEdit ? avatar.rarity : 'common';
  
  XFile? selectedImage;
  final picker = ImagePicker();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> pickImage() async {
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              setState(() {
                selectedImage = picked; // [UBAH] Simpan langsung XFile-nya
                urlCtrl.clear();
              });
            }
          }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isEdit ? "Edit Avatar" : "New Avatar", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.darkAzure.withOpacity(0.3)),
                      ),
                      // [LOGIC BARU UNTUK MENAMPILKAN GAMBAR]
                      child: selectedImage == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload_rounded, color: AppColors.darkAzure, size: 32),
                                SizedBox(height: 8),
                                Text("Upload Image", style: TextStyle(fontSize: 10)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: kIsWeb 
                                  ? Image.network(selectedImage!.path, fit: BoxFit.cover) // Web pakai Network
                                  : Image.file(File(selectedImage!.path), fit: BoxFit.cover), // Mobile pakai File
                            ),
                    ),
                ),
                const SizedBox(height: 16),
                const Text("OR Enter URL", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildField(nameCtrl, "Name", Icons.face_rounded),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  enabled: selectedImage == null, 
                  decoration: InputDecoration(
                    labelText: "Image URL",
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: selectedImage == null ? Colors.grey[50] : Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 12),
                _buildField(priceCtrl, "Price", Icons.monetization_on_rounded, isNumber: true),
                const SizedBox(height: 12),
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
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAzure,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final price = double.tryParse(priceCtrl.text) ?? 0;
                if (isEdit) {
                  bloc.add(EditAvatarEvent(avatar.id, nameCtrl.text, urlCtrl.text, price, rarity));
                } else {
                  bloc.add(AddAvatarEvent(nameCtrl.text, urlCtrl.text, price, rarity, file: selectedImage));
                }
                Navigator.pop(ctx);
              },
              child: const Text("Save Avatar"),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}