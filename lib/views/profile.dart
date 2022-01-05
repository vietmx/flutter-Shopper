import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/user_orders.dart';

import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final String name;
  final String email;

  const Profile({Key key, this.name, this.email}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Database database = Database();
  Stream profileStream;

  @override
  void initState() {
    getUserProfileInfo();
    super.initState();
  }

  getUserProfileInfo() async {
    database.getUserProfile().then((value) {
      setState(() {
        profileStream = value;
      });
    });
  }

  Widget profileList() {
    return StreamBuilder(
        stream: profileStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ProfileTiles(
                  name: snapshot.data.data()["fullName"],
                  email: snapshot.data.data()["email"],
                  img: snapshot.data.data()["img"],
                  username: snapshot.data.data()["userName"],
                  shippingAddress: snapshot.data.data()["shippingAddress"],
                )
              : Center(child: spinKit);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: StyleColors.bigText,
                  size: 30,
                ),
                onPressed: () => CustomDrawer.of(context).open(),
              );
            },
          ),
          actions: [
            StreamBuilder(
                stream: profileStream,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 13),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage:
                      NetworkImage(snapshot.data.data()["img"]),
                      backgroundColor: Colors.white54,
                    ),
                  )
                      : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child:
                      SizedBox(width: 15, height: 15, child: spinKit),
                    ),
                  );
                })
          ],
        ),
        body: profileList());
  }
}

class ProfileTiles extends StatelessWidget {
  final String name;
  final String email;
  final String img;
  final String username;
  final String shippingAddress;

  const ProfileTiles(
      {Key key, this.name, this.email, this.img, this.username, this.shippingAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        appBar: AppBar(
          brightness: Brightness.light,
          toolbarHeight: 20,
          backgroundColor: Theme
              .of(context)
              .scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            "User Profile",
            style: normalStyle(28),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                      tag: 'pic',
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[900],
                        backgroundImage: NetworkImage('$img'),
                        radius: 60,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Name: ",
                        style: profileStyle(18),
                        children: [
                          TextSpan(
                              text: '$name',
                              style: normalStyle(18)
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "User Name: ",
                        style: profileStyle(18),
                        children: [
                          TextSpan(
                              text: '$username',
                              style: normalStyle(18)
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Email: ",
                        style: profileStyle(18),
                        children: [
                          TextSpan(
                              text: '$email',
                              style: normalStyle(18)
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Shipping Address: ",
                        style: profileStyle(18),
                        children: [
                          TextSpan(
                              text: '$shippingAddress',
                              style: normalStyle(18)
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Hero(
                    tag: 'edit',
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      decoration: neumorphicButton(),
                      child: FlatButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => EditProfile()));
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          "Edit Profile",
                          style: menuStyle(15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    decoration: neumorphicOrderButton(),
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => UserOrders()));
                      },
                      icon: Icon(
                        Icons.shopping_basket,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        "Orders",
                        style: menuStyle(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 50,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
