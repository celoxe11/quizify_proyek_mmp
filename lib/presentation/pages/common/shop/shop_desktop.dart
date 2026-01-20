import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';
import 'shop_item_card.dart';

class ShopDesktop extends StatefulWidget {
  const ShopDesktop({super.key});

  @override
  State<ShopDesktop> createState() => _ShopDesktopState();
}

class _ShopDesktopState extends State<ShopDesktop>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when shop page becomes visible
    // This ensures points are updated after completing a quiz
    final currentState = context.read<AuthBloc>().state;
    if (currentState is AuthAuthenticated) {
      context.read<AuthBloc>().add(const RefreshUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with Points Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Avatar Shop',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAzure,
                  ),
                ),
                // Points Display
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${state.user.points} Points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Sidebar Tab (Optional, atau pakai AppBar Tab kayak mobile)
                NavigationRail(
                  selectedIndex: _tabController.index,
                  onDestinationSelected: (int index) =>
                      setState(() => _tabController.animateTo(index)),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.storefront),
                      label: Text('Shop'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.backpack),
                      label: Text('Inventory'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: BlocBuilder<ShopBloc, ShopState>(
                    builder: (context, state) {
                      if (state is ShopLoading)
                        return const Center(child: CircularProgressIndicator());
                      if (state is ShopLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildGrid(state.shopItems, false, state.inventory),
                            _buildGrid(state.inventory, true, state.inventory),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<AvatarModel> items, bool isInventory, List<AvatarModel> inventory) {
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
        print("USER INVENTORY: ${inventory.toString()}");

        return ShopItemCard(
          avatar: items[index],
          isInventory: isInventory,
          inventory: inventory,
        );
      },
    );
  }
}
