import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';
import 'shop_item_card.dart'; // Import Card Widget yang dipisah

class ShopMobile extends StatefulWidget {
  const ShopMobile({super.key});

  @override
  State<ShopMobile> createState() => _ShopMobileState();
}

class _ShopMobileState extends State<ShopMobile>
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
      appBar: AppBar(
        title: const Text(
          'Avatar Shop',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkAzure,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Points Display
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
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
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.user.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkAzure,
          indicatorColor: AppColors.darkAzure,
          tabs: const [
            Tab(text: "Browse Shop", icon: Icon(Icons.storefront_rounded)),
            Tab(text: "My Inventory", icon: Icon(Icons.backpack_outlined)),
          ],
        ),
      ),
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is ShopLoading)
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          if (state is ShopError)
            return Center(child: Text("Error: ${state.message}"));
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
    );
  }

  Widget _buildGrid(
    List<AvatarModel> items,
    bool isInventory,
    List<AvatarModel> inventory,
  ) {
    if (items.isEmpty) return const Center(child: Text("No items available."));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Mobile 2 Kolom
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ShopItemCard(
          avatar: items[index],
          isInventory: isInventory,
          inventory: inventory,
        );
      },
    );
  }
}
