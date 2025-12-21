import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_state.dart';
import 'package:quizify_proyek_mmp/domain/entities/user.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart'; // Sesuaikan path

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    // Panggil event load saat halaman dibuka
    context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Users'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "All Registered Users",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                  builder: (context, state) {
                    if (state is AdminUsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminUsersError) {
                      return Center(child: Text(state.message));
                    } else if (state is AdminUsersLoaded) {
                      if (state.users.isEmpty) {
                        return const Center(child: Text("No users found"));
                      }
                      return _buildUsersTable(state.users);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable(List<User> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('User Info', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Subscription', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: users.map((user) {
            final isBlocked = !user.isActive;
            return DataRow(
              cells: [
                DataCell(Text(user.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.role == 'teacher' ? Colors.blue[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: user.role == 'teacher' ? Colors.blue : Colors.green,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: user.role == 'teacher' ? Colors.blue[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(user.subscriptionStatus ?? 'Free')), // Pakai field baru
                DataCell(
                  Row(
                    children: [
                      Icon(
                        isBlocked ? Icons.block : Icons.check_circle,
                        color: isBlocked ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBlocked ? 'Blocked' : 'Active',
                        style: TextStyle(
                          color: isBlocked ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      // Tombol Block / Unblock
                      Tooltip(
                        message: isBlocked ? "Unblock User" : "Block User",
                        child: IconButton(
                          icon: Icon(
                            isBlocked ? Icons.lock_open : Icons.lock_outline,
                            color: isBlocked ? Colors.green : Colors.red,
                          ),
                          onPressed: () => _showBlockConfirmation(context, user),
                        ),
                      ),
                      // Tombol Delete (Optional)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {
                          // Logic delete here
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, User user) {
    final isBlocked = !user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked ? 'Unblock User?' : 'Block User?'),
        content: Text(
          isBlocked 
            ? 'Are you sure you want to reactivate ${user.name}?' 
            : 'Are you sure you want to block ${user.name}? They will not be able to login.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Dispatch Event ke Bloc
              context.read<AdminUsersBloc>().add(
                ToggleUserStatusEvent(userId: user.id, currentStatus: user.isActive),
              );
            },
            child: Text(isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }
}