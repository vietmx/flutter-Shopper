import 'package:flutter/material.dart';
import 'package:shopper/views/signin.dart';
import 'package:shopper/views/signup.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  bool toggleSignIn = true;

  void toggleView(){
    setState(() {
      toggleSignIn = !toggleSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(toggleSignIn){
      return SignIn(toggle: toggleView);
    }else{
      return SignUp(toggle: toggleView);
    }
  }
}