import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Winner userFromJson(String str) {
  final jsonData = json.decode(str);
  return Winner.fromJson(jsonData);
}

String userToJson(Winner data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Winner {
  String companyId;
  String tenderId;
  String date;
  String status;

  Winner({
    this.companyId,
    this.tenderId,
    this.date,
    this.status,
  });

  factory Winner.fromJson(Map<String, dynamic> json) => new Winner(
        companyId: json["companyId"],
        tenderId: json["tenderId"],
        date: json["date"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "companyId": companyId,
        "tenderId": tenderId,
        "date": date,
        "status": status,
      };

  factory Winner.fromDocument(DocumentSnapshot doc) {
    return Winner.fromJson(doc.data);
  }
}
