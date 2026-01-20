import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/payment_status_model.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';

/// Halaman pilih subscription plan
class SubscriptionPlanPage extends StatefulWidget {
  final String userId;

  const SubscriptionPlanPage({required this.userId, super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  late PaymentBloc _paymentBloc;
  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Get existing PaymentBloc dari context, jangan membuat baru
    _paymentBloc = context.read<PaymentBloc>();

    // Fetch subscription plans dengan userId
    print(
      '📝 [SubscriptionPlanPage] Fetching plans for user: ${widget.userId}',
    );
    _paymentBloc.add(FetchSubscriptionPlansEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    // Jangan close BLoC karena masih digunakan oleh app
    super.dispose();
  }

  /// Helper method to close loading dialog
  void _closeLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShowing) {
      _isLoadingDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        // Show loading dialog saat membuat payment
        if (state is PaymentLoading) {
          _isLoadingDialogShowing = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.darkAzure),
                    const SizedBox(height: 16),
                    const Text(
                      'Membuat pembayaran...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Navigate to payment ketika snap token sudah dibuat
        if (state is PaymentSnapCreated) {
          // Close loading dialog first
          _closeLoadingDialog(context);
          // Show payment method dialog
          _showPaymentMethod(context, state);
        }

        // Handle payment status loaded
        if (state is PaymentStatusLoaded) {
          // Close any loading dialog
          _closeLoadingDialog(context);
          // Show payment status result
          _showPaymentStatusResult(context, state.status);
        }

        // Show error
        if (state is PaymentError) {
          // Close loading dialog if open
          _closeLoadingDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkAzure,
          foregroundColor: Colors.white,
          title: const Text('Choose Subscription Plan'),
          elevation: 0,
        ),
        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is SubscriptionPlansLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkAzure),
              );
            }

            if (state is PaymentError) {
              return _buildErrorState(context);
            }

            if (state is SubscriptionPlansLoaded) {
              return _buildPlansList(context, state.plans);
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkAzure),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<SubscriptionModel> plans) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pilih Paket Berlangganan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAzure,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tingkatkan akses Anda dengan berlangganan premium',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 24),

            // Plans List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _buildPlanCard(context, plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionModel plan) {
    final isPopular = plan.id.toString().contains('yearly');

    return GestureDetector(
      onTap: () {
        // Create payment dengan subscription plan ID dan amount
        _paymentBloc.add(
          CreatePaymentEvent(
            type: 'subscription',
            planId: plan.id.toString(),
            amount: plan.price,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.darkAzure : Colors.grey[300]!,
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: AppColors.darkAzure.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular badge
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkAzure,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isPopular) const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp${plan.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAzure,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        _paymentBloc.add(
                          CreatePaymentEvent(
                            type: 'subscription',
                            planId: plan.id.toString(),
                            amount: plan.price,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAzure,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pilih Paket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethod(BuildContext context, PaymentSnapCreated state) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAzure,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih metode pembayaran Anda:',
                style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
              ),
              const SizedBox(height: 20),

              // Midtrans Payment Option
              _buildPaymentMethodOption(
                context: context,
                icon: Icons.payment,
                title: 'Midtrans Payment',
                subtitle: 'Kartu Kredit, E-Wallet, Transfer Bank',
                onTap: () async {
                  Navigator.pop(context);
                  await _navigateToPayment(
                    context,
                    state.snap.snapToken,
                    state.snap.orderId,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAzure,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.darkAzure.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.darkAzure, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAzure,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  /// Navigate to Midtrans Snap payment page
  ///
  /// Sandbox URL: https://app.sandbox.midtrans.com/snap/v2/vtweb/{SNAP_TOKEN}
  /// Production URL: https://app.midtrans.com/snap/v2/vtweb/{SNAP_TOKEN}
  Future<void> _navigateToPayment(
    BuildContext context,
    String snapToken,
    String orderId,
  ) async {
    // Use sandbox URL for development, change to production when deploying
    // Sandbox: https://app.sandbox.midtrans.com/snap/v2/vtweb/
    // Production: https://app.midtrans.com/snap/v2/vtweb/
    const bool isProduction = false; // TODO: Set to true for production

    final String baseUrl = isProduction
        ? 'https://app.midtrans.com/snap/v2/vtweb/'
        : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';

    final Uri snapUrl = Uri.parse('$baseUrl$snapToken');

    print('🔗 [SubscriptionPlanPage] Opening Midtrans Snap URL: $snapUrl');
    print('📋 [SubscriptionPlanPage] Order ID: $orderId');

    try {
      // Launch URL in external browser
      final bool launched = await launchUrl(
        snapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // If external browser failed, try in-app browser
        final bool inAppLaunched = await launchUrl(
          snapUrl,
          mode: LaunchMode.inAppBrowserView,
        );

        if (!inAppLaunched && context.mounted) {
          _showErrorDialog(
            context,
            'Tidak dapat membuka halaman pembayaran. Silakan coba lagi.',
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
      print('❌ [SubscriptionPlanPage] Error launching URL: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Gagal membuka halaman pembayaran: $e');
      }
    }
  }

  /// Show payment confirmation dialog after returning from Midtrans
  void _showPaymentConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: AppColors.darkAzure),
            SizedBox(width: 8),
            Text('Status Pembayaran'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sudah selesai melakukan pembayaran?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.darkAzure,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order ID: $orderId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _checkPaymentStatus(context, orderId);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Cek Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Check payment status manually
  void _checkPaymentStatus(BuildContext context, String orderId) {
    // Show loading
    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.darkAzure),
              SizedBox(height: 16),
              Text('Mengecek status pembayaran...'),
            ],
          ),
        ),
      ),
    );

    // Dispatch check status event - BlocListener will handle the response
    _paymentBloc.add(CheckPaymentStatusEvent(orderId));
  }

  /// Show payment status result
  void _showPaymentStatusResult(
    BuildContext context,
    PaymentStatusModel status,
  ) {
    final bool isSuccess =
        status.status.toLowerCase() == 'settlement' ||
        status.status.toLowerCase() == 'capture' ||
        status.status.toLowerCase() == 'success';

    final bool isPending = status.status.toLowerCase() == 'pending';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle
                  : (isPending ? Icons.schedule : Icons.cancel),
              color: isSuccess
                  ? Colors.green
                  : (isPending ? Colors.orange : Colors.red),
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess
                  ? 'Pembayaran Berhasil!'
                  : (isPending ? 'Menunggu Pembayaran' : 'Pembayaran Gagal'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${status.status}'),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${status.orderId}',
              style: const TextStyle(fontSize: 12),
            ),
            if (isSuccess) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Subscription Anda telah aktif!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(dialogContext).pop();

              if (isSuccess) {
                // Trigger auth refresh to update user data (including subscription)
                try {
                  context.read<AuthBloc>().add(const RefreshUserEvent());
                } catch (e) {
                  print('⚠️ Could not trigger auth refresh: $e');
                }

                // Pop until we're back at the main navigation
                Navigator.of(context).popUntil((route) => route.isFirst);

                // Navigate to profile
                context.go('/student/profile');
              }
            },
            child: Text(isSuccess ? 'Selesai' : 'Tutup'),
          ),
          if (isPending)
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _checkPaymentStatus(context, status.orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAzure,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cek Lagi'),
            ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Failed to load subscription plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _paymentBloc.add(
                FetchSubscriptionPlansEvent(userId: widget.userId),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAzure,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
