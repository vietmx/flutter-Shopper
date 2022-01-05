import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/cupertinoicon.dart';
import 'package:shopper/shared/customDrawer.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';
import 'package:shopper/views/product_page.dart';

class Categories extends StatefulWidget {
  final String profileImg;

  const Categories({Key key, this.profileImg}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>
    with SingleTickerProviderStateMixin {
  Database _database = Database();
  TextEditingController searchController = TextEditingController();
  String searchElectronics = "";
  String searchShoes = "";
  String searchGroceries = "";
  String searchHousehold = "";
  Stream electronicsStream;
  Stream shoesStream;
  Stream householdStream;
  Stream groceriesStream;
  Stream profileStream;

  final bodyGlobalKey = GlobalKey();
  final List<Widget> cateTabs = [
    Tab(text: "Electronics"),
    Tab(text: "Shoes"),
    Tab(text: "Household"),
    Tab(
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          "Groceries",
        ),
      ),
    ),
  ];

  TabController _tabController;
  ScrollController _scrollController;
  bool fixedScroll;

  Widget _buildCarousel() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Categories",
              style: normalStyle(30),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_smoothScrollToTop);
    getUserProfileInfo();
    getElectronicsProducts();
    getShoesProducts();
    getHouseholdProducts();
    getGroceriesProducts();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(microseconds: 300),
      curve: Curves.ease,
    );

    setState(() {
      fixedScroll = _tabController.index == 2;
    });
  }

  getUserProfileInfo() async {
    _database.getUserProfile().then((value) {
      setState(() {
        profileStream = value;
      });
    });
  }

  getElectronicsProducts() async {
    _database.getElectronicsProducts().then((value) {
      setState(() {
        electronicsStream = value;
      });
    });
  }

  getShoesProducts() async {
    _database.getShoesProducts().then((value) {
      setState(() {
        shoesStream = value;
      });
    });
  }

  getHouseholdProducts() async {
    _database.getHouseholdProducts().then((value) {
      setState(() {
        householdStream = value;
      });
    });
  }

  getGroceriesProducts() async {
    _database.getGroceriesProducts().then((value) {
      setState(() {
        groceriesStream = value;
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(
              child: TabBar(
                onTap: (cateTabs) {
                  FocusScope.of(context).unfocus();
                },
                labelPadding: EdgeInsets.only(right: 12, left: 15),
                indicatorColor: Colors.transparent,
                labelStyle: normalStyle(15),
                labelColor: StyleColors.buttonColor,
                unselectedLabelColor: StyleColors.hintText,
                controller: _tabController,
                isScrollable: true,
                tabs: cateTabs,
              ),
            ),
          ];
        },
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10,),
                      decoration: neumorphicGrid(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: StyleColors.buttonColor),
                          child: TextFormField(
                            style: normalStyle(15),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            controller: searchController,
                            decoration: InputDecoration(
                                suffixIcon: Icon(search),
                                border: InputBorder.none,
                                hintText: "Find Product",
                                hintStyle: inputBoxStyle(14)),
                            onChanged: (val) {
                              setState(() {
                                searchElectronics = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      flex: 10,
                      child: StreamBuilder(
                        stream: (searchElectronics != "" &&
                            searchElectronics != null)
                            ? FirebaseFirestore.instance
                            .collection('products')
                            .doc('categories').collection('electronics')
                            .where("search", arrayContains: searchElectronics
                            .toLowerCase())
                            .snapshots()
                            : electronicsStream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            shrinkWrap: true,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Electronics(
                                pName: snapshot.data.docs[index]
                                    .data()['pname'],
                                price: snapshot.data.docs[index]
                                    .data()['price']
                                    .toDouble(),
                                img: snapshot.data.docs[index]
                                    .data()['img'],
                                desc: snapshot.data.docs[index]
                                    .data()['desc'],
                                fav: snapshot.data.docs[index]
                                    .data()['fav'],
                                size: List.from(snapshot
                                    .data.docs[index]
                                    .data()['size']),
                                color: List.from(snapshot
                                    .data.docs[index]
                                    .data()['color']),
                              );
                            },
                          )
                              : Center(
                              child: spinKit
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10,),
                      decoration: neumorphicGrid(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: StyleColors.buttonColor),
                          child: TextFormField(
                            style: normalStyle(15),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                suffixIcon: Icon(search),
                                border: InputBorder.none,
                                hintText: "Find Product",
                                hintStyle: inputBoxStyle(14)),
                            onChanged: (val) {
                              setState(() {
                                searchShoes = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      flex: 10,
                      child: StreamBuilder(
                        stream: (searchShoes != "" && searchShoes != null)
                            ? FirebaseFirestore.instance
                            .collection('products')
                            .doc('categories').collection('shoes')
                            .where("search", arrayContains: searchShoes
                            .toLowerCase())
                            .snapshots()
                            : shoesStream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? GridView.builder(
                            padding:
                            EdgeInsets.symmetric(horizontal: 5),
                            shrinkWrap: true,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Shoes(
                                pName: snapshot.data.docs[index]
                                    .data()['pname'],
                                price: snapshot.data.docs[index]
                                    .data()['price']
                                    .toDouble(),
                                img: snapshot.data.docs[index]
                                    .data()['img'],
                                desc: snapshot.data.docs[index]
                                    .data()['desc'],
                                fav: snapshot.data.docs[index]
                                    .data()['fav'],
                                size: List.from(snapshot
                                    .data.docs[index]
                                    .data()['size']),
                                color: List.from(snapshot
                                    .data.docs[index]
                                    .data()['color']),
                              );
                            },
                          )
                              : Center(
                              child: spinKit
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10,),
                      decoration: neumorphicGrid(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: StyleColors.buttonColor),
                          child: TextFormField(
                            style: normalStyle(15),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                suffixIcon: Icon(search),
                                border: InputBorder.none,
                                hintText: "Find Product",
                                hintStyle: inputBoxStyle(14)),
                            onChanged: (val) {
                              setState(() {
                                searchHousehold = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      flex: 10,
                      child: StreamBuilder(
                        stream: (searchHousehold != "" &&
                            searchHousehold != null)
                            ? FirebaseFirestore.instance
                            .collection('products')
                            .doc('categories').collection('household')
                            .where("search", arrayContains: searchHousehold
                            .toLowerCase())
                            .snapshots()
                            : householdStream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? GridView.builder(
                            padding:
                            EdgeInsets.symmetric(horizontal: 5),
                            shrinkWrap: true,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Household(
                                pName: snapshot.data.docs[index]
                                    .data()['pname'],
                                price: snapshot.data.docs[index]
                                    .data()['price']
                                    .toDouble(),
                                img: snapshot.data.docs[index]
                                    .data()['img'],
                                desc: snapshot.data.docs[index]
                                    .data()['desc'],
                                fav: snapshot.data.docs[index]
                                    .data()['fav'],
                                size: List.from(snapshot
                                    .data.docs[index]
                                    .data()['size']),
                                color: List.from(snapshot
                                    .data.docs[index]
                                    .data()['color']),
                              );
                            },
                          )
                              : Center(
                              child: spinKit
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10,),
                      decoration: neumorphicGrid(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: StyleColors.buttonColor),
                          child: TextFormField(
                            style: normalStyle(15),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                suffixIcon: Icon(search),
                                border: InputBorder.none,
                                hintText: "Find Product",
                                hintStyle: inputBoxStyle(14)),
                            onChanged: (val) {
                              setState(() {
                                searchGroceries = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      flex: 10,
                      child: StreamBuilder(
                        stream: (searchGroceries != "" &&
                            searchGroceries != null)
                            ? FirebaseFirestore.instance
                            .collection('products')
                            .doc('categories').collection('groceries')
                            .where("search", arrayContains: searchGroceries
                            .toLowerCase())
                            .snapshots()
                            : groceriesStream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? GridView.builder(
                            padding:
                            EdgeInsets.symmetric(horizontal: 5),
                            shrinkWrap: true,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Groceries(
                                pName: snapshot.data.docs[index]
                                    .data()['pname'],
                                price: snapshot.data.docs[index]
                                    .data()['price'],
                                img: snapshot.data.docs[index]
                                    .data()['img'],
                                desc: snapshot.data.docs[index]
                                    .data()['desc'],
                                fav: snapshot.data.docs[index]
                                    .data()['fav'],
                                size: List.from(snapshot
                                    .data.docs[index]
                                    .data()['size']),
                                color: List.from(snapshot
                                    .data.docs[index]
                                    .data()['color']),
                              );
                            },
                          )
                              : Center(
                              child: spinKit
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),),);
  }
}

class Electronics extends StatelessWidget {
  final String pName;
  final String desc;
  final double price;
  final bool fav;
  final String img;
  final List<String> size;
  final List<String> color;

  const Electronics({Key key,
    this.pName,
    this.desc,
    this.price,
    this.fav,
    this.img,
    this.size,
    this.color})
      : super(key: key);

  addToFav() {
    Map<String, dynamic> favoriteMap = {
      "pname": pName,
      "price": price,
      "img": img,
      "desc": desc,
      "size": size,
      "color": color,
    };
    Database().addItemToUserFavorite(favoriteMap);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(size);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ProductPage(
                  pName: pName,
                  price: price,
                  desc: desc,
                  img: img,
                  fav: fav,
                  size: size,
                  color: color,
                )));
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: EdgeInsets.all(7),
        decoration: neumorphicGrid(),
        child: GridTile(
          header: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "\$",
                      style: TextStyle(
                          fontFamily: "ProductSans",
                          color: Colors.deepOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: price.toString(), style: priceStyle(18, context))
                ]),
              ),
              Spacer(),
              Material(
                child: Ink(
                  child: InkWell(
                    child: Stack(children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      )
                    ]),
                    onTap: () {
                      addToFav();
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item Added To Favorite List!",
                            style: TextStyle(
                                fontFamily: 'ProductSans', color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          child: Stack(children: [
            Positioned(
              left: 40,
              top: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.deepOrange[100].withOpacity(.5),
                ),
              ),
            ),
            Positioned(
              child: Container(
                padding:
                EdgeInsets.only(left: 35, right: 0, bottom: 50, top: 30),
                child: Image.network(
                  img,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ]),
          footer: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            child: Text(
              pName,
              style: priceStyle(13, context),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class Shoes extends StatefulWidget {
  final String pName;
  final String desc;
  final double price;
  final bool fav;
  final String img;
  final List<String> size;
  final List<String> color;

  Shoes({Key key,
    this.pName,
    this.desc,
    this.price,
    this.fav,
    this.img,
    this.size,
    this.color})
      : super(key: key);

  @override
  _ShoesState createState() => _ShoesState();
}

class _ShoesState extends State<Shoes> {
  Database _database = Database();

  addToFav() {
    Map<String, dynamic> favoriteMap = {
      "pname": widget.pName,
      "price": widget.price,
      "img": widget.img,
      "desc": widget.desc,
      "size": widget.size,
      "color": widget.color,
    };
    _database.addItemToUserFavorite(favoriteMap);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ProductPage(
                  pName: widget.pName,
                  price: widget.price,
                  desc: widget.desc,
                  img: widget.img,
                  fav: widget.fav,
                  size: widget.size,
                  color: widget.color,
                )));
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: EdgeInsets.all(7),
        decoration: neumorphicGrid(),
        child: GridTile(
          header: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "\$",
                      style: TextStyle(
                          fontFamily: "ProductSans",
                          color: Colors.deepOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: widget.price.toString(),
                      style: priceStyle(18, context))
                ]),
              ),
              Spacer(),
              Material(
                child: Ink(
                  child: InkWell(
                    child: Stack(children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      )
                    ]),
                    onTap: () {
                      addToFav();
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item Added To Favorite List!",
                            style: TextStyle(
                                fontFamily: 'ProductSans', color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(bottom: 25),
            child: Image.network(
              widget.img,
              fit: BoxFit.contain,
            ),
          ),
          footer: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            child: Text(
              widget.pName,
              style: priceStyle(13, context),
            ),
          ),
        ),
      ),
    );
  }
}

class Household extends StatelessWidget {
  final String pName;
  final String desc;
  final double price;
  final bool fav;
  final String img;
  final List<String> size;
  final List<String> color;

  const Household({Key key,
    this.pName,
    this.desc,
    this.price,
    this.fav,
    this.img,
    this.size,
    this.color})
      : super(key: key);

  addToFav() {
    Map<String, dynamic> favoriteMap = {
      "pname": pName,
      "price": price,
      "img": img,
      "desc": desc,
      "size": size,
      "color": color
    };
    Database().addItemToUserFavorite(favoriteMap);
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      ProductPage(
                        pName: pName,
                        price: price,
                        desc: desc,
                        img: img,
                        fav: fav,
                        size: size,
                        color: color,
                      )));
        },
        child: Container(
          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
          padding: EdgeInsets.all(7),
          decoration: neumorphicGrid(),
          child: GridTile(
            header: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "\$",
                        style: TextStyle(
                            fontFamily: "ProductSans",
                            color: Colors.deepOrange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: '$price', style: priceStyle(18, context))
                  ]),
                ),
                Spacer(),
                Material(
                  child: Ink(
                    child: InkWell(
                      child: Stack(children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        )
                      ]),
                      onTap: () {
                        addToFav();
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Item Added To Favorite List!",
                              style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.only(bottom: 25),
              child: Image.network(
                img,
                fit: BoxFit.contain,
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
              child: Text(
                pName,
                style: priceStyle(13, context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Groceries extends StatelessWidget {
  final String pName;
  final String desc;
  final double price;
  final bool fav;
  final String img;
  final List<String> size;
  final List<String> color;

  const Groceries({Key key,
    this.pName,
    this.desc,
    this.price,
    this.fav,
    this.img,
    this.size,
    this.color})
      : super(key: key);

  addToFav() {
    Map<String, dynamic> favoriteMap = {
      "pname": pName,
      "price": price,
      "img": img,
      "desc": desc,
      "size": size,
      "color": color
    };
    Database().addItemToUserFavorite(favoriteMap);
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      ProductPage(
                        pName: pName,
                        price: price,
                        desc: desc,
                        img: img,
                        fav: fav,
                        size: size,
                        color: color,
                      )));
        },
        child: Container(
          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
          padding: EdgeInsets.all(7),
          decoration: neumorphicGrid(),
          child: GridTile(
            header: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "\$",
                        style: TextStyle(
                            fontFamily: "ProductSans",
                            color: Colors.deepOrange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: '$price', style: priceStyle(18, context))
                  ]),
                ),
                Spacer(),
                Material(
                  child: Ink(
                    child: InkWell(
                      child: Stack(children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        )
                      ]),
                      onTap: () {
                        addToFav();
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Item Added To Favorite List!",
                              style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.only(bottom: 35, top: 20),
              child: Image.network(
                img,
                fit: BoxFit.contain,
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
              child: Text(
                pName,
                style: priceStyle(13, context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
