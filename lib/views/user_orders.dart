import 'package:flutter/material.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/loading.dart';

class UserOrders extends StatefulWidget {
  @override
  _UserOrdersState createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  Stream profileStream;
  Database _database = Database();

  @override
  void initState() {
    getUserProfileInfo();
    super.initState();
  }

  getUserProfileInfo() async {
    _database.getUserProfile().then((value) {
      setState(() {
        profileStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket,
              size: 150,
              color: StyleColors.hintText,
            ),
            Text(
              "Coming Soon!",
              style: TextStyle(
                color: StyleColors.hintText,
                fontFamily: "ProductSans",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
