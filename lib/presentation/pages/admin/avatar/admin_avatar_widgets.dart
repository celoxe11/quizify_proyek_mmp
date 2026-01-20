import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';

// --- WIDGET 1: FILTER BAR ---
class AdminAvatarFilterBar extends StatelessWidget {
  final String selectedRarity;
  final String sortBy;
  final Function(String) onRarityChanged;
  final Function(String) onSortChanged;

  const AdminAvatarFilterBar({
    super.key,
    required this.selectedRarity,
    required this.sortBy,
    required this.onRarityChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color getRarityColor(String rarity) {
      switch (rarity.toLowerCase()) {
        case 'rare': return Colors.blue;
        case 'epic': return Colors.purple;
        case 'legendary': return Colors.amber;
        default: return AppColors.darkAzure;
      }
    }

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
                final isSelected = selectedRarity == rarity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(rarity),
                    selected: isSelected,
                    onSelected: (val) => onRarityChanged(rarity),
                    selectedColor: isSelected ? getRarityColor(rarity) : Colors.grey[100]!,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600]!,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
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
                  onSelected: onSortChanged,
                  child: Row(
                    children: [
                      Text(sortBy, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure)),
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
}

// --- WIDGET 2: AVATAR CARD ---
class AvatarCard extends StatefulWidget {
  final AvatarModel avatar;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const AvatarCard({
    super.key,
    required this.avatar,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard> {
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
          border: Border.all(
              color: _isHovered ? rarityColor.withOpacity(0.5) : Colors.transparent,
              width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
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
              Positioned(
                top: 8, right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (val) {
                    if (val == 'edit') widget.onEdit();
                    if (val == 'toggle') widget.onToggle();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                          widget.avatar.isActive ? "Archive" : "Restore",
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

// --- HELPER UNTUK PREVIEW IMAGE (SHARED) ---
Widget buildAvatarPreview(String imageUrl, {XFile? selectedImage}) {
  return Container(
    height: 120, width: 120,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkAzure.withOpacity(0.3))),
    child: selectedImage != null 
      ? ClipRRect(borderRadius: BorderRadius.circular(18), child: kIsWeb ? Image.network(selectedImage.path) : Image.file(File(selectedImage.path)))
      : (imageUrl.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(imageUrl.replaceAll('/svg', '/png'), errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey)))
          : const Icon(Icons.cloud_upload_rounded, size: 40, color: AppColors.darkAzure)),
  );
}