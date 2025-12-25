import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/users/admin_users_state.dart';
import 'package:quizify_proyek_mmp/domain/entities/user.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    // Load data saat halaman dibuka
    context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
              color: AppColors.darkAzure, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.darkAzure),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER TITLE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Registered Users",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pureWhite,
                    foregroundColor: AppColors.darkAzure,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.darkAzure),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- TABLE CARD ---
            Expanded(
              child: Card(
                elevation: 0,
                // [FIX 1] Clip.antiAlias membuat sudut header tabel ikut melengkung (rounded)
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                  builder: (context, state) {
                    if (state is AdminUsersLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.darkAzure));
                    } else if (state is AdminUsersError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(state.message,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    } else if (state is AdminUsersLoaded) {
                      if (state.users.isEmpty) {
                        return const Center(child: Text("No users found"));
                      }
                      
                      // [FIX 2] LayoutBuilder digunakan untuk mengambil lebar Card
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Kirim lebar maksimal ke fungsi tabel
                          return _buildUsersTable(state.users, constraints.maxWidth);
                        },
                      );
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

  Widget _buildUsersTable(List<User> users, double minWidth) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.grey.shade200,
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(AppColors.darkAzure),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
            return Colors.white;
          }),
        ),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // [FIX 3] Paksa lebar tabel minimal selebar layar/card
              // Ini yang bikin background header hijau full ke kanan
              constraints: BoxConstraints(minWidth: minWidth),
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columnSpacing: 24,
                horizontalMargin: 24,
                columns: const [
                  DataColumn(
                      label: Text('USER INFO',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('ROLE',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('SUBSCRIPTION',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('STATUS',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('ACTIONS',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                ],
                rows: users.map((user) {
                  final isBlocked = !user.isActive;
                  return DataRow(
                    cells: [
                      // CELL 1: USER INFO
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.dirtyCyan.withOpacity(0.2),
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppColors.darkAzure,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(user.email,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // CELL 2: ROLE
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: user.role == 'teacher'
                                ? AppColors.darkAzure.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: user.role == 'teacher'
                                  ? AppColors.darkAzure
                                  : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: user.role == 'teacher'
                                  ? AppColors.darkAzure
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                      ),
                      
                      // CELL 3: SUBSCRIPTION
                      DataCell(
                        Text(
                          user.subscriptionStatus ?? 'Free',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      
                      // CELL 4: STATUS
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isBlocked
                                    ? AppColors.accentRed
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBlocked ? 'Blocked' : 'Active',
                              style: TextStyle(
                                color: isBlocked
                                    ? AppColors.accentRed
                                    : Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // CELL 5: ACTIONS
                      DataCell(
                        Row(
                          children: [
                            Tooltip(
                              message: isBlocked ? "Unblock User" : "Block User",
                              child: InkWell(
                                onTap: () => _showBlockConfirmation(context, user),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isBlocked
                                        ? Colors.green.withOpacity(0.1)
                                        : AppColors.accentRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isBlocked ? Icons.lock_open : Icons.block,
                                    color: isBlocked
                                        ? Colors.green
                                        : AppColors.accentRed,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: "Delete User",
                              child: InkWell(
                                onTap: () {}, // Tambahkan logic delete nanti
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                                message: "View Activity Logs",
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/admin/users/logs',
                                      arguments: {
                                        'userId': user.id,
                                        'userName': user.name,
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkAzure.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.history,
                                      color: AppColors.darkAzure,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, User user) {
    final isBlocked = !user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isBlocked ? Icons.check_circle : Icons.warning_amber,
                color: isBlocked ? Colors.green : AppColors.accentRed),
            const SizedBox(width: 8),
            Text(isBlocked ? 'Activate User' : 'Block User'),
          ],
        ),
        content: Text(isBlocked
            ? 'Are you sure you want to reactivate ${user.name}? They will be able to access the system again.'
            : 'Are you sure you want to block ${user.name}? They will lose access immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green : AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminUsersBloc>().add(
                    ToggleUserStatusEvent(
                        userId: user.id, currentStatus: user.isActive),
                  );
            },
            child: Text(isBlocked ? 'Reactivate' : 'Block Access'),
          ),
        ],
      ),
    );
  }
}