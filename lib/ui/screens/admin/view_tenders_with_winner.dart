import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/models/tender.dart';

import 'add_winner.dart';
import 'admin_drawer.dart';

class ViewTendersClosed extends StatefulWidget {
  ViewTendersClosed({this.user});

  final FirebaseUser user;

  @override
  State createState() => _ViewTendersClosedState();
}

class _ViewTendersClosedState extends State<ViewTendersClosed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AdminDrawer(),
        appBar: new AppBar(
          title: new Text('Closed Tenders'),
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 160),
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection(DBConstants.DB_TENDER)
                    .where('status', isEqualTo: "Pending")
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
            Tender tender = new Tender();
            tender.title = document[positon].data['title'].toString();
            tender.description =
                document[positon].data['description'].toString();
            tender.dueDate = document[positon].data['dueDate'].toString();
            tender.dueTime = document[positon].data['dueTime'].toString();
            tender.status = document[positon].data['status'].toString();
            tender.date = document[positon].data['date'].toString();
            tender.category = document[positon].data['category'].toString();
            tender.winner = document[positon].data['winner'].toString();
            tender.id = document[positon].data['id'].toString();

            if (DateTime.now().isAfter(DateTime.parse(
                tender.dueDate + ' ' + tender.dueTime + ':00'))) {
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Container(
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person)),
                      title: Text("Tender: " + tender.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Description: " +
                              tender.description +
                              '\nDue Date: ' +
                              tender.dueDate,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      trailing: GestureDetector(
                        //to make the icon clickable and respond
                        child: Icon(Icons.thumb_up,
                            color: Colors.white, size: 25.0),
                        onTap: () {
//                      Firestore.instance.runTransaction((transaction) async {
//                        DocumentSnapshot snapshot =
//                            await transaction.get(document[positon].reference);
//                        await transaction.delete(snapshot.reference);
//                      });
                        },
                      ),
                      onTap: () {
                        debugPrint("ListTile Tapped");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => new AddWinner(
                                  tender: tender,
                                )));
                      },
                    ),
                  ));
            }
            //return null;
          });
    }

    return getNoteListView();
  }
}
