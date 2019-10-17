import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Tender userFromJson(String str) {
  final jsonData = json.decode(str);
  return Tender.fromJson(jsonData);
}

String userToJson(Tender data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Tender {
  String id;
  String title;
  String description;
  String imageUrl;
  String dueDate;
  String dueTime;
  String status;
  String date;
  String category;
  String winner;

  Tender(
      {this.id,
      this.title,
      this.description,
      this.imageUrl,
      this.dueDate,
      this.dueTime,
      this.status,
      this.date,
      this.category,
      this.winner});

  factory Tender.fromJson(Map<String, dynamic> json) => new Tender(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        dueDate: json["dueDate"],
        dueTime: json["dueTime"],
        status: json["status"],
        date: json["date"],
        category: json["category"],
        winner: json["winner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "dueDate": dueDate,
        "dueTime": dueTime,
        "status": status,
        "date": date,
        "category": category,
        "winner": winner
      };

  factory Tender.fromDocument(DocumentSnapshot doc) {
    return Tender.fromJson(doc.data);
  }
}
