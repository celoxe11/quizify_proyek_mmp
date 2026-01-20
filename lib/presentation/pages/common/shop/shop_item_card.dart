import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_event.dart';

class ShopItemCard extends StatefulWidget {
  final AvatarModel avatar;
  final bool isInventory;
  final List<AvatarModel>? inventory; // Add inventory to check ownership

  const ShopItemCard({
    super.key,
    required this.avatar,
    required this.isInventory,
    this.inventory, // Optional inventory list
  });

  @override
  State<ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<ShopItemCard> {
  bool _isHovered = false;

  String _getValidImageUrl(String url) {
    if (url.contains('dicebear.com') && url.contains('/svg')) {
      return url.replaceAll('/svg', '/png');
    }
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  bool get _isOwned {
    if (widget.inventory == null) return false;
    return widget.inventory!.any((item) => item.id == widget.avatar.id);
  }

  void _handleBuyAvatar(int avatarId) {
    // Get current user from AuthBloc
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      _showErrorDialog('Please login to purchase items');
      return;
    }

    final user = authState.user;
    final avatarPrice = widget.avatar.price;

    // Check if user has enough points
    if (user.points < avatarPrice) {
      _showErrorDialog(
        'Insufficient Points!\n\n'
        'You need ${avatarPrice.toInt()} points but only have ${user.points} points.\n'
        'Complete more quizzes to earn points!',
      );
      return;
    }

    // User has enough points, proceed with purchase
    context.read<ShopBloc>().add(BuyItemEvent(avatarId));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Purchase Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarity = widget.avatar.rarity.toLowerCase();

    // [FITUR BARU] Warna Rarity
    Color rarityColor;
    switch (rarity) {
      case 'rare':
        rarityColor = Colors.blue;
        break;
      case 'epic':
        rarityColor = Colors.purple;
        break;
      case 'legendary':
        rarityColor = Colors.amber;
        break;
      default:
        rarityColor = Colors.grey; // Common
    }

    final imageUrl = _getValidImageUrl(widget.avatar.imageUrl);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(
                _isHovered ? 0.2 : 0.05,
              ), // Shadow ikutan warna rarity
              blurRadius: _isHovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          // [FITUR BARU] Border berwarna sesuai Rarity
          border: Border.all(
            color: widget.isInventory && widget.avatar.isActive
                ? Colors
                      .green // Jika Equipped -> Hijau
                : (_isHovered
                      ? rarityColor
                      : Colors.transparent), // Jika Hover -> Warna Rarity
            width: 3,
          ),
        ),
        child: Column(
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
                        color: rarityColor.withOpacity(
                          0.05,
                        ), // Background tipis sesuai rarity
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Badge Rarity
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.avatar.rarity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
                        Text(
                          widget.avatar.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (!widget.isInventory)
                          Text(
                            "${widget.avatar.price.toInt()} Points",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),

                    // BUTTONS
                    SizedBox(
                      width: double.infinity,
                      child: widget.isInventory
                          ? (widget.avatar.isActive
                                ? Center(
                                    child: Text(
                                      "EQUIPPED",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  )
                                : OutlinedButton(
                                    onPressed: () {
                                      context.read<ShopBloc>().add(
                                        EquipItemEvent(widget.avatar.id),
                                      );
                                      context.read<AuthBloc>().add(
                                        UpdateAvatarEvent(
                                          avatarId: widget.avatar.id,
                                          avatarUrl: widget.avatar.imageUrl,
                                        ),
                                      );
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          if (context.mounted) {
                                            context.read<AuthBloc>().add(
                                              const RefreshUserEvent(),
                                            );
                                          }
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.darkAzure,
                                      side: const BorderSide(
                                        color: AppColors.darkAzure,
                                      ),
                                    ),
                                    child: const Text("Equip"),
                                  ))
                          : _isOwned
                          ? Center(
                              child: Text(
                                "OWNED",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  _handleBuyAvatar(widget.avatar.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAzure,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text("Buy Now"),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
