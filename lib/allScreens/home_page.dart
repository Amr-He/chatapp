
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/home_provider.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/allScreens/settings_page.dart';
import 'package:ichat_app/allWidgets/widgets.dart';
import 'package:ichat_app/allmodles/popupchoise.dart';
import 'package:ichat_app/allmodles/user_chat.dart';
import 'package:ichat_app/utilites/Utilites.dart';
import 'package:ichat_app/utilites/debouncer.dart';
import 'package:provider/src/provider.dart';
import '../main.dart';
import 'chat_page.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final GoogleSignIn googleSignIn= GoogleSignIn();
  final ScrollController listscrollController=ScrollController();

  int _limit =20;
  int _limitIncrement =20;
  String _textSearch ="";
  bool isLoading =false;


  late  String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  Debouncer searchDeboucer=Debouncer(milliseconds: 300);
  StreamController<bool>btnClearController=StreamController<bool>();
  TextEditingController SearchBarTec =TextEditingController();

  List<PopupChoices> choices =<PopupChoices>[
    PopupChoices(title: 'Settings',icon: Icons.settings),
    PopupChoices(title: 'Sign out',icon: Icons.exit_to_app),
  ];

  Future<void>handleSignout() async{
    authProvider.handleSingOut();
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>LogginPage()));
  }

  void scrollistener(){
    if(listscrollController.offset >=listscrollController.position.maxScrollExtent && !listscrollController.position.outOfRange)
      setState(() {
        _limit +=_limitIncrement;
      });
  }

  void onItemMenuPress(PopupChoices choice){
    if(choice.title == "Sign out"){
      handleSignout();
    }else{
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>SettingsPage()));
    }
  }

  Future<bool>onBackPress(){
    openDialog();
    return Future.value(false);
  }

