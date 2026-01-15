
abstract class ShopEvent {}
class LoadShopData extends ShopEvent {}
class EquipItemEvent extends ShopEvent {
  final int avatarId;
  EquipItemEvent(this.avatarId);
}