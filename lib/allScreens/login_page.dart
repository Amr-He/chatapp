
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class LogginPage extends StatefulWidget {
  const LogginPage({Key? key}) : super(key: key);

  @override
  _LogginPageState createState() => _LogginPageState();
}

class _LogginPageState extends State<LogginPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider=Provider.of<AuthProvider>(context);
    switch(authProvider.status){
      case Status.authenticateErorr:
        Fluttertoast.showToast(msg: "Sign In Fail");
        break;
      case Status.authenticatecannceled:
        Fluttertoast.showToast(msg: "Sign In cannceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign In Success");
        break;
        default:
          break;
    }

    return Scaffold(
      backgroundColor: Colors.blue[80],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              "images/back.png"
            ),
          ),
          SizedBox(height: 20.0,),
          Padding(
              padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () async{
                bool isSuccess=await authProvider.handleSingin();
                if(isSuccess){
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>Homepage()));
                }
              },
              child: Image.asset(
                  "images/google_login.jpg"
              ),
            ),
          ),
          Positioned(
              child: authProvider.status== Status.authenticating?LoadingView():SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
