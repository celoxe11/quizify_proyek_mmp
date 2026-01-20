import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
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
