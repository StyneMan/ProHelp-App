class SearchModel {
  String id;
  String key;
  String createdAt;

  SearchModel({ required this.id, required this.key, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': key,
      'created_at': createdAt,
    };
  }
}
