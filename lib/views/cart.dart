import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/checkout.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  Stream profileStream;
  Stream itemStream;
  Database _database = Database();

  @override
  void initState() {
    getUserProfileInfo();
    fetchItemFromUserCart();
    super.initState();
  }

  getUserProfileInfo() async {
    _database.getUserProfile().then((value) {
      setState(() {
        profileStream = value;
      });
    });
  }

  fetchItemFromUserCart() async {
    _database.fetchItemFromUserCart().then((value) {
      setState(() {
        itemStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, actions: [
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
                child: spinKit,
                    );
            })
      ]),
      body: Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 15,
                  ),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Shopping Cart',
                    style: normalStyle(30),
                  ),
                ),
              ),
              Expanded(
                flex: 11,
                child: StreamBuilder(
                  stream: itemStream,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return CartTile(
                                pname:
                                    snapshot.data.docs[index].data()['pname'],
                                price:
                                    snapshot.data.docs[index].data()['price'].toDouble(),
                                color:
                                    snapshot.data.docs[index].data()['color'],
                                img: snapshot.data.docs[index].data()['img'],
                                size: snapshot.data.docs[index].data()['size'],
                                quantity: snapshot.data.docs[index]
                                    .data()['quantity'],
                                dId: snapshot.data.documents[index].reference,
                              );
                            },
                          )
                        : Center(
                        child: spinKit);
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: StreamBuilder(
                    stream: itemStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text(
                            "Calculating...",
                            style: normalStyle(15),
                          ),
                        );
                      } else {
                        var ds = snapshot.data.docs;
                        double sum = 0.0;
                        for (int i = 0; i < ds.length; i++)
                          sum += (ds[i].data()['price']);
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                      text: "Total price : ",
                                      style: normalStyle(16),
                                      children: [
                                        TextSpan(
                                          text: "$sum USD",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'ProductSans',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange
                                          ),
                                        )
                                      ]
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Ink(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context, CupertinoPageRoute(
                                          builder: (context) =>
                                              CheckOut(
                                                totalPayment: sum,
                                              )
                                      ));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      margin: EdgeInsets.only(left: 5),
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      decoration: neumorphicButton(),
                                      child: Text(
                                        'Check Out',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'ProductSans',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]);
                      }
                    }),
              ),
            ],
          )),
    );
  }
}

class CartTile extends StatelessWidget {
  final String pname;
  final String color;
  final double price;
  final String img;
  final String size;
  final int quantity;
  final DocumentReference dId;
  const CartTile(
      {Key key,
      this.pname,
      this.color,
      this.price,
      this.img,
      this.size,
      this.quantity,
      this.dId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          margin: EdgeInsets.only(top: 8, bottom: 8),
          decoration: neumorphicSearch(),
          child: ListTile(
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 60,
                minHeight: 44,
                maxWidth: 70,
                maxHeight: 44,
              ),
              child: Image.network(
                img,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              '$pname',
              style: normalStyle(17),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Hexcolor(color),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '\$$price',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        fontSize: 15),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'S:$size',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        fontSize: 15),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Q:$quantity',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: Colors.white,
            iconWidget: Icon(
              Icons.menu,
              size: 35,
              color: Theme.of(context).accentColor,
            ),
            onTap: () {},
          ),
          IconSlideAction(
            color: Colors.red,
            iconWidget: Icon(
              Icons.delete,
              size: 35,
              color: Colors.white,
            ),
            onTap: () async {
              await FirebaseFirestore.instance
                  .runTransaction((Transaction myTransaction) async {
                myTransaction.delete(dId);
              });
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Item has been removed from cart!"),
                backgroundColor: Colors.red,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
    );
  }
}
