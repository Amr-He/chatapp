


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:provider/src/provider.dart';
import 'home_page.dart';

class splashpage extends StatefulWidget {
  const splashpage({Key? key}) : super(key: key);

  @override
  _splashpageState createState() => _splashpageState();
}

class _splashpageState extends State<splashpage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5),(){
      CheckSignedIn();
    });
  }
void CheckSignedIn() async {
    AuthProvider authProvider =context.read<AuthProvider>();
    bool isloggedin =await authProvider.isLoggedin();
    if(isloggedin){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>Homepage()));
      return;
    }
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>LogginPage()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "images/splash.png",
              width: 300,
              height: 300,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "welcome your Health app",
              style: TextStyle(color: ColorConstants.themeColor),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: ColorConstants.themeColor,),
            )
          ],
        ),
      ),
    );
  }
}
