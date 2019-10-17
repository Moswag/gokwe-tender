import 'package:flutter/material.dart';
import 'package:flutter_my_chat/root_page.dart';
import 'package:flutter_my_chat/ui/screens/admin/view_admins.dart';
import 'package:flutter_my_chat/ui/screens/admin/view_categories.dart';
import 'package:flutter_my_chat/ui/screens/admin/view_companies.dart';
import 'package:flutter_my_chat/ui/screens/admin/view_tenders.dart';
import 'package:flutter_my_chat/ui/screens/company/view_tenders.dart';
import 'package:flutter_my_chat/ui/screens/forgot_password.dart';
import 'package:flutter_my_chat/ui/screens/sign_in.dart';
import 'package:flutter_my_chat/ui/screens/sign_up.dart';
import 'package:flutter_my_chat/ui/theme.dart';
import 'package:flutter_my_chat/util/auth.dart';

import 'constants/routes_constants.dart';
import 'util/state_widget.dart';

void main() {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );

  runApp(stateWidget);
}

class MyApp extends StatelessWidget {
  MyApp() {
    //Navigation.initPaths();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-TENDERING SYSTEM',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,
      home: RootPage(
        auth: Auth(),
      ),
      routes: <String, WidgetBuilder>{
        //controller

        //guest
        RouteConstants.SIGNIN: (context) => SignInScreen(),
        RouteConstants.SIGNUP: (context) => SignUpScreen(),
        RouteConstants.FORGOT_PASSWORD: (context) => ForgotPasswordScreen(),

        //admin
        RouteConstants.VIEW_ADMINS: (context) => ViewAdmins(),
        RouteConstants.VIEW_COMPANIES: (context) => ViewCompanies(),
        RouteConstants.VIEW_CATEGORIES: (context) => ViewCategories(),
        RouteConstants.VIEW_TENDERS: (context) => ViewTenders(),

        //company
        RouteConstants.COMPANY_VIEW_TENDERS: (context) => CompanyViewTenders(),
      },
    );
  }
}
