

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Utilites {
  static bool isKeyboardShowing() {

  if(WidgetsBinding.instance !=null){
  return WidgetsBinding.instance!.window.viewInsets.bottom >0;
  }else{
  return false;
  }
}
static CloseKeyboard(BuildContext context){
    FocusScopeNode currentFocus=FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus){
      currentFocus.unfocus();
    }
}
}