Future<void> openDialog() async{
switch (await showDialog(
  context: context,
  builder:(BuildContext context){
    return SimpleDialog(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          color: ColorConstants.themeColor,
          padding: EdgeInsets.only(bottom: 10,top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:<Widget> [
              Container(
                child: Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Text(
                'Exit app',
                style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
              ),
              Text(
                'Are you sure to exit app',
                style: TextStyle(color: Colors.white70, fontSize: 14,),
              ),
            ],
          ),
        ),
        SimpleDialogOption(
          onPressed: (){
            Navigator.pop(context,0);
          },
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.cancel,
                  color: Colors.black,
                ),
                margin: EdgeInsets.only(right: 10),
              ),
              Text(
                'Cancel',
                style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SimpleDialogOption(
          onPressed: (){
            Navigator.pop(context,1);
          },
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.check_circle,
                  color:Colors.black,
                ),
                margin: EdgeInsets.only(right: 10),
              ),
              Text(
                'Yes',
                style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
)){
  case 0:
    break;
  case 1:
    exit(0);
}
}

  buildPopupMenu(){
    return PopupMenuButton<PopupChoices>(
      icon: Icon(Icons.more_vert, color: Colors.white,),
        onSelected: onItemMenuPress,
        itemBuilder:(BuildContext Context){
          return choices.map((PopupChoices choice){
            return PopupMenuItem<PopupChoices>(
              value:choice ,
                child: Row(
                  children: <Widget>[
                    Icon(
                        choice.icon,
                      color: ColorConstants.greyColor,
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                        choice.title,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            );
          }).toList();
        }
    );
  }

  void dispose(){
    super.dispose();
    btnClearController.close();
  }

   @override
  void initState() {
    super.initState();
    authProvider =context.read<AuthProvider>();
    homeProvider =context.read<HomeProvider>();

    if(authProvider.getuserFirebaseId()?.isNotEmpty == true){
      currentUserId= authProvider.getuserFirebaseId()!;
    }else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> LogginPage()),
              (Route<dynamic>route) => false,);
    }
    listscrollController.addListener(scrollistener);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffb7dcea),Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          brightness: Brightness.dark,
          //remove bcakgroundcolor from appbar
          backgroundColor: Colors.transparent,
          //remove shadwo frome app bar
          elevation: 0 ,
          toolbarHeight: 65,

          flexibleSpace:Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight:Radius.circular(30) ),
              gradient: LinearGradient(
                colors: [Color(0xff80b1fe),Color( 0xff3d50e7)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          title: Text('Recent Chats'),
          actions: <Widget>[
            buildPopupMenu(
            ),
          ],
        ),
        body: WillPopScope(
            onWillPop: onBackPress,
            child: Stack(
              children:<Widget> [
                Column(
                  children: [
                    SizedBox(height: 20,),
                    buildSearchBar(),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: homeProvider.getStreamFireStore(FirestoreConstants.pathUserCollection, _limit, _textSearch),
                          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                            if(snapshot.hasData){
                              if((snapshot.data?.docs.length ?? 0) > 0){
                                return ListView.builder(
                                  padding: EdgeInsets.all(10),
                                    itemBuilder: (context,index)=> buildItem(context,snapshot.data?.docs[index]),
                                  itemCount:snapshot.data?.docs.length,
                                  controller: listscrollController,
                                );
                              }else{
                                return Center(
                                  child:  Text('No User Found...',style: TextStyle(color: Colors.grey),),
                                );
                              }
                            }else{
                              return Center(
                                child:  CircularProgressIndicator(
                                  color: Colors.grey,
                                ),
                              );
                            }
                          },
                        ),
                    ),
                  ],
                ),
                Positioned(
                    child:isLoading ? LoadingView() :SizedBox.shrink()
                ),
              ],
            ),
          ),

      ),
    );
  }
  Widget buildSearchBar(){
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search,color: ColorConstants.greyColor,size: 20,),
          SizedBox(width: 5,),
          Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.search,
                controller: SearchBarTec,
                onChanged: (value){
                  if(value.isNotEmpty){
                    btnClearController.add(true);
                    setState(() {
                      _textSearch =value;
                    });
                  }else{
                    btnClearController.add(false);
                    setState(() {
                      _textSearch="";
                    });
                  }
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Search Here....',
                  hintStyle: TextStyle(fontSize: 13,color: ColorConstants.greyColor),
                ),
                style: TextStyle(fontSize: 13,),
              ),
          ),
          StreamBuilder(
            stream: btnClearController.stream,
              builder:(context, snapshot){
              return snapshot.data==true
                  ?GestureDetector(
               onTap: (){
                 SearchBarTec.clear();
                 btnClearController.add(false);
                 setState(() {
                   _textSearch="";
                 });
               },
                child: Icon(Icons.clear_rounded,color: ColorConstants.greyColor,size: 20,),
              )
                  : SizedBox.shrink();
              }
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          margin:EdgeInsets.fromLTRB(16, 8, 16, 8),

    );
  }

  Widget buildItem(BuildContext context,DocumentSnapshot? doucment){
    if(doucment !=null){
      UserChat userChat=UserChat.fromDocument(doucment);
      if(userChat.id ==currentUserId){
        return SizedBox.shrink();
      }else{
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photourl.isNotEmpty
                      ? Image.network(
                    userChat.photourl,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                      if(loadingProgress ==null )return child;
                      return  Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                        color: Colors.grey,
                          value:loadingProgress.expectedTotalBytes !=null
                              && loadingProgress.expectedTotalBytes !=null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              :null,
                        ),
                      );
                    },
                      errorBuilder: (context, object ,stackTrace){
                      return Icon(
                        Icons.account_circle,
                        size: 50,
                        color: ColorConstants.greyColor,
                      );
                      },
                  )
                      :Icon(
                    Icons.account_circle,
                    size: 50,
                    color: ColorConstants.greyColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                    child: Container(
                      child: Column(
                        children:<Widget> [
                          Container(
                            child: Text(
                              '${userChat.nickname}',
                              maxLines: 1,
                              style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.bold,fontSize: 18),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          ),
                          Container(
                            child: Text(
                              '${userChat.aboutme}',
                              maxLines: 1,
                              style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.bold,fontSize: 18),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 2),
                    ),
                )
              ],
            ),
            onPressed: (){
              if(Utilites.isKeyboardShowing()){
                Utilites.CloseKeyboard(context);
              }
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(
                peerId:userChat.id,
                peerAvatar:userChat.photourl,
                peerNickname: userChat.nickname,
                )
               )
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withOpacity(0.2)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10,left: 5,right: 5),
        );
      }
    }else{
      return SizedBox.shrink();
    }
  }
}
