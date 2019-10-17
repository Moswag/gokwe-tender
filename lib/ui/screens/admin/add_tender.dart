import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/constants/routes_constants.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/models/tender.dart';
import 'package:flutter_my_chat/repo/admin_repo.dart';
import 'package:flutter_my_chat/ui/widgets/loading.dart';
import 'package:flutter_my_chat/util/alert_dialog.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import '../sign_in.dart';

class AddTender extends StatefulWidget {
  @override
  State createState() => _AddTenderState();
}

class _AddTenderState extends State<AddTender> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  File _image;
  String category;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isTapped = false;

  TextEditingController dateController = new TextEditingController();

  String phonenumber;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        isTapped = true;
      });
  }

  Future<Null> _selectTIme(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        isTapped = true;
      });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  Future _addTender({Tender tender}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child(
                PropaneConstants.PATH_POSTS + '${Path.basename(_image.path)}}');
        StorageUploadTask uploadTask = storageReference.putFile(_image);
        //String up=uploadTask.
        await uploadTask.onComplete;
        print('File Uploaded');
        storageReference.getDownloadURL().then((fileURL) {
          setState(() {
            tender.imageUrl = fileURL;
            var id = utf8
                .encode(tender.title + tender.description); // data being hashed
            tender.id = sha1.convert(id).toString();

            AdminRepo.addTender(tender).then((onValue) {
              if (onValue) {
                AlertDiag.showAlertDialog(context, 'Status',
                    'Tender Successfully Added', RouteConstants.VIEW_TENDERS);
              } else {
                AlertDiag.showAlertDialog(
                    context,
                    'Status',
                    'Failed to add tender, please contact admin',
                    RouteConstants.VIEW_TENDERS);
              }
            });
          });
        });
      } catch (e) {
        print("Sign Up Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
                title: "Adding company failed",
                message: exception,
                duration: Duration(seconds: 5))
            .show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StateModel appState;
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      final email = appState?.firebaseUserAuth?.email ?? '';
      final name = appState?.user?.name ?? '';
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      //define form fields
      final backButton = IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          moveToLastScreen();
        },
      );
      final header = Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(PropaneConstants.APP_LOGO),
              fit: BoxFit.contain),
          color: Colors.white,
        ),
      );

      final nameField = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: titleController,
        //validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.title,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Title',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final dateField = TextField(
        onTap: () {
          _selectDate(context);
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.date_range,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: (this.isTapped)
              ? this.selectedDate.toString().substring(0, 10)
              : "Pick Due Date",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final timeField = TextField(
        onTap: () {
          _selectTIme(context);
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.access_time,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: (this.isTapped)
              ? this
                  .selectedTime
                  .toString()
                  .substring(10, selectedTime.toString().length - 1)
              : "Pick Due Time",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final descriptionField = TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        controller: descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.description,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Description',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final categoryField = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection(DBConstants.DB_CATEGORY)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CupertinoActivityIndicator(),
              );

            return Container(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                        child: Text(
                          "Category",
                        ),
                      )),
                  new Expanded(
                    flex: 4,
                    child: DropdownButton(
                      value: category,
                      isDense: true,
                      onChanged: (valueSelectedByUser) {
                        _onShopDropItemSelected(valueSelectedByUser);
                      },
                      hint: Text('Choose category'),
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data['category'],
                            child: Text(document.data['category']));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          });

      final docField = Column(
        children: <Widget>[
          Text('Selected Image'),
          _image != null
              ? Image.asset(
                  _image.path,
                  height: 150,
                )
              : Container(height: 0),
          _image == null
              ? RaisedButton(
                  child: Text('Choose Image'),
                  onPressed: chooseFile,
                  color: Colors.cyan,
                )
              : Container(),
        ],
      );
      final submitButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.blue,
            textColor: Theme.of(context).primaryColorLight,
            child: Text(
              'Save',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Save clicked");

                Tender tender = new Tender();
                tender.title = titleController.text;
                tender.description = descriptionController.text;
                tender.category = category;
                tender.dueDate = this.selectedDate.toString().substring(0, 10);
                tender.dueTime = this
                    .selectedTime
                    .toString()
                    .substring(10, selectedTime.toString().length - 1);
                tender.status = category;
                tender.date = DateTime.now().toString();
                _addTender(tender: tender);
              });
            }),
      );

      final cancelButton = Expanded(
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.red,
            textColor: Theme.of(context).primaryColorLight,
            child: Text(
              'Cancel',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Cancel button clicked");
                Navigator.pop(context);
              });
            }),
      );

      Form form = new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    header,
                    SizedBox(height: 48.0),
                    nameField,
                    SizedBox(height: 24.0),
                    descriptionField,
                    SizedBox(height: 24.0),
                    categoryField,
                    SizedBox(height: 24.0),
                    dateField,
                    SizedBox(height: 24.0),
                    timeField,
                    SizedBox(height: 24.0),
                    docField,
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          submitButton,
                          Container(
                            width: 5.0,
                          ), //for adding space between buttons
                          cancelButton
                        ],
                      ),
                    ),
                  ],
                ),
              )));

      return WillPopScope(
          onWillPop: () {
            moveToLastScreen();
          },
          child: Scaffold(
            appBar: new AppBar(
              elevation: 0.1,
              backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
              title: Text('Add Tender'),
            ),
            body: LoadingScreen(child: form, inAsyncCall: _loadingVisible),
          ));
    }
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  void _onShopDropItemSelected(String newValueSelected) {
    setState(() {
      this.category = newValueSelected;
    });
  }
}
