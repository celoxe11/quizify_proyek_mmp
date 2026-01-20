import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';

abstract class ShopState {}
class ShopInitial extends ShopState {}
class ShopLoading extends ShopState {}
class ShopError extends ShopState { final String message; ShopError(this.message); }
class ShopLoaded extends ShopState {
  final List<AvatarModel> shopItems;
  final List<AvatarModel> inventory;
  
  ShopLoaded({required this.shopItems, required this.inventory});
}
class BuyItemSuccess extends ShopState {
  final String message;
  BuyItemSuccess(this.message);
}
class BuyItemError extends ShopState {
  final String message;
  BuyItemError(this.message);
}