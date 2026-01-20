import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/auth/auth_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';
import 'package:quizify_proyek_mmp/presentation/pages/common/shop/shop_desktop.dart';
import 'package:quizify_proyek_mmp/presentation/pages/common/shop/shop_mobile.dart';

class ShopPage extends StatelessWidget {
  final bool isTeacher;
  const ShopPage({super.key, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ShopBloc(context.read<ShopRepository>())..add(LoadShopData()),
      child: BlocListener<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ShopError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is BuyItemSuccess) {
            // Refresh shop data to update inventory
            context.read<ShopBloc>().add(LoadShopData());

            // Refresh user data to update points balance
            context.read<AuthBloc>().add(const RefreshUserEvent());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is BuyItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
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
      ),
    );
  }
}
