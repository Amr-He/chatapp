import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allProviders/setting_provider.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/allmodles/user_chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'home_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        brightness: Brightness.dark,
        //remove bcakgroundcolor from appbar
        backgroundColor: Colors.transparent,
        //remove shadwo frome app bar
        elevation: 0 ,
        toolbarHeight: 65,

        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder:(context)=>Homepage(),
          ),),
        ),
        title: Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
      ),
      body: SettingsPageState(),
    );
      }
}
class SettingsPageState extends StatefulWidget {
  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {

  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutme;

  String dialCodeDigts ="+00";
  final TextEditingController _controller=TextEditingController();

  String id='';
  String nickname='';
  String aboutMe='';
  String photourl='';
  String phoneNumber='';


  bool isLoading=false;
  File? avaterImageFile;
  late SettingProvider settingsProvider;

  final FocusNode focusNodeNickName =FocusNode();
  final FocusNode focusNodeAboutMe =FocusNode();

  @override
  void initState() {
    super.initState();
    settingsProvider =context.read<SettingProvider>();
    readLocal();
  }
  void readLocal(){
    setState(() {
      id =settingsProvider.getprefs(FirestoreConstants.id)??"";
      nickname =settingsProvider.getprefs(FirestoreConstants.nickname)??"";
      aboutMe =settingsProvider.getprefs(FirestoreConstants.aboutMe)??"";
      photourl =settingsProvider.getprefs(FirestoreConstants.photoUrl)??"";
      phoneNumber =settingsProvider.getprefs(FirestoreConstants.phoneNumber)??"";
    });
    controllerNickname= TextEditingController(text: nickname);
    controllerAboutme=  TextEditingController(text: aboutMe);
  }
  Future getImage() async{
    ImagePicker imagePicker=ImagePicker();
    PickedFile? pickdFile=await imagePicker.getImage(source: ImageSource.gallery).catchError((err){
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if(pickdFile !=null){
      image=File(pickdFile.path);
    }
    if(image !=null){
      setState(() {
        avaterImageFile= image;
        isLoading =true;
      });
     uploadFile();
    }
  }
  Future uploadFile() async{
    String fileName=id;
    UploadTask uploadTask=settingsProvider.uploadFile(avaterImageFile!, fileName);
    try{
      TaskSnapshot snapshot=await uploadTask;
      photourl =await snapshot.ref.getDownloadURL();

      UserChat updateInfo=UserChat(
        id: id,
        photourl: photourl,
        nickname: nickname,
        aboutme: aboutMe,
        phonenumber: phoneNumber,
      );
      settingsProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson()).then((data) async {
        await settingsProvider.setprefs(FirestoreConstants.photoUrl, photourl);
        setState(() {
          isLoading =false;
        });
      }).catchError((err){
        setState(() {
          isLoading =false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch(e){
      setState(() {
        isLoading =false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }
  void handeleUpdateData(){
    focusNodeNickName.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading =true;
      if(dialCodeDigts !="+00" && _controller.text !=""){
        phoneNumber =dialCodeDigts + _controller.text.toString();
      }
    });
    UserChat updateinfo =UserChat(
      id: id,
      photourl: photourl,
      nickname: nickname,
      aboutme: aboutMe,
      phonenumber: phoneNumber,
    );
    settingsProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateinfo.toJson())
        .then((data) async {
      await settingsProvider.setprefs(FirestoreConstants.nickname, nickname);
      await settingsProvider.setprefs(FirestoreConstants.aboutMe, aboutMe);
      await settingsProvider.setprefs(FirestoreConstants.photoUrl, photourl);
      await settingsProvider.setprefs(
          FirestoreConstants.phoneNumber, phoneNumber);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "update success");
    }).catchError((err){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 15,right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton( onPressed: getImage, child: Container(
               margin: EdgeInsets.all(20),
                child: avaterImageFile ==null
                    ?photourl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    photourl,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                    errorBuilder: (context,object,stackTrace){
                      return Icon(
                        Icons.account_circle,
                        size: 90,
                        color: ColorConstants.greyColor,
                      );
                    },
                    loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent ? loadingProgress){
                      if(loadingProgress ==null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        child:  Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            value:loadingProgress.expectedTotalBytes !=null &&
                                loadingProgress.expectedTotalBytes !=null
                            ? loadingProgress.cumulativeBytesLoaded /loadingProgress.expectedTotalBytes!
                                :null,
                          ),
                        ),
                      );
                    }
                  ),
                ): Icon(
                Icons.account_circle,
                size: 90,
                color: ColorConstants.greyColor,
                  )
                :ClipRRect(
              borderRadius: BorderRadius.circular(45),
             child: Image.file(
              avaterImageFile!,
              width: 90,
              height: 90,
              fit:BoxFit.cover ,
                    ),
                  ),
               ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:<Widget> [
                  Container(
                    child: Text(
                      'Name',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.primaryColor),
                          ),
                          hintText: 'Write Your Name...',
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: ColorConstants.greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value){
                          nickname=value;
                        },
                        focusNode: focusNodeNickName,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'About Me.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.primaryColor),
                          ),
                          hintText: 'Write Something About YourSelf...',
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: ColorConstants.greyColor),
                        ),
                        controller: controllerAboutme,
                        onChanged: (value){
                          aboutMe=value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                  ),

                  Container(
                    child: Text(
                      'Phone No.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        style: TextStyle(color: Colors.grey),
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: phoneNumber,
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10,top: 30,bottom: 5),
                    child: SizedBox(
                      width: 400,
                      height: 60,
                      child: CountryCodePicker(
                        onChanged: (country){
                          setState(() {
                            dialCodeDigts=country.dialCode!;
                          });
                        },
                        initialSelection: "IT",
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        favorite: ["+1","US","+20","EGP"],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5,bottom: 5,top: 10),
                      child: TextField(
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.primaryColor),
                          ),
                          hintText: '  Phone Number',
                          hintStyle: TextStyle(color: Colors.black),
                          prefix: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(dialCodeDigts,style: TextStyle(color: Colors.grey),),
                          ),
                        ),
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        controller: _controller,
                      ),
                    ),

                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 50,bottom: 50),
                child: TextButton(
                  onPressed: handeleUpdateData,
                  child: Text(
                    'Upate Now',
                    style: TextStyle(fontSize: 10,color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),

                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)
                          )
                      ),
                    ),

                  ),
                ),
            ],
          ),
        ),
        Positioned(child: isLoading ? LoadingView() :SizedBox.shrink()),

      ],
    );
  }
}
