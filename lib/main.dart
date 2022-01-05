import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopper/services/auth.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/views/storehome.dart';
import 'package:shopper/wrapper/wrapper.dart';
import 'package:provider/provider.dart';
import 'models/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF2F2F7), // navigation bar color
    statusBarColor: Color(0xFFF2F2F7),
    statusBarBrightness: Brightness.light// status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Users>.value(
      value: AuthMethods().userAuthChangeStream,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFFF2F2F7),
          accentColor: Color(0xFF626ABB),
          scaffoldBackgroundColor: Color(0xFFF2F2F7),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 4),
            ()=> Navigator.pushReplacement(context, CupertinoPageRoute(
            builder: (context) => StateManagement()
        ))
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height /4,
            child: FlareActor(
              "assets/splash.flr",
              alignment:Alignment.center,
              fit:BoxFit.contain,
              animation:"splash_shopper",
            ),
          ),
        ),
      );
  }
}

class StateManagement extends StatefulWidget {
  @override
  _StateManagementState createState() => _StateManagementState();
}

class _StateManagementState extends State<StateManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // Simple case
        if (snapshot.hasData) {
          return CustomDrawer();
        }

        return Wrapper();
      },
    );
  }
}

