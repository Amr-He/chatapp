import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allmodles/user_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status{
  uninitalized,
  authenticated,
  authenticating,
  authenticateErorr,
  authenticatecannceled,
}

class AuthProvider extends ChangeNotifier{
  late final GoogleSignIn googleSignIn;
  late final FirebaseAuth firebaseAuth;
  late final FirebaseFirestore firebaseFirestore;
  late final SharedPreferences Prefs;
  Status _status=Status.uninitalized;

  Status get status =>_status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.Prefs,
    required this.firebaseFirestore,
});

  String? getuserFirebaseId(){
    return Prefs.getString(FirestoreConstants.id);
  }
  Future<bool>isLoggedin() async{
    bool isLoggedin =await googleSignIn.isSignedIn();
    if(isLoggedin && Prefs.getString(FirestoreConstants.id)?.isNotEmpty ==true){
      return true;
    }
    else{
      return false;
    }
  }
  Future<bool>handleSingin() async{
    _status=Status.authenticating;
    notifyListeners();

    GoogleSignInAccount ? googleUser= await googleSignIn.signIn();
    if(googleUser != null){
      GoogleSignInAuthentication? googlAuth =await googleUser.authentication;
      final AuthCredential credential =GoogleAuthProvider.credential(
        accessToken: googlAuth.accessToken,
        idToken: googlAuth.idToken,
      );
      User?firebaseUser=(await firebaseAuth.signInWithCredential(credential)).user;

      if(firebaseUser !=null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if (document.length == 0) {
          firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid).set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createdAt': DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            FirestoreConstants.chattingWith: null,
          });
          User? currentUser = firebaseUser;
          await Prefs.setString(FirestoreConstants.id, currentUser.uid);
          await Prefs.setString(
              FirestoreConstants.nickname, currentUser.displayName ?? "");
          await Prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await Prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        }
        else {
          DocumentSnapshot documentSnapshot = document[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);

          await Prefs.setString(FirestoreConstants.id, userChat.id);
          await Prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await Prefs.setString(FirestoreConstants.photoUrl, userChat.photourl);
          await Prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phonenumber);
        }
        _status = Status.authenticated;
        notifyListeners();

        return true;
      }else{
        _status = Status.authenticateErorr;
        notifyListeners();
        return false;
      }
        }else{
      _status = Status.authenticatecannceled;
      notifyListeners();
      return false;
    }
      }
      Future<void>handleSingOut() async{
        _status=Status.uninitalized;
        await firebaseAuth.signOut();
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }
    }

