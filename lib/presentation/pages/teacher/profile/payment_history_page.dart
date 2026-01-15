import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/payment_status_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_state.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;

  const PaymentHistoryPage({required this.userId, super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
    _paymentBloc.add(FetchPaymentHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: AppColors.darkAzure,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkAzure),
              );
            }

            if (state is PaymentHistoryLoaded) {
              if (state.payments.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _paymentBloc.add(FetchPaymentHistoryEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.payments.length,
                  itemBuilder: (context, index) {
                    final payment = state.payments[index];
                    return _buildPaymentCard(context, payment);
                  },
                ),
              );
            }

            if (state is PaymentError) {
              return _buildErrorState(state.message);
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat transaksi.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _paymentBloc.add(FetchPaymentHistoryEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Riwayat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              // Tampilkan pesan error bersih tanpa prefix Exception
              message.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _paymentBloc.add(FetchPaymentHistoryEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAzure,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentStatusModel payment) {
    final bool isPending = payment.status.toLowerCase() == 'pending';
    final bool isSuccess = [
      'capture',
      'settlement',
      'success',
    ].contains(payment.status.toLowerCase());
    final bool isFailed = [
      'deny',
      'cancel',
      'expire',
      'failure',
    ].contains(payment.status.toLowerCase());

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else if (isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (payment.itemName != null) ...[
                        Text(
                          payment.itemName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkAzure,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        payment.orderId,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(payment.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        payment.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  currencyFormat.format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isPending && payment.snapToken != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToPayment(
                      context,
                      payment.snapToken!,
                      payment.orderId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkAzure,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Navigate to Midtrans Snap payment page
  Future<void> _navigateToPayment(
    BuildContext context,
    String snapToken,
    String orderId,
  ) async {
    const bool isProduction = false; // TODO: Set to true for production

    final String baseUrl = isProduction
        ? 'https://app.midtrans.com/snap/v2/vtweb/'
        : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';

    final Uri snapUrl = Uri.parse('$baseUrl$snapToken');

    print('🔗 [PaymentHistoryPage] Opening Midtrans Snap URL: $snapUrl');
    print('📋 [PaymentHistoryPage] Order ID: $orderId');

    try {
      final bool launched = await launchUrl(
        snapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final bool inAppLaunched = await launchUrl(
          snapUrl,
          mode: LaunchMode.inAppBrowserView,
        );

        if (!inAppLaunched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak dapat membuka halaman pembayaran. Silakan coba lagi.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Show confirmation dialog after user returns from payment
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          _showPaymentConfirmationDialog(context, orderId);
        }
      }
    } catch (e) {
      print('❌ [PaymentHistoryPage] Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka halaman pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Status Pembayaran'),
        content: const Text('Sudah selesai melakukan pembayaran?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPaymentStatus(context, orderId);
            },
            child: const Text('Cek Status'),
          ),
        ],
      ),
    );
  }

  void _checkPaymentStatus(BuildContext context, String orderId) {
    _paymentBloc.add(CheckPaymentStatusEvent(orderId));

    // Refresh history
    Future.delayed(const Duration(seconds: 1), () {
      _paymentBloc.add(FetchPaymentHistoryEvent());
    });
  }
}
