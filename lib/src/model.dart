import 'dart:convert';

class Store {
  final int id;
  final dynamic data;
  int isDeleted;

  Store(this.id, this.data, {this.isDeleted = 0});

  Map toMap() {
    return {
      'id': id,
      'isDeleted': isDeleted,
      'data': data,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Store(
      map['id'],
      Map.from(map['data']),
      isDeleted: map['isDeleted'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Store.fromJson(String source) => Store.fromMap(json.decode(source));

  @override
  String toString() {
    return toJson();
  }
}
