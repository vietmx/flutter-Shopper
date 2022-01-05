import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopper/services/auth.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/cupertinoicon.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/storehome.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  const SignIn({Key key, this.toggle}) : super(key: key);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  AuthMethods _authMethods = AuthMethods();
  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showPassword = true;

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await _authMethods
          .signInWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((result) async {
        if (result != null) {
          Navigator.pushReplacement(
              context, CupertinoPageRoute(builder: (context) => CustomDrawer()));
        } else {
          setState(() {
            isLoading = false;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Oops!",
                      style: normalStyle(23),
                    ),
                    content: Text(
                      "Invalid Email or Password! Enter correct Email & Password and try again!",
                      style: normalStyle(16),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarAuthScreen(context),
      body: isLoading ? Container(
          child: Center(child: spinKit)
      ) : Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height /4,
                    child: FlareActor(
                      "assets/logo.flr",
                      alignment:Alignment.center,
                      fit:BoxFit.contain,
                      animation:"title animation",
                    ),
                  ),
                  Container(
                    decoration: neumorphicTextInput(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: StyleColors.buttonColor),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          style: normalStyle(13),
                          textInputAction: TextInputAction.done,
                          validator: (val){
                            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)
                                ? null : "Provide a valid email";
                          },
                          controller: emailTextEditingController,
                          decoration: InputDecoration(
                              suffixIcon: Icon(email),
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: inputBoxStyle(12)
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: neumorphicTextInput(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: StyleColors.buttonColor),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          style: normalStyle(13),
                          textInputAction: TextInputAction.go,
                          validator: (val){
                            return val.length > 6 ? null : "Password should be 6+ chars";
                          },
                          controller: passwordTextEditingController,
                          obscureText: showPassword,
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                  child: Icon(eyeSlash)
                              ),
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: inputBoxStyle(12)
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  InkWell(
                    splashColor: Colors.white,
                    onTap: (){
                      signIn();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: neumorphicButton(),
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "ProductSans",
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don\'t have an account? ",
                        style: TextStyle(
                          fontFamily: "ProductSans",
                          color: StyleColors.bigText,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          widget.toggle();
                        },
                        child: Text(
                            "Sign Up.",
                            style: normalStyle(14)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


