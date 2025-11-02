class FriendModel {
  final int id;
  final String name;

  FriendModel({required this.id, required this.name});

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      id: map['id'],
      name: map['name'],
    );
  }
}