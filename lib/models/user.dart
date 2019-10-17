import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String userId;
  String name;
  String nationalId;
  String phonenumber;
  String email;
  String role;
  bool isCompany;
  String companyId;

  User(
      {this.userId,
      this.name,
      this.nationalId,
      this.phonenumber,
      this.email,
      this.role,
      this.isCompany,
      this.companyId});

  factory User.fromJson(Map<String, dynamic> json) => new User(
      userId: json["userId"],
      name: json["name"],
      nationalId: json["nationalId"],
      phonenumber: json["phonenumber"],
      email: json["email"],
      role: json["role"],
      isCompany: json["isCompany"],
      companyId: json["companyId"]);

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "nationalId": nationalId,
        "phonenumber": phonenumber,
        "email": email,
        "role": role,
        "isCompany": isCompany,
        "companyId": companyId
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
