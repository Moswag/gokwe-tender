import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/constants/routes_constants.dart';
import 'package:flutter_my_chat/models/job.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/models/tender.dart';
import 'package:flutter_my_chat/repo/admin_repo.dart';
import 'package:flutter_my_chat/ui/widgets/loading.dart';
import 'package:flutter_my_chat/util/alert_dialog.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';

import '../sign_in.dart';

class AddWinner extends StatefulWidget {
  Tender tender;
  AddWinner({this.tender});

  @override
  State createState() => _AddWinnerState();
}

class _AddWinnerState extends State<AddWinner> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  File _image;
  String company;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  Future _addJob({Job job}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        String company = job.companyName;
        job.id = company.split("/")[0].toString();
        job.companyId = company.split("/")[0].toString();
        job.companyName = company.split("/")[1].toString();

        AdminRepo.addJob(job).then((onValue) {
          if (onValue) {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Job to ${job.companyName} Successfully created',
                RouteConstants.VIEW_CLOSED_TENDERS);
          } else {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Failed to add job, please contact admin',
                RouteConstants.VIEW_CLOSED_TENDERS);
          }
        });
      } catch (e) {
        print("Sign Up Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
                title: "Adding job  failed",
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
        enabled: false,
        //validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.title,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: widget.tender.title,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final companyField = StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection(DBConstants.DB_COMPANY)
              .where('category', isEqualTo: widget.tender.category)
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
                          "Company",
                        ),
                      )),
                  new Expanded(
                    flex: 4,
                    child: DropdownButton(
                      value: company,
                      isDense: true,
                      onChanged: (valueSelectedByUser) {
                        _onShopDropItemSelected(valueSelectedByUser);
                      },
                      hint: Text('Choose company'),
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data['id'] +
                                '/' +
                                document.data['name'],
                            child: Text(document.data['name']));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          });

      final amountField = TextFormField(
        autofocus: false,
        keyboardType: TextInputType.numberWithOptions(),
        controller: amountController,
        // validator: Validator.validateNumber,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.monetization_on,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Amount',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
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
                String tenderId;
                String tenderTitle;
                double amount;
                String workStatus;
                String paymentStatus;
                String date;

                Job job = new Job();
                job.companyName = company;
                job.tenderTitle = widget.tender.title;
                job.tenderId = widget.tender.id;
                job.amount = double.parse(amountController.text);
                job.workStatus = 'Pending';
                job.paymentStatus = 'Pending';
                job.date = DateTime.now().toString();

                _addJob(job: job);
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
                    companyField,
                    SizedBox(height: 24.0),
                    amountField,
                    SizedBox(height: 24.0),
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
              title: Text('Add Winner'),
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

  void _onShopDropItemSelected(String newValueSelected) {
    setState(() {
      this.company = newValueSelected;
    });
  }
}
