import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/models/job.dart';

class CompanyRepo{
  static Future<bool> finishJob(Job job) async {
    try {
      getJob(job.id).then((QuerySnapshot snapshot) {
        if (snapshot.documents.isNotEmpty) {
          updateJob(job, snapshot.documents[0].reference);
          return true;
        } else {
          return false;
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
  static getJob(String jobId) {
    return Firestore.instance
        .collection(DBConstants.DB_JOB)
        .where('id', isEqualTo: jobId)
        .limit(1)
        .getDocuments();
  }

  static Future<bool> updateJob(Job job, final index) async {
    try {
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentSnapshot snapshot = await transaction.get(index);
        await transaction.update(snapshot.reference,
            {"status": job.workStatus});
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}