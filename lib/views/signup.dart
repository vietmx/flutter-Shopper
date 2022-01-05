import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopper/services/auth.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/cupertinoicon.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/storehome.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  const SignUp({Key key, this.toggle}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthMethods _authMethods = AuthMethods();
  Database _database = Database();

  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showPassword = true;

  signUp() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _authMethods
          .signUpWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((val) {
        if (val != null) {
          Map<String, String> userInfoMap = {
            "img":
                "https://firebasestorage.googleapis.com/v0/b/shopper-fcc6c.appspot.com/o/default.png?alt=media&token=678b1158-976c-4f14-8cb0-c850d94ad05a",
            "userName": userNameTextEditingController.text,
            "email": emailTextEditingController.text,
            "fullName": fullNameTextEditingController.text,
            "shippingAddress" : "Enter Your Shipping Address!"
          };
          _database.uploadUserInfo(userInfoMap);
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
                      "The email address is already in use by another account!",
                      style: normalStyle(17),
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
                      child: TextFormField(
                        style: normalStyle(13),
                        textInputAction: TextInputAction.done,
                        validator: (val){
                          return val.isEmpty || val.length < 4 ? "Enter Your Full Name" : null;
                        },
                        controller: fullNameTextEditingController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Full Name",
                            hintStyle: inputBoxStyle(12)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: neumorphicTextInput(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        style: normalStyle(13),
                        textInputAction: TextInputAction.done,
                        validator: (val){
                          return val.isEmpty || val.length < 4 ? "Username Should be at least 4 chars" : null;
                        },
                        controller: userNameTextEditingController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Username",
                            hintStyle: inputBoxStyle(12)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: neumorphicTextInput(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        style: normalStyle(13),
                        textInputAction: TextInputAction.done,
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)
                              ? null : "Provide a valid email";
                        },
                        controller: emailTextEditingController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: inputBoxStyle(12)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    decoration: neumorphicTextInput(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 5),
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
                      signUp();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: neumorphicButton(),
                        child: Text(
                          "Sign Up",
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
                          "Already have an account? ",
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
                          "Log In.",
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


