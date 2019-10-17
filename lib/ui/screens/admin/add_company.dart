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
import 'package:flutter_my_chat/models/company.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/repo/admin_repo.dart';
import 'package:flutter_my_chat/ui/widgets/loading.dart';
import 'package:flutter_my_chat/util/alert_dialog.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import '../sign_in.dart';

class AddCompany extends StatefulWidget {
  @override
  State createState() => _AddPostState();
}

class _AddPostState extends State<AddCompany> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  File _image;
  String category;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController uniqueController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  Future _addCompany({Company company}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child(
                PropaneConstants.PATH_LOGO + '${Path.basename(_image.path)}}');
        StorageUploadTask uploadTask = storageReference.putFile(_image);
        //String up=uploadTask.
        await uploadTask.onComplete;
        print('File Uploaded');
        storageReference.getDownloadURL().then((fileURL) {
          setState(() {
            company.logoUrl = fileURL;
            var id = utf8.encode(company.companyUniqueId); // data being hashed
            company.id = sha1.convert(id).toString();

            AdminRepo.addCompany(company).then((onValue) {
              if (onValue) {
                AlertDiag.showAlertDialog(
                    context,
                    'Status',
                    'Company Successfully Added',
                    RouteConstants.VIEW_COMPANIES);
              } else {
                AlertDiag.showAlertDialog(
                    context,
                    'Status',
                    'Failed to add Company, please contact admin',
                    RouteConstants.VIEW_COMPANIES);
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
          hintText: 'Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final uniqueField = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: uniqueController,
        //validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.ac_unit,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'UniqueId',
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
          hintText: 'Mission',
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
          Text('Selected Logo'),
          _image != null
              ? Image.asset(
                  _image.path,
                  height: 150,
                )
              : Container(height: 0),
          _image == null
              ? RaisedButton(
                  child: Text('Choose Logo'),
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
                Company company = new Company();
                company.name = titleController.text;
                company.mission = descriptionController.text;
                company.category = category;
                company.companyUniqueId = uniqueController.text;
                company.date = DateTime.now().toString();
                _addCompany(company: company);
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
                    uniqueField,
                    SizedBox(height: 24.0),
                    categoryField,
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
              title: Text('Add Company'),
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
