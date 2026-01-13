class AvatarModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String status; // 'owned', 'available', 'locked', etc
  final bool isActive;
  final DateTime createdAt;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.status,
    required this.isActive,
    required this.createdAt,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? json['photo'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String? ?? json['rarity'] as String? ?? 'available',
      isActive: json['is_active'] as bool? ?? json['active'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'status': status,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
