import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_my_chat/constants/const.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';

import '../sign_in.dart';
import 'add_category.dart';
import 'admin_drawer.dart';

class ViewCategories extends StatefulWidget {
  ViewCategories({this.user, this.auth});

  final FirebaseUser user;

  final Auth auth;

  StateModel appState;

  @override
  State createState() => __ViewCategoriesStateState();
}

class __ViewCategoriesStateState extends State<ViewCategories> {
  @override
  Widget build(BuildContext context) {
    widget.appState = StateWidget.of(context).state;
    if (!widget.appState.isLoading &&
        (widget.appState.firebaseUserAuth == null ||
            widget.appState.user == null ||
            widget.appState.settings == null)) {
      return SignInScreen();
    } else {
      final email = widget.appState?.firebaseUserAuth?.email ?? '';
      final name = widget.appState?.user?.name ?? '';
      final companyId = widget.appState?.user?.companyId ?? '';

      return Scaffold(
          drawer: AdminDrawer(),
          appBar: new AppBar(
            title: new Text('Categories'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddCategory()));
            },
            child: Icon(Icons.add),
            backgroundColor: meroonColor,
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 160),
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection(DBConstants.DB_CATEGORY)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Container(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    return new TaskList(document: snapshot.data.documents);
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
      return ListView.builder(
          itemCount: document.length,
          itemBuilder: (BuildContext context, int positon) {
            String category = document[positon].data['category'].toString();
            String date = document[positon].data['date'].toString();

            return Card(
                color: Colors.white,
                elevation: 2.0,
                child: Container(
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.category)),
                    title: Text("Category: " + category,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Date: ' + date,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: GestureDetector(
                      //to make the icon clickable and respond
                      child:
                          Icon(Icons.delete, color: Colors.white, size: 25.0),
                      onTap: () {
                        Firestore.instance.runTransaction((transaction) async {
                          DocumentSnapshot snapshot = await transaction
                              .get(document[positon].reference);
                          await transaction.delete(snapshot.reference);
                        });

                        Scaffold.of(context).showSnackBar(new SnackBar(
                            content: new Text('Category Deleted')));
                      },
                    ),
                    onTap: () {
                      debugPrint("ListTile Tapped");
//                    Navigator.of(context).push(MaterialPageRoute(
//                        builder: (BuildContext context)=>new EditController(
//                          name:  name,
//                          email: email,
//                          nationalId: nationalId ,
//                          phonenumber: phonenumber,
//                          index: document[positon].reference,
//                        )));
                    },
                  ),
                ));
          });
    }

    return getNoteListView();
  }
}
