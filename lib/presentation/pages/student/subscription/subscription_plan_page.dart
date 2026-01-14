import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/payment_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_state.dart';

/// Halaman pilih subscription plan
class SubscriptionPlanPage extends StatefulWidget {
  final String userId;

  const SubscriptionPlanPage({required this.userId, super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  late PaymentBloc _paymentBloc;
  bool _isSelectingPlan = false;

  @override
  void initState() {
    super.initState();
    // Get existing PaymentBloc dari context, jangan membuat baru
    _paymentBloc = context.read<PaymentBloc>();
    
    // Fetch subscription plans dengan userId
    print('📝 [SubscriptionPlanPage] Fetching plans for user: ${widget.userId}');
    _paymentBloc.add(FetchSubscriptionPlansEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    // Jangan close BLoC karena masih digunakan oleh app
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        // Navigate to payment ketika snap token sudah dibuat
        if (state is PaymentSnapCreated && !_isSelectingPlan) {
          _isSelectingPlan = true;
          _showPaymentMethod(context, state);
        }
        // Show error
        if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          _isSelectingPlan = false;
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
                child:
                    CircularProgressIndicator(color: AppColors.darkAzure),
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
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
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
        if (!_isSelectingPlan) {
          _isSelectingPlan = true;
          // Create payment dengan subscription plan ID
          _paymentBloc.add(
            CreatePaymentEvent(
              type: 'subscription',
              planId: plan.id.toString(),
            ),
          );
        }
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
                        if (!_isSelectingPlan) {
                          _isSelectingPlan = true;
                          _paymentBloc.add(
                            CreatePaymentEvent(
                              type: 'subscription',
                              planId: plan.id.toString(),
                            ),
                          );
                        }
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

  void _showPaymentMethod(
    BuildContext context,
    PaymentSnapCreated state,
  ) {
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 20),

              // Midtrans Payment Option
              _buildPaymentMethodOption(
                context: context,
                icon: Icons.payment,
                title: 'Midtrans Payment',
                subtitle: 'Kartu Kredit, E-Wallet, Transfer Bank',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPayment(context, state.snap.snapToken);
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
                    _isSelectingPlan = false;
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
    ).then((_) {
      _isSelectingPlan = false;
    });
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
              child: Icon(
                icon,
                color: AppColors.darkAzure,
                size: 24,
              ),
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
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context, String snapToken) {
    // TODO: Integrate dengan Midtrans UI library
    // Untuk sekarang, show placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Snap Token:'),
            const SizedBox(height: 8),
            SelectableText(
              snapToken,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan: Integrasi Midtrans Snap UI akan ditambahkan di sini',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
              _paymentBloc.add(FetchSubscriptionPlansEvent(userId: widget.userId));
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

