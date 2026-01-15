import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';

// EVENTS
abstract class StudentShopEvent {}
class LoadShopData extends StudentShopEvent {}
class EquipItemEvent extends StudentShopEvent {
  final int avatarId;
  EquipItemEvent(this.avatarId);
}
class BuyItemEvent extends StudentShopEvent {
  final int avatarId;
  BuyItemEvent(this.avatarId);
}

// STATES
abstract class StudentShopState {}
class ShopLoading extends StudentShopState {}
class ShopError extends StudentShopState { final String message; ShopError(this.message); }
class ShopLoaded extends StudentShopState {
  final List<AvatarModel> shopItems;
  final List<AvatarModel> inventory;
  
  ShopLoaded({required this.shopItems, required this.inventory});
}

// BLOC
class StudentShopBloc extends Bloc<StudentShopEvent, StudentShopState> {
  final StudentRepository repo;

  StudentShopBloc(this.repo) : super(ShopLoading()) {
    
    on<LoadShopData>((event, emit) async {
      emit(ShopLoading());
      try {
        // Load Shop & Inventory bersamaan
        final results = await Future.wait([
          repo.fetchShopAvatars(), // Buat endpoint ini di backend atau reuse getAvatars
          repo.fetchMyInventory(),
        ]);
        
        emit(ShopLoaded(
          shopItems: results[0],
          inventory: results[1],
        ));
      } catch (e) {
        emit(ShopError(e.toString()));
      }
    });

    on<EquipItemEvent>((event, emit) async {
      try {
        await repo.equipAvatar(event.avatarId);
        // Refresh data agar UI update (tombol berubah jadi "Equipped")
        add(LoadShopData());
      } catch (e) {
        // Bisa emit error sementara atau snackbar (skip for now)
        print("Equip Failed: $e");
      }
    });

    on<BuyItemEvent>((event, emit) async {
      try {
        await repo.buyAvatar(event.avatarId);
        add(LoadShopData()); // Refresh agar pindah ke inventory
      } catch (e) {
        print("Buy Failed: $e");
      }
    });
  }
}