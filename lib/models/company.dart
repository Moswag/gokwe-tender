import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Company userFromJson(String str) {
  final jsonData = json.decode(str);
  return Company.fromJson(jsonData);
}

String userToJson(Company data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Company {
  String id;
  String name;
  String mission;
  String logoUrl;
  String profile;
  String date;
  String category;
  String companyUniqueId;

  Company(
      {this.id,
      this.name,
      this.mission,
      this.logoUrl,
      this.profile,
      this.date,
      this.category,
      this.companyUniqueId});

  factory Company.fromJson(Map<String, dynamic> json) => new Company(
        id: json["id"],
        name: json["name"],
        mission: json["mission"],
        logoUrl: json["logoUrl"],
        profile: json["profile"],
        date: json["date"],
        category: json["category"],
        companyUniqueId: json["companyUniqueId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mission": mission,
        "logoUrl": logoUrl,
        "profile": profile,
        "date": date,
        "category": category,
        "companyUniqueId": companyUniqueId
      };

  factory Company.fromDocument(DocumentSnapshot doc) {
    return Company.fromJson(doc.data);
  }
}
