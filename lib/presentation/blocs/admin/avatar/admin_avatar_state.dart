import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';

abstract class AdminAvatarState {}
class AvatarInitial extends AdminAvatarState {}
class AvatarLoading extends AdminAvatarState {}

class AvatarLoaded extends AdminAvatarState {
  final List<AvatarModel> allAvatars;      // List Backup (Semua Data)
  final List<AvatarModel> filteredAvatars; // List yang Ditampilkan (Setelah Filter)

  AvatarLoaded({
    required this.allAvatars,
    required this.filteredAvatars,
  });
}

class AvatarError extends AdminAvatarState {
  final String message;
  AvatarError(this.message);
}