import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
// [FIX] Import Bloc yang benar
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart'; 

class ShopPage extends StatelessWidget {
  final bool isTeacher; 
  const ShopPage({super.key, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    // [FIX] Inject Bloc disini (Bungkus _ShopView dengan BlocProvider)
    return BlocProvider(
      create: (context) => ShopBloc(
        // Pastikan ShopRepository sudah di-inject di main.dart
        context.read<ShopRepository>(), 
      )..add(LoadShopData()), // Gunakan nama event yang benar: LoadShopData
      child: const _ShopView(),
    );
  }
}

class _ShopView extends StatefulWidget {
  const _ShopView();

  @override
  State<_ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<_ShopView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Avatar Shop', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkAzure,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkAzure,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.darkAzure,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Browse Shop", icon: Icon(Icons.storefront_rounded)),
            Tab(text: "My Inventory", icon: Icon(Icons.backpack_outlined)),
          ],
        ),
      ),
      // [FIX] Gunakan BlocBuilder untuk menampilkan data ASLI
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
          }
          if (state is ShopError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is ShopLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _ShopGrid(items: state.shopItems, isInventory: false), // Data dari API
                _ShopGrid(items: state.inventory, isInventory: true),  // Data dari API
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  final List<AvatarModel> items; // [FIX] Terima List AvatarModel
  final bool isInventory;
  
  const _ShopGrid({required this.items, required this.isInventory});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(isInventory ? "You don't own any items yet." : "Shop is empty."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
        
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _ShopItemCard(
              avatar: items[index], // [FIX] Kirim object AvatarModel
              isInventory: isInventory,
            );
          },
        );
      },
    );
  }
}

class _ShopItemCard extends StatefulWidget {
  final AvatarModel avatar;
  final bool isInventory;

  const _ShopItemCard({required this.avatar, required this.isInventory});

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard> {
  bool _isHovered = false;

  // [FIX] Fungsi untuk memperbaiki URL Gambar
  String _getValidImageUrl(String url) {
    // 1. Jika Dicebear SVG -> Ubah ke PNG
    if (url.contains('dicebear.com') && url.contains('/svg')) {
      return url.replaceAll('/svg', '/png');
    }
    
    // 2. Jika Localhost di Android Emulator -> Ubah ke 10.0.2.2
    // (Hanya jika Anda nanti upload gambar sendiri ke backend)
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final rarity = widget.avatar.rarity;
    
    Color rarityColor;
    switch (rarity.toLowerCase()) {
      case 'rare': rarityColor = Colors.blue; break;
      case 'epic': rarityColor = Colors.purple; break;
      case 'legendary': rarityColor = Colors.amber; break;
      default: rarityColor = Colors.grey;
    }

    // [FIX] Gunakan fungsi helper di sini
    final imageUrl = _getValidImageUrl(widget.avatar.imageUrl);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: (widget.isInventory && widget.avatar.isActive)
              ? Border.all(color: Colors.green, width: 3)
              : (_isHovered ? Border.all(color: AppColors.darkAzure.withOpacity(0.3), width: 2) : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. IMAGE AREA ---
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // [FIX] Tampilkan Gambar
                      child: Image.network(
                        imageUrl, 
                        fit: BoxFit.contain,
                        // Loading Builder
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        // Error Builder (Fallback jika masih gagal)
                        errorBuilder: (_, error, stackTrace) {
                          print("Image Error: $error"); // Debugging di console
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey, size: 30),
                              Text("Error", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rarity.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (widget.isInventory && widget.avatar.isActive)
                    const Positioned(
                      top: 12, right: 12,
                      child: Icon(Icons.check_circle, color: Colors.green, size: 24),
                    )
                ],
              ),
            ),

            // --- 2. INFO AREA ---
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.avatar.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (!widget.isInventory)
                          Text(
                            "Rp ${widget.avatar.price.toInt()}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                      ],
                    ),
                    
                    // --- 3. ACTION BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: widget.isInventory
                          ? (widget.avatar.isActive 
                              ? const Center(child: Text("Equipped", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))
                              : OutlinedButton(
                                  onPressed: () {
                                    context.read<ShopBloc>().add(EquipItemEvent(widget.avatar.id));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkAzure,
                                    side: const BorderSide(color: AppColors.darkAzure),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Equip"),
                                ))
                          : ElevatedButton(
                              onPressed: () {
                                // context.read<ShopBloc>().add(BuyItemEvent(widget.avatar.id));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur beli belum aktif")));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAzure,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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