import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';
import 'shop_item_card.dart';

class ShopDesktop extends StatefulWidget {
  const ShopDesktop({super.key});

  @override
  State<ShopDesktop> createState() => _ShopDesktopState();
}

class _ShopDesktopState extends State<ShopDesktop> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar Tab (Optional, atau pakai AppBar Tab kayak mobile)
          NavigationRail(
            selectedIndex: _tabController.index,
            onDestinationSelected: (int index) => setState(() => _tabController.animateTo(index)),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.storefront), label: Text('Shop')),
              NavigationRailDestination(icon: Icon(Icons.backpack), label: Text('Inventory')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                if (state is ShopLoading) return const Center(child: CircularProgressIndicator());
                if (state is ShopLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(state.shopItems, false),
                      _buildGrid(state.inventory, true),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<AvatarModel> items, bool isInventory) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250, // Card Desktop lebih lebar
        childAspectRatio: 0.75,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ShopItemCard(avatar: items[index], isInventory: isInventory);
      },
    );
  }
}