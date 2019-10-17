import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_my_chat/constants/db_constants.dart';
import 'package:flutter_my_chat/constants/myconstants.dart';
import 'package:flutter_my_chat/models/settings.dart';
import 'package:flutter_my_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

abstract class BaseAuth {
  Future<String> currentUser();
}

class Auth implements BaseAuth {
  static Future<String> signUp(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  static Future<bool> checkCompanyExist(String companyId) async {
    bool exists = false;
    try {
      await Firestore.instance
          .document("${DBConstants.DB_COMPANY}/$companyId")
          .get()
          .then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static getCompany(String companyId) {
    return Firestore.instance
        .collection(DBConstants.DB_COMPANY)
        .where('id', isEqualTo: companyId)
        .limit(1)
        .getDocuments();
  }

  static void addUserSettingsDB(User user) async {
    checkUserExist(user.userId).then((value) {
      if (!value) {
        getCompany(user.companyId).then((QuerySnapshot snapshot) {
          if (snapshot.documents.isNotEmpty) {
            var companyAccount = snapshot.documents[0].data;
            user.name = companyAccount['name'];
            print("user ${user.name} ${user.email} added");
            Firestore.instance
                .document("users/${user.userId}")
                .setData(user.toJson());
            _addSettings(new Settings(
              settingsId: user.userId,
            ));
            return true;
          } else {
            print('Company do not exists');
            return false;
          }
        });
        return true;
      } else {
        print("user ${user.name} ${user.email} exists");
        return false;
      }
    });
  }

  static void addEmployeeSettingsDB(User user) async {
    checkUserExist(user.userId).then((value) {
      if (!value) {
        if (user.companyId.contains(PropaneConstants.SHOP_WHOLESALE)) {
          user.role = PropaneConstants.SALES_PERSON_WHOLESALE;
          user.companyId = user.companyId
              .replaceAll(PropaneConstants.SHOP_WHOLESALE, ''.trim());
          int x = user.companyId.length - 1;
          int y = user.companyId.length;
          user.companyId = user.companyId
              .replaceRange(x, y, ''); //replace the space in between the end
        } else if (user.companyId.contains(PropaneConstants.SHOP_FRENCHISE)) {
          user.role = PropaneConstants.USER_ADMIN;
          user.companyId = user.companyId
              .replaceAll(PropaneConstants.SHOP_FRENCHISE, ''.trim());
          int x = user.companyId.length - 1;
          int y = user.companyId.length;
          user.companyId = user.companyId
              .replaceRange(x, y, ''); //replace the space in between the end
        } else if (user.companyId.contains(PropaneConstants.SHOP_CAGE)) {
          user.role = PropaneConstants.SALES_PERSON_AT_CAGE;
          user.companyId =
              user.companyId.replaceAll(PropaneConstants.SHOP_CAGE, ''.trim());
          int x = user.companyId.length - 1;
          int y = user.companyId.length;
          user.companyId = user.companyId
              .replaceRange(x, y, ''); //replace the space in between the end
        }

        print("user ${user.name} ${user.email} added");
        Firestore.instance
            .document("users/${user.userId}")
            .setData(user.toJson());
        _addSettings(new Settings(
          settingsId: user.userId,
        ));
      } else {
        print("user ${user.name} ${user.email} exists");
      }
    });
  }

  static void addFrenchiseSettingsDB(User user) async {
    checkUserExist(user.userId).then((value) {
      if (!value) {
        print("user ${user.name} ${user.email} added");
        Firestore.instance
            .document("users/${user.userId}")
            .setData(user.toJson());
        _addSettings(new Settings(
          settingsId: user.userId,
        ));
      } else {
        print("user ${user.name} ${user.email} exists");
      }
    });
  }

  static String GetShopType(String plant_name) {
    String shopType;
    Firestore.instance
        .collection('shops')
        .where('plant_name', isEqualTo: plant_name)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              shopType = doc["shop_type"];
              print('Code zvinhu hona ${doc["shop_type"]}');
            }));
    print('This is a $shopType');
    return shopType;
  }

  static Future<bool> checkUserExist(String userId) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$userId").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static void _addSettings(Settings settings) async {
    Firestore.instance
        .document("settings/${settings.settingsId}")
        .setData(settings.toJson());
  }

  static Future<String> signIn(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  static Future<User> getUserFirestore(String userId) async {
    if (userId != null) {
      return Firestore.instance
          .collection('users')
          .document(userId)
          .get()
          .then((documentSnapshot) => User.fromDocument(documentSnapshot));
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<Settings> getSettingsFirestore(String settingsId) async {
    if (settingsId != null) {
      return Firestore.instance
          .collection('settings')
          .document(settingsId)
          .get()
          .then((documentSnapshot) => Settings.fromDocument(documentSnapshot));
    } else {
      print('no firestore settings available');
      return null;
    }
  }

  static Future<String> storeUserLocal(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  static Future<String> storeSettingsLocal(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsToJson(settings);
    await prefs.setString('settings', storeSettings);
    return settings.settingsId;
  }

  static Future<FirebaseUser> getCurrentFirebaseUser() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  static Future<User> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      User user = userFromJson(prefs.getString('user'));
      //print('USER: $user');
      return user;
    } else {
      return null;
    }
  }

  static Future<Settings> getSettingsLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('settings') != null) {
      Settings settings = settingsFromJson(prefs.getString('settings'));
      //print('SETTINGS: $settings');
      return settings;
    } else {
      return null;
    }
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth.instance.signOut();
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this email address not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'This email address already has an account.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }

  /*static Stream<User> getUserFirestore(String userId) {
    print("...getUserFirestore...");
    if (userId != null) {
      //try firestore
      return Firestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return User.fromDocument(doc);
        }).first;
      });
    } else {
      print('firestore user not found');
      return null;
    }
  }*/

  /*static Stream<Settings> getSettingsFirestore(String settingsId) {
    print("...getSettingsFirestore...");
    if (settingsId != null) {
      //try firestore
      return Firestore.instance
          .collection("settings")
          .where("settingsId", isEqualTo: settingsId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Settings.fromDocument(doc);
        }).first;
      });
    } else {
      print('no firestore settings available');
      return null;
    }
  }*/
}
