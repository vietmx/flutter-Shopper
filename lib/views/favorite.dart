import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/product_page.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Stream favStream;
  Stream profileStream;
  Database _database = Database();

  @override
  void initState() {
    getUserProfileInfo();
    fetchItemFromUserFavorite();
    super.initState();
  }

  getUserProfileInfo() async {
    _database.getUserProfile().then((value){
      setState(() {
        profileStream = value;
      });
    });
  }

  fetchItemFromUserFavorite() async {
    _database.fetchItemFromUserFavorite().then((value) {
      setState(() {
        favStream = value;
      });
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
              icon: Icon(Icons.menu, color: StyleColors.bigText, size: 30,),
              onPressed: () => CustomDrawer.of(context).open(),
            );
          },
        ),
        actions: [
          StreamBuilder(
              stream: profileStream,
              builder: (context, snapshot) {
                return snapshot.hasData ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(snapshot.data.data()["img"]),
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
              }
          )
        ],
      ),
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
                    'Favorites',
                    style: normalStyle(30),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: StreamBuilder(
                  stream: favStream,
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
                                img: snapshot.data.docs[index].data()['img'],
                                dId: snapshot.data.documents[index].reference,
                                desc: snapshot.data.docs[index].data()['desc'],
                                size: List.from(snapshot.data.docs[index].data()['size'],),
                                color: List.from(snapshot.data.docs[index].data()['color'],),
                              );
                            },
                          )
                        : Center(
                        child: spinKit);
                  },
                ),
              ),
            ],
          )),
    );
  }
}

class CartTile extends StatefulWidget {
  final String pname;
  final double price;
  final String img;
  final String desc;
  final List<String> size;
  final List<String> color;
  final DocumentReference dId;

  const CartTile({Key key,
    this.pname,
    this.price,
    this.img,
    this.dId, this.desc, this.size, this.color})
      : super(key: key);

  @override
  _CartTileState createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: neumorphicSearch(),
        child: ListTile(
          leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 60,
              minHeight: 44,
              maxWidth: 70,
              maxHeight: 50,
            ),
            child: Image.network(
              widget.img,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            '${widget.pname}',
            style: normalStyle(15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                Text(
                  '\$${widget.price}',
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
            Icons.details,
            size: 35,
            color: Theme.of(context).accentColor,
          ),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(
                builder: (context) => ProductPage(
                  img: widget.img,
                  price: widget.price,
                  pName: widget.pname,
                  desc: widget.desc,
                  size: widget.size,
                  color: widget.color,
                )
            ));
          },
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
              myTransaction.delete(widget.dId);
            });
            setState(() {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Item has been removed from favorite!"),
                backgroundColor: Colors.red,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
              ));
            });
          },
        ),
      ],
    );
  }
}
