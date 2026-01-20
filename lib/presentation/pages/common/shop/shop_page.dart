import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
// [FIX] Import Bloc yang benar
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/student/payment/payment_state.dart';
import 'package:quizify_proyek_mmp/presentation/pages/common/shop/shop_desktop.dart';
import 'package:quizify_proyek_mmp/presentation/pages/common/shop/shop_mobile.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatelessWidget {
  final bool isTeacher;
  const ShopPage({super.key, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ShopBloc(context.read<ShopRepository>())..add(LoadShopData()),
        ),
        BlocProvider.value(value: BlocProvider.of<PaymentBloc>(context)),
      ],
      child: const _ShopPageContent(),
    );
  }
}

class _ShopPageContent extends StatefulWidget {
  const _ShopPageContent();

  @override
  State<_ShopPageContent> createState() => _ShopPageContentState();
}

class _ShopPageContentState extends State<_ShopPageContent> {
  bool _isLoadingDialogShowing = false;

  void _closeLoadingDialog() {
    if (_isLoadingDialogShowing) {
      _isLoadingDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentLoading) {
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
                    Text('Processing payment...'),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is PaymentSnapCreated) {
          _closeLoadingDialog();
          _showPaymentMethod(context, state);
        }
        if (state is PaymentError) {
          _closeLoadingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return const ShopDesktop();
          } else {
            return const ShopMobile();
          }
        },
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

  Future<void> _navigateToPayment(
    BuildContext context,
    String snapToken,
    String orderId,
  ) async {
    const bool isProduction = false;
    final String baseUrl = isProduction
        ? 'https://app.midtrans.com/snap/v2/vtweb/'
        : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';
    final Uri snapUrl = Uri.parse('$baseUrl$snapToken');
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
          _showErrorDialog(
            context,
            'Tidak dapat membuka halaman pembayaran. Silakan coba lagi.',
          );
          return;
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Gagal membuka halaman pembayaran: $e');
      }
    }
  }

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
}

class _ShopGrid extends StatelessWidget {
  final List<AvatarModel> items; // [FIX] Terima List AvatarModel
  final bool isInventory;

  const _ShopGrid({required this.items, required this.isInventory});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isInventory ? "You don't own any items yet." : "Shop is empty.",
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 3 : 2);

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _ShopItemCard(
              avatar: items[index], // [FIX] Kirim object AvatarModel
              isInventory: isInventory,
            );
          },
        );
      },
    );
  }
}

class _ShopItemCard extends StatefulWidget {
  final AvatarModel avatar;
  final bool isInventory;

  const _ShopItemCard({required this.avatar, required this.isInventory});

  @override
  State<_ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<_ShopItemCard> {
  bool _isHovered = false;

  // [FIX] Fungsi untuk memperbaiki URL Gambar
  String _getValidImageUrl(String url) {
    // 1. Jika Dicebear SVG -> Ubah ke PNG
    if (url.contains('dicebear.com') && url.contains('/svg')) {
      return url.replaceAll('/svg', '/png');
    }

    // 2. Jika Localhost di Android Emulator -> Ubah ke 10.0.2.2
    // (Hanya jika Anda nanti upload gambar sendiri ke backend)
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final rarity = widget.avatar.rarity;

    Color rarityColor;
    switch (rarity.toLowerCase()) {
      case 'rare':
        rarityColor = Colors.blue;
        break;
      case 'epic':
        rarityColor = Colors.purple;
        break;
      case 'legendary':
        rarityColor = Colors.amber;
        break;
      default:
        rarityColor = Colors.grey;
    }

    // [FIX] Gunakan fungsi helper di sini
    final imageUrl = _getValidImageUrl(widget.avatar.imageUrl);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
          //     blurRadius: _isHovered ? 16 : 8,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
          border: (widget.isInventory && widget.avatar.isActive)
              ? Border.all(color: Colors.green, width: 3)
              : (_isHovered
                    ? Border.all(
                        color: AppColors.darkAzure.withOpacity(0.3),
                        width: 2,
                      )
                    : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. IMAGE AREA ---
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // [FIX] Tampilkan Gambar
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        // Loading Builder
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        // Error Builder (Fallback jika masih gagal)
                        errorBuilder: (_, error, stackTrace) {
                          print("Image Error: $error"); // Debugging di console
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 30,
                              ),
                              Text(
                                "Error",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rarity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.isInventory && widget.avatar.isActive)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // --- 2. INFO AREA ---
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.avatar.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (!widget.isInventory)
                          Text(
                            "Rp ${widget.avatar.price.toInt()}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),

                    // --- 3. ACTION BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: widget.isInventory
                          ? (widget.avatar.isActive
                                ? const Center(
                                    child: Text(
                                      "Equipped",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : OutlinedButton(
                                    onPressed: () {
                                      context.read<ShopBloc>().add(
                                        EquipItemEvent(widget.avatar.id),
                                      );
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          if (context.mounted) {
                                            context.read<AuthBloc>().add(
                                              const RefreshUserEvent(),
                                            );
                                          }
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.darkAzure,
                                      side: const BorderSide(
                                        color: AppColors.darkAzure,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Equip",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ))
                          : ElevatedButton(
                              onPressed: () {
                                // Trigger payment event untuk avatar
                                context.read<PaymentBloc>().add(
                                  CreatePaymentEvent(
                                    type: 'avatar',
                                    avatarId: widget.avatar.id.toString(),
                                    amount: widget.avatar.price,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAzure,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Buy Now",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
