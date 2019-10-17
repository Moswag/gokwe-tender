import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Category userFromJson(String str) {
  final jsonData = json.decode(str);
  return Category.fromJson(jsonData);
}

String userToJson(Category data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Category {
  String id;
  String category;
  String date;

  Category({this.id, this.category, this.date});

  factory Category.fromJson(Map<String, dynamic> json) => new Category(
        id: json["id"],
        category: json["category"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() =>
      {"id": id, "category": category, "date": date};

  factory Category.fromDocument(DocumentSnapshot doc) {
    return Category.fromJson(doc.data);
  }
}
