import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/constants.dart';

class UserChat{
  late String id;
  late String photourl;
  late String nickname;
  late String aboutme;
  late String phonenumber;

  UserChat({
    required this.id,
    required this.photourl,
    required this.nickname,
    required this.aboutme,
    required this.phonenumber,
});
  Map<String ,String> toJson(){
    return{
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutme,
      FirestoreConstants.photoUrl: photourl,
      FirestoreConstants.phoneNumber: phonenumber,
    };
  }
  factory UserChat.fromDocument(DocumentSnapshot doc){
    String aboutme="";
    String photourl="";
    String nickname="";
    String phonenumber="";
    try{
      aboutme =doc.get(FirestoreConstants.aboutMe);

    }catch(e){}
    try{
      photourl =doc.get(FirestoreConstants.photoUrl);

    }catch(e){}
    try{
      nickname =doc.get(FirestoreConstants.nickname);

    }catch(e){}
    try{
      phonenumber =doc.get(FirestoreConstants.phoneNumber);

    }catch(e){}
    return UserChat(
      id: doc.id,
      photourl: photourl,
      nickname: nickname,
      aboutme: aboutme,
      phonenumber: phonenumber,
    );

  }
}