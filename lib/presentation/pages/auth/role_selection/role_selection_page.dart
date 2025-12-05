import 'package:flutter/material.dart';
import 'role_selection_mobile.dart';
import 'role_selection_desktop.dart';

class RoleSelectionPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const RoleSelectionPage({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return RoleSelectionMobile(userData: userData);
        } else {
          return RoleSelectionDesktop(userData: userData);
        }
      },
    );
  }
}
