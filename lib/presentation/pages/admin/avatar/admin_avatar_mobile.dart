import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
// Pastikan path ini sesuai dengan tempat Anda menyimpan file widgets tadi
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_widgets.dart'; 

class AdminAvatarMobileView extends StatelessWidget {
  final List<AvatarModel> avatars;
  final Function(AvatarModel) onEdit;
  final Function(String) onToggle;

  const AdminAvatarMobileView({
    super.key,
    required this.avatars,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Mobile: Responsif 1 atau 2 Kolom
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width < 350 ? 1 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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