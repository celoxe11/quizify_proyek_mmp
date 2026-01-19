class AvatarModel {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final String rarity;
  final bool isActive;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rarity,
    required this.isActive,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] ?? '0',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      rarity: json['rarity'] ?? 'common',
      isActive: (json['is_equipped'] == true || json['is_equipped'] == 1) || 
                (json['is_active'] == true || json['is_active'] == 1),
    );
  }
}