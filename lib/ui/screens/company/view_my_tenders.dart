import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/models/job.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/util/state_widget.dart';

import '../sign_in.dart';
import 'company_drawer.dart';
import 'company_finished_job.dart';

class ViewMyTenders extends StatefulWidget {
  ViewMyTenders({this.user});

  final FirebaseUser user;

  @override
  State createState() => _ViewJobsState();
}

class _ViewJobsState extends State<ViewMyTenders> {
  StateModel appState;
  bool _loadingVisible = false;

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      final email = appState?.firebaseUserAuth?.email ?? '';
      final name = appState?.user?.name ?? '';
      final companyId = appState?.user?.companyId ?? '';
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      return Scaffold(
          drawer: CompanyDrawer(),
          appBar: new AppBar(
            title: new Text('My Tenders'),
            centerTitle: true,
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 160),
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection(DBConstants.DB_JOB)
                      .where('companyId', isEqualTo: companyId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Container(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    return new TaskList(
                      document: snapshot.data.documents,
                    );
                  },
                ),
              ),
              Container(
                height: 150.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(PropaneConstants.BACKGROUND_IMAGE),
                        fit: BoxFit.cover),
                    boxShadow: [
                      new BoxShadow(color: Colors.black, blurRadius: 8.0)
                    ],
                    color: Colors.black),
              ),
            ],
          ));
    }
  }
}

class TaskList extends StatelessWidget {
  TaskList({this.document});

  final List<DocumentSnapshot> document;

  @override
  Widget build(BuildContext context) {
    ListView getNoteListView() {
      TextStyle titleStyle = Theme.of(context).textTheme.subhead;
      return ListView.builder(
        itemCount: document.length,
        itemBuilder: (BuildContext context, int positon) {
          Job job = new Job();
          job.id = document[positon].data['id'].toString();
          job.companyId = document[positon].data['companyId'].toString();
          job.companyName = document[positon].data['companyName'].toString();
          job.tenderId = document[positon].data['tenderId'].toString();
          job.tenderTitle = document[positon].data['tenderTitle'].toString();
          job.amount =
              double.parse(document[positon].data['amount'].toString());
          job.workStatus = document[positon].data['workStatus'].toString();
          job.paymentStatus =
              document[positon].data['paymentStatus'].toString();
          job.date = document[positon].data['date'].toString();

          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                decoration:
                    BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.white, child: Icon(Icons.work)),
                  title: Text("Tender: " + job.tenderTitle,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Winner: " +
                          job.companyName +
                          '\nWork Status: ' +
                          job.workStatus +
                          '\nPayment Status: ' +
                          job.paymentStatus +
                          '\nDate: ' +
                          job.date,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  trailing: GestureDetector(
                    //to make the icon clickable and respond
                    child: Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 25.0),
                    onTap: () {
//                      Firestore.instance.runTransaction((transaction) async {
//                        DocumentSnapshot snapshot =
//                        await transaction.get(document[positon].reference);
//                        await transaction.delete(snapshot.reference);
//                      });
//
//                      Scaffold.of(context).showSnackBar(
//                          new SnackBar(content: new Text('Admin Deleted')));
                    },
                  ),
                  onTap: () {
                    debugPrint("ListTile Tapped");
                    if (job.workStatus == "Request Finished") {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => new FinishJob(
                            job: job,
                          )));
                    } else {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text('Awaiting response from winner ' +
                              job.companyName)));
                    }
                  },
                ),
              ));
        },
      );
    }

    return getNoteListView();
  }
}
