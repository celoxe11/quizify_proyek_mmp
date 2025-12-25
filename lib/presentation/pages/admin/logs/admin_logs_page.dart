import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/user_log_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';

class AdminLogsPage extends StatefulWidget {
  final String? userId; 
  const AdminLogsPage({super.key, this.userId});


  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  late Future<List<UserLogModel>> _logsFuture;

  @override
  void initState() {
    super.initState();
    // Mengambil data log dari repository saat halaman dibuka
    _logsFuture = context.read<AdminRepositoryImpl>().fetchLogs(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background abu muda
      appBar: AppBar(
        title: Text(
          widget.userId != null ? "Logs for ${widget.userId}" : "All Activity Logs",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAzure),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.darkAzure),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _logsFuture = context.read<AdminRepositoryImpl>().fetchLogs(userId: widget.userId);
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Activities",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            // --- TABLE SECTION ---
            Expanded(
              child: Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias, // Agar header rounded mengikuti card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: FutureBuilder<List<UserLogModel>>(
                  future: _logsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    final logs = snapshot.data ?? [];

                    if (logs.isEmpty) {
                      return const Center(child: Text("No activity logs found."));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(AppColors.darkAzure),
                                  dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                    return Colors.white; // Bisa diganti logic selang-seling jika mau
                                  }),
                                  headingTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  columnSpacing: 24,
                                  horizontalMargin: 24,
                                  columns: const [
                                    DataColumn(label: Text('DATE & TIME')),
                                    DataColumn(label: Text('USER')),
                                    DataColumn(label: Text('ACTION TYPE')),
                                    DataColumn(label: Text('ENDPOINT / DETAIL')),
                                    DataColumn(label: Text('ID')),
                                  ],
                                  rows: logs.map((log) {
                                    // Format tanggal sederhana
                                    final dateStr = log.createdAt.toString().substring(0, 16).replaceAll('T', ' ');
                                    
                                    return DataRow(
                                      cells: [
                                        // 1. Date
                                        DataCell(Text(dateStr, style: const TextStyle(fontSize: 13))),
                                        
                                        // 2. User Name
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.grey.shade200,
                                                child: Text(
                                                  log.userName.isNotEmpty ? log.userName[0].toUpperCase() : '?',
                                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(log.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        
                                        // 3. Action Type (Badge)
                                        DataCell(_buildActionBadge(log.actionType)),
                                        
                                        // 4. Endpoint
                                        DataCell(
                                          Text(
                                            log.endpoint ?? '-',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontFamily: 'monospace'),
                                          ),
                                        ),
                                        
                                        // 5. User ID
                                        DataCell(Text(log.userId, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat Badge warna-warni berdasarkan tipe aksi
  Widget _buildActionBadge(String action) {
    Color bgColor;
    Color textColor;

    // Tentukan warna berdasarkan keyword
    String upperAction = action.toUpperCase();
    if (upperAction.contains('LOGIN') || upperAction.contains('SIGN IN')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (upperAction.contains('DELETE') || upperAction.contains('REMOVE')) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
    } else if (upperAction.contains('CREATE') || upperAction.contains('ADD')) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else if (upperAction.contains('UPDATE') || upperAction.contains('EDIT')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        action,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}