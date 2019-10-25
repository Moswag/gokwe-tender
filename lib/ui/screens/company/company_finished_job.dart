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
import 'package:flutter_my_chat/repo/company_repo.dart';
import 'package:flutter_my_chat/ui/widgets/loading.dart';
import 'package:flutter_my_chat/util/alert_dialog.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';
import 'package:flutter_my_chat/util/validator.dart';

import '../sign_in.dart';

class FinishJob extends StatefulWidget {
  Job job;
  FinishJob({this.job});

  @override
  State createState() => _FinishJobrState();
}

class _FinishJobrState extends State<FinishJob> {
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



        CompanyRepo.finishJob(job).then((onValue) {
          if (onValue) {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Job  ${job.tenderTitle} Successfully reported finished',
                RouteConstants.COMPANY_WON_TENDERS);
          } else {
            AlertDiag.showAlertDialog(
                context,
                'Status',
                'Failed to update job, please contact admin',
                RouteConstants.COMPANY_WON_TENDERS);
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
          hintText: widget.job.tenderTitle,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );


      final amountField = TextFormField(
        autofocus: false,
        enabled: false,
        keyboardType: TextInputType.numberWithOptions(),
        controller: amountController,
        validator: Validator.validateNumber,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.monetization_on,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: widget.job.amount.toString(),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final statusField = TextFormField(
        autofocus: false,
        enabled: false,
        keyboardType: TextInputType.numberWithOptions(),
        controller: amountController,
        validator: Validator.validateNumber,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.transfer_within_a_station,
              color: Colors.black,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: "Awaiting your finishing response",
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
              'Confirm Finished',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              setState(() {
                debugPrint("Save clicked");

                Job job=new Job();
                job.id=widget.job.id;
                job.workStatus="Company Finished";

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
                    amountField,
                    SizedBox(height: 24.0),
                    statusField,
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
