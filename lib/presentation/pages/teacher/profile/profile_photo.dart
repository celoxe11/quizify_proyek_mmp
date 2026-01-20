import 'package:flutter/material.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';

class ProfilePhoto extends StatelessWidget {
  final String name;
  final int? currentAvatarId;
  final String? currentAvatarUrl;
  final double size;

  const ProfilePhoto({
    super.key,
    required this.name,
    this.currentAvatarId,
    this.currentAvatarUrl,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl;

    // 1. Prioritas Utama: URL dari Database
    if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      // [FIX] Gunakan replaceAll '.svg' agar aman untuk segala format URL Dicebear
      imageUrl = currentAvatarUrl!.trim().replaceAll('/svg', '/png');
    } 
    // 2. Prioritas Kedua: ID Avatar (Fallback)
    else if (currentAvatarId != null && currentAvatarId! > 0) {
       imageUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=Avatar$currentAvatarId';
    }   
    // 3. Fallback Terakhir: UI Avatars
    else {
      imageUrl = 'https://ui-avatars.com/api/?name=$name&background=random&size=200';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkAzure, width: 3),
        color: Colors.white,
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, loading) {
             if (loading == null) return child;
             return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
          errorBuilder: (_, error, stackTrace) {
            // Debugging: Biar tau kenapa error
            print("Gagal load avatar: $imageUrl | Error: $error");
            return const Icon(Icons.person, size: 50);
          },
        ),
      ),
    );
  }
}