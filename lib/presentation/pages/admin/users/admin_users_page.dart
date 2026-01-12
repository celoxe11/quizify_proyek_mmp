import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
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

class EditUserDialog extends StatefulWidget {
  final User user;
  final List<SubscriptionModel> subscriptions;

  const EditUserDialog({super.key, required this.user, required this.subscriptions});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>(); 
  late String _selectedRole;
  int? _selectedSubId;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    // --- LOGIC PENGECEKAN DATA HANTU ---
    // Cek apakah ID langganan user saat ini ada di daftar yang tersedia?
    bool isIdExist = widget.subscriptions.any((sub) => sub.id == widget.user.subscriptionId);

    if (isIdExist) {
      _selectedSubId = widget.user.subscriptionId;
    } else {
      // [PENTING] Jika tidak ketemu, biarkan NULL.
      // Ini akan membuat dropdown kosong dan memaksa admin memilih ulang.
      _selectedSubId = null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit User"),
      content: Form( // [NEW] Bungkus dengan Form
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ROLE DROPDOWN
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 16),
            
            // SUBSCRIPTION DROPDOWN
            DropdownButtonFormField<int>(
              value: _selectedSubId, // Bisa null
              decoration: InputDecoration(
                labelText: 'Subscription',
                border: const OutlineInputBorder(),
                // Beri warna merah pada label jika data sebelumnya error/hilang
                labelStyle: _selectedSubId == null ? const TextStyle(color: Colors.red) : null,
              ),
              hint: const Text("Please select subscription", style: TextStyle(color: Colors.red)), // Petunjuk jika null
              items: widget.subscriptions.map((sub) {
                return DropdownMenuItem(
                  value: sub.id,
                  child: Text(sub.status),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedSubId = val),
              // [NEW] Validasi Wajib Pilih
              validator: (value) => value == null ? 'Wajib dipilih!' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Cek validasi sebelum kirim
            if (_formKey.currentState!.validate()) {

              print("Sending from Dialog: $_selectedRole, $_selectedSubId");

              Navigator.pop(context, {
                'role': _selectedRole,
                'subId': _selectedSubId,
              });
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminUsersBloc>().add(FetchAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkAzure,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
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
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkAzure),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 18,
                          color: AppColors.darkAzure,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Filter",
                          style: TextStyle(
                            color: AppColors.darkAzure,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (value) {
                    // Panggil Event Filter di Bloc
                    context.read<AdminUsersBloc>().add(FilterUsersEvent(value));
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'All',
                          child: Text('Show All'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'Teacher',
                          child: Text('Teachers Only'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Student',
                          child: Text('Students Only'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'Active',
                          child: Text('Active Users'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Blocked',
                          child: Text('Blocked Users'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- TABLE CARD ---
            Expanded(
              child: Card(
                elevation: 0,
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
                          color: AppColors.darkAzure,
                        ),
                      );
                    } else if (state is AdminUsersError) {
                      return Center(child: Text(state.message));
                    } else if (state is AdminUsersLoaded) {
                      if (state.filteredUsers.isEmpty) {
                        return const Center(child: Text("No users found"));
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildUsersTable(
                            state.filteredUsers,
                            constraints.maxWidth,
                          );
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
              constraints: BoxConstraints(minWidth: minWidth),
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columnSpacing: 24,
                horizontalMargin: 24,
                columns: const [
                  DataColumn(
                    label: Text(
                      'USER INFO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ROLE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'SUBSCRIPTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: users.map((user) {
                  final isBlocked =
                      !user.isActive; // isActive true = Tidak Diblokir
                  return DataRow(
                    cells: [
                      // USER INFO
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.dirtyCyan.withOpacity(
                                0.2,
                              ),
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.darkAzure,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ROLE
                      DataCell(_buildRoleBadge(user.role)),
                      // SUBSCRIPTION
                      DataCell(
                        Text(
                          user.subscriptionStatus ?? 'Free',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      // STATUS
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
                      // ACTIONS
                      DataCell(
                        Row(
                          children: [
                            // 1. BLOCK / UNBLOCK BUTTON
                            Tooltip(
                              message: isBlocked
                                  ? "Unblock User"
                                  : "Block User",
                              child: InkWell(
                                onTap: () =>
                                    _showBlockConfirmation(context, user),
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
                            // 3. EDIT BUTTON
                            Tooltip(
                              message: "Edit User",
                              child: InkWell(
                                onTap: () async {
                                  // Ambil list subscription dari state Bloc saat ini
                                  final currentState = context
                                      .read<AdminUsersBloc>()
                                      .state;
                                  List<SubscriptionModel> subs = [];
                                  if (currentState is AdminUsersLoaded) {
                                    subs = currentState.availableSubscriptions;
                                  }

                                  // Tampilkan Dialog
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (ctx) => EditUserDialog(
                                          user: user,
                                          subscriptions: subs,
                                        ),
                                      );

                                  // Jika user klik Save
                                  if (result != null) {
                                    context.read<AdminUsersBloc>().add(
                                      UpdateUserEvent(
                                        userId: user.id,
                                        role: result['role'],
                                        subscriptionId: result['subId'],
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 2. VIEW LOGS BUTTON (Navigasi ke Page Logs)
                            Tooltip(
                              message: "View Activity Logs",
                              child: InkWell(
                                onTap: () {
                                  // Navigasi dengan Query Param untuk filter user spesifik
                                  context.go(
                                    Uri(
                                      path: '/admin/logs',
                                      queryParameters: {'user_id': user.id},
                                    ).toString(),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.blue,
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

  Widget _buildRoleBadge(String role) {
    bool isTeacher = role == 'teacher';
    bool isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTeacher
            ? AppColors.darkAzure.withOpacity(0.1)
            : (isAdmin
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTeacher
              ? AppColors.darkAzure
              : (isAdmin ? Colors.red : Colors.orange),
          width: 1,
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isTeacher
              ? AppColors.darkAzure
              : (isAdmin ? Colors.red : Colors.orange[800]),
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, User user) {
    final isBlocked = !user.isActive; // Jika !isActive berarti sedang diblokir

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isBlocked ? Icons.check_circle : Icons.warning_amber,
              color: isBlocked ? Colors.green : AppColors.accentRed,
            ),
            const SizedBox(width: 8),
            Text(isBlocked ? 'Activate User' : 'Block User'),
          ],
        ),
        content: Text(
          isBlocked
              ? 'Are you sure you want to reactivate ${user.name}? They will be able to access the system again.'
              : 'Are you sure you want to block ${user.name}? They will lose access immediately.',
        ),
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Panggil Event Bloc untuk update ke Backend
              context.read<AdminUsersBloc>().add(
                ToggleUserStatusEvent(
                  userId: user.id,
                  currentStatus: user.isActive,
                ),
              );
            },
            child: Text(isBlocked ? 'Reactivate' : 'Block Access'),
          ),
        ],
      ),
    );
  }
}
