import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopper/services/auth.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/cart.dart';
import 'package:shopper/views/categories.dart';
import 'package:shopper/views/favorite.dart';
import 'package:shopper/views/messages.dart';
import 'package:shopper/views/profile.dart';
import 'package:shopper/views/storehome.dart';
import '../main.dart';
import 'cupertinoicon.dart';

class CustomDrawer extends StatefulWidget {

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => new CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  static const Duration toggleDuration = Duration(milliseconds: 250);
  static const double maxSlide = 225;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;
  AnimationController _animationController;
  bool _canBeDragged = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: CustomDrawerState.toggleDuration,
    );
  }

  void toggle() => _animationController.isDismissed
      ? _animationController.forward()
      : _animationController.reverse();

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  void toggleDrawer() => _animationController.isCompleted ? close() : open();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _animationController,
          child: StoreHome(),
          builder: (context, _ ) {
            double animValue = _animationController.value;
            final slideAmount = maxSlide * animValue;
            final contentScale = 1.0 - (0.3 * animValue);
            return Stack(
              children: <Widget>[
                MyDrawer(),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slideAmount)
                    ..scale(contentScale, contentScale),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _animationController.isCompleted ? close : null,
                    child: StoreHome(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    //I have no idea what it means, copied from Drawer
    double _kMinFlingVelocity = 365.0;

    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }
}

class MyDrawer extends StatefulWidget {

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  Database _database = Database();
  Stream profileStream;

  @override
  void initState() {
    getUserProfileInfo();
    super.initState();
  }

  getUserProfileInfo() async {
    _database.getUserProfile().then((value){
      setState(() {
        profileStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.blueAccent,
      child: SafeArea(
        child: Theme(
          data: ThemeData(
              brightness: Brightness.dark,
          ),
          child: Container(
            color: Theme.of(context).accentColor,
            child: StreamBuilder(
              stream: profileStream,
              builder: (context, snapshot) {
                return snapshot.hasData ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 15,),
                    ListTile(
                      leading: InkWell(
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(
                            builder : (context) => Profile()
                          ));
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.data()["img"]),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      title: InkWell(
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(
                              builder : (context) => Profile()
                          ));
                        },
                        child: Text(
                          snapshot.data.data()["fullName"],
                          style: menuStyle(18),
                        ),
                      ),
                      subtitle: Text(
                        snapshot.data.data()["email"],
                        style: menuStyle(12),
                      ),
                    ),
                    Spacer(),
                    ListTile(
                      onTap: (){
                        Navigator.pushReplacement(context, CupertinoPageRoute(
                            builder: (context) => CustomDrawer()
                        ));
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 1, top: 0),
                        child: SvgPicture.asset(
                            'assets/clipboard.svg',
                            color: Colors.white,
                        ),
                      ),
                      title: Text(
                          'Categories',
                          style: menuStyle(18),
                      ),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(
                            builder: (context) => Messages()
                        ));
                      },
                      leading: Icon(
                        Icons.chat_bubble
                      ),
                      title: Text(
                        'Messages',
                        style: menuStyle(18),
                      ),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(
                            builder: (context) => Favorites()
                        ));
                      },
                      leading: Icon(
                          heart
                      ),
                      title: Text(
                        'Favorites',
                        style: menuStyle(18),
                      ),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(
                            builder: (context) => Cart()
                        ));
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 0, top: 0),
                        child: SvgPicture.asset(
                          'assets/cart.svg',
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Your Cart',
                        style: menuStyle(18),
                      ),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(
                            builder: (context) => Profile()
                        ));
                      },
                      leading: Icon(settings, size: 33,),
                      title: Text(
                        'Settings',
                        style: menuStyle(18),
                      ),
                    ),
                    Spacer(),
                    ListTile(
                      onTap: () async{
                        await AuthMethods().signOut();
                        Navigator.pushReplacement(
                            context, CupertinoPageRoute(builder: (context) => MyApp()));
                      },
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 0, top: 0),
                        child: SvgPicture.asset(
                          'assets/signout.svg',
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Sign Out',
                        style: menuStyle(18),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ) : Text("Loading...", style: menuStyle(18),);
              }
            ),
          ),
        ),
      ),
    );
  }
}