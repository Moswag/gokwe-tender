import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/constants/routes_constants.dart';
import 'package:flutter_my_chat/models/job.dart';
import 'package:flutter_my_chat/models/state.dart';
import 'package:flutter_my_chat/repo/admin_repo.dart';
import 'package:flutter_my_chat/ui/widgets/loading.dart';
import 'package:flutter_my_chat/util/alert_dialog.dart';
import 'package:flutter_my_chat/util/auth.dart';
import 'package:flutter_my_chat/util/state_widget.dart';

import '../sign_in.dart';

class ApproveJob extends StatefulWidget {
  Job job;
  ApproveJob({this.job});

  @override
  State createState() => ApproveJobState();
}

class ApproveJobState extends State<ApproveJob> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
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
          hintText: "TItle: " + widget.job.tenderTitle,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );
      final winnerField = TextFormField(
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
          hintText: "Winner: " + widget.job.companyName,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final amountField = TextFormField(
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
          hintText: "Amount: " + widget.job.amount.toString(),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final statusField = TextFormField(
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
          hintText: "Status: " + widget.job.workStatus,
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
//                String status
//
//
//
//                _addJob(job: job);
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
                    winnerField,
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
              title: Text('Approve Job'),
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
