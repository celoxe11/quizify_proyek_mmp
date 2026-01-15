import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/domain/repositories/shop_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/shop/shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository repo;

  ShopBloc(this.repo) : super(ShopInitial()) {
    
    on<LoadShopData>((event, emit) async {
      emit(ShopLoading());
      try {
        final results = await Future.wait([
          repo.fetchShopAvatars(),
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
        add(LoadShopData()); // Refresh data
      } catch (e) {
        print("Equip Failed: $e"); // Handle error UI jika perlu
      }
    });
  }
}
