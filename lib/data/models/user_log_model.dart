class UserLogModel {
  final int id;
  final String userId;
  final String userName; // Dari Include User
  final String actionType;
  final String? endpoint;
  final DateTime createdAt;

  UserLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.actionType,
    this.endpoint,
    required this.createdAt,
  });

  factory UserLogModel.fromJson(Map<String, dynamic> json) {
    return UserLogModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      // Ambil nama user dari relasi User (jika backend kirim nested object)
      userName: json['User'] != null ? json['User']['name'] : 'Unknown',
      actionType: json['action_type'] ?? '',
      endpoint: json['endpoint'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}