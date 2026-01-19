import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class AdminAvatarEvent {}
class LoadAvatarsEvent extends AdminAvatarEvent {}
class AddAvatarEvent extends AdminAvatarEvent {
  final String name, url, rarity;
  final double price;
  final XFile? file;
  AddAvatarEvent(this.name, this.url, this.price, this.rarity, {this.file});
}
class EditAvatarEvent extends AdminAvatarEvent {
  final int id;
  final String name, url, rarity;
  final double price;
  EditAvatarEvent(this.id, this.name, this.url, this.price, this.rarity);
}
class ToggleAvatarEvent extends AdminAvatarEvent {
  final int id;
  ToggleAvatarEvent(this.id);
}
class FilterAvatarsEvent extends AdminAvatarEvent {
  final String rarity;
  final String sortBy;
  FilterAvatarsEvent(this.rarity, this.sortBy);
}
