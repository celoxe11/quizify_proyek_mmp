import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_state.dart';
// Import halaman transaksi
import 'package:quizify_proyek_mmp/presentation/pages/admin/transaction/admin_transaction_page.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // [FIX] Ubah length jadi 3 (Subs, Roles, Transactions)
    _tabController = TabController(length: 3, vsync: this);
    
    // Load data users & subscription
    context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Subscriptions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkAzure,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.darkAzure,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.darkAzure,
          tabs: const [
            Tab(text: "Subscriptions", icon: Icon(Icons.card_membership)),
            Tab(text: "User Roles", icon: Icon(Icons.admin_panel_settings)),
            // [FIX] Tab Baru
            Tab(text: "Transactions", icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Subscription
          _SubscriptionTab(),
          
          // TAB 2: Roles
          _RolesTab(),

          // TAB 3: Transactions
          const AdminTransactionPage(isEmbedded: true),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1: SUBSCRIPTION MANAGEMENT (VIEW, ADD, EDIT)
// =============================================================================
class _SubscriptionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersBloc, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
        }

        if (state is AdminUsersLoaded) {
          final subs = state.availableSubscriptions;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader("Subscription Tiers", "Manage prices and package names."),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    if (subs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No subscriptions found."),
                      )
                    else
                      ...subs.map((sub) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.darkAzure.withOpacity(0.1),
                          child: Text("${sub.id}", style: const TextStyle(color: AppColors.darkAzure, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(sub.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          _formatCurrency(sub.price), 
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showSubscriptionDialog(context, subscription: sub),
                        ),
                      )),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add_circle, color: AppColors.darkAzure),
                      title: const Text("Add New Tier", style: TextStyle(color: AppColors.darkAzure, fontWeight: FontWeight.bold)),
                      onTap: () => _showSubscriptionDialog(context), // Mode Tambah
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  // Dialog untuk Add & Edit
  void _showSubscriptionDialog(BuildContext context, {SubscriptionModel? subscription}) {
    final isEditing = subscription != null;
    final nameController = TextEditingController(text: isEditing ? subscription.status : '');
    final priceController = TextEditingController(text: isEditing ? subscription.price.toInt().toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Edit Tier" : "New Subscription Tier"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tier Name (e.g. Gold)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price (IDR)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: "IDR",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;

                Navigator.pop(ctx);

                if (isEditing) {
                  // Kirim Event Update
                  context.read<AdminUsersBloc>().add(
                    UpdateSubscriptionEvent(id: subscription.id, name: name, price: price)
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updating...")));
                } else {
                  // Kirim Event Create
                  context.read<AdminUsersBloc>().add(
                    CreateSubscriptionEvent(name, price)
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Creating...")));
                }
              }
            },
            child: Text(isEditing ? "Update" : "Create"),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double price) {
    if (price == 0) return "Free";
    return "Rp ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}

// =============================================================================
// TAB 2: ROLES MANAGEMENT (INFO ONLY)
// =============================================================================
class _RolesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roles = [
      {'name': 'Student', 'desc': 'Can join quizzes and view history.', 'color': Colors.orange},
      {'name': 'Teacher', 'desc': 'Can create quizzes and view student reports.', 'color': AppColors.darkAzure},
      {'name': 'Admin', 'desc': 'Full access to system settings and users.', 'color': Colors.red},
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader("System Roles", "Pre-defined roles in the application."),
        const SizedBox(height: 16),
        ...roles.map((role) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (role['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.security, color: role['color'] as Color),
            ),
            title: Text(role['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(role['desc'] as String),
          ),
        )),
      ],
    );
  }
}

// Helper Widget Global (Bisa diakses oleh _SubscriptionTab dan _RolesTab)
Widget _buildHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: Colors.grey)),
    ],
  );
}