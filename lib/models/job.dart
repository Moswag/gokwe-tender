import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Job userFromJson(String str) {
  final jsonData = json.decode(str);
  return Job.fromJson(jsonData);
}

String userToJson(Job data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Job {
  String id;
  String companyId;
  String companyName;
  String tenderId;
  String tenderTitle;
  double amount;
  String workStatus;
  String paymentStatus;
  String date;

  Job(
      {this.id,
      this.companyId,
      this.companyName,
      this.tenderId,
      this.tenderTitle,
      this.amount,
      this.workStatus,
      this.paymentStatus,
      this.date});

  factory Job.fromJson(Map<String, dynamic> json) => new Job(
        id: json["id"],
        companyId: json["companyId"],
        companyName: json["companyName"],
        tenderId: json["tenderId"],
        tenderTitle: json["tenderTitle"],
        amount: json["amount"],
        workStatus: json["workStatus"],
        paymentStatus: json["paymentStatus"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "companyName": companyName,
        "tenderId": tenderId,
        "tenderTitle": tenderTitle,
        "amount": amount,
        "workStatus": workStatus,
        "paymentStatus": paymentStatus,
        "date": date
      };

  factory Job.fromDocument(DocumentSnapshot doc) {
    return Job.fromJson(doc.data);
  }
}
