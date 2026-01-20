import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
// Import widget bersama
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_widgets.dart';

class AdminAvatarDesktopView extends StatelessWidget {
  final List<AvatarModel> avatars;
  final Function(AvatarModel) onEdit;
  final Function(String) onToggle;

  const AdminAvatarDesktopView({
    super.key,
    required this.avatars,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Desktop: 4 - 5 Kolom
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 5 : 4; 

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) => AvatarCard(
        avatar: avatars[index],
        onEdit: () => onEdit(avatars[index]),
        onToggle: () => onToggle(avatars[index].id.toString()),
      ),
    );
  }
}