import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

ScoreCard userFromJson(String str) {
  final jsonData = json.decode(str);
  return ScoreCard.fromJson(jsonData);
}

String userToJson(ScoreCard data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ScoreCard {
  String companyId;
  int scrore;
  String date;

  ScoreCard({
    this.companyId,
    this.scrore,
    this.date,
  });

  factory ScoreCard.fromJson(Map<String, dynamic> json) => new ScoreCard(
      companyId: json["companyId"], scrore: json["scrore"], date: json["date"]);

  Map<String, dynamic> toJson() =>
      {"companyId": companyId, "scrore": scrore, "date": date};

  factory ScoreCard.fromDocument(DocumentSnapshot doc) {
    return ScoreCard.fromJson(doc.data);
  }
}
