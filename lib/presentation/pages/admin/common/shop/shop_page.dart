import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
// Ganti dengan Bloc Shop yang sesuai nantinya
// import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart'; 

class ShopPage extends StatefulWidget {
  final bool isTeacher; // Opsional: Jika ingin membedakan konten sedikit
  const ShopPage({super.key, this.isTeacher = false});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // context.read<ShopBloc>().add(LoadShopItems()); // Load data nanti
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white modern background
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _ShopGrid(isInventory: false), // Tab Belanja
          _ShopGrid(isInventory: true),  // Tab Inventory
        ],
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  final bool isInventory;
  const _ShopGrid({required this.isInventory});

  @override
  Widget build(BuildContext context) {
    // [DUMMY DATA] Nanti diganti dengan state.avatars dari Bloc
    final dummyAvatars = List.generate(8, (index) => index);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsif Grid
        int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
        
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75, // Proporsi kartu memanjang ke bawah
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: dummyAvatars.length,
          itemBuilder: (context, index) {
            return _ShopItemCard(
              index: index,
              isInventory: isInventory,
            );
          },
        );
      },
    );
  }
}

class _ShopItemCard extends StatefulWidget {
  final int index;
  final bool isInventory;

  const _ShopItemCard({required this.index, required this.isInventory});

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Simulasi Rarity
    final rarities = ['Common', 'Rare', 'Epic', 'Legendary'];
    final rarity = rarities[widget.index % rarities.length];
    
    Color rarityColor;
    switch (rarity) {
      case 'Rare': rarityColor = Colors.blue; break;
      case 'Epic': rarityColor = Colors.purple; break;
      case 'Legendary': rarityColor = Colors.amber; break;
      default: rarityColor = Colors.grey;
    }

    // Simulasi Gambar (Dicebear)
    final imageUrl = "https://api.dicebear.com/7.x/avataaars/png?seed=Avatar${widget.index}";

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
          border: _isHovered ? Border.all(color: AppColors.darkAzure.withOpacity(0.3), width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. IMAGE AREA ---
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Background lingkaran halus
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Gambar Avatar
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  // Badge Rarity
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: rarityColor.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))]
                      ),
                      child: Text(
                        rarity.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
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
                          "Cool Avatar ${widget.index}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (!widget.isInventory)
                          Text(
                            "Rp ${15000 + (widget.index * 5000)}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                      ],
                    ),
                    
                    // --- 3. ACTION BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: widget.isInventory
                          ? OutlinedButton(
                              onPressed: () {}, // Logic Equip
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkAzure,
                                side: const BorderSide(color: AppColors.darkAzure),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Equip"),
                            )
                          : ElevatedButton(
                              onPressed: () {}, // Logic Buy
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