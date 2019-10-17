import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Bid userFromJson(String str) {
  final jsonData = json.decode(str);
  return Bid.fromJson(jsonData);
}

String userToJson(Bid data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Bid {
  String id;
  String companyId;
  String companyName;
  double bid;
  String date;

  Bid({this.id, this.companyId, this.companyName, this.bid, String date});

  factory Bid.fromJson(Map<String, dynamic> json) => new Bid(
        id: json["id"],
        companyId: json["companyId"],
        companyName: json["companyName"],
        bid: json["bid"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "companyName": companyName,
        "bid": bid,
        "date": date
      };

  factory Bid.fromDocument(DocumentSnapshot doc) {
    return Bid.fromJson(doc.data);
  }
}
