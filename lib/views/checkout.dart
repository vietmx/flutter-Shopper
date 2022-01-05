import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';

class CheckOut extends StatefulWidget {
  final double totalPayment;
  const CheckOut({Key key, @required this.totalPayment}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CheckOut",
            style: normalStyle(20),
          ),
          centerTitle: true,
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
                          child: CircularProgressIndicator(),
                        );
                })
          ],
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            indicatorColor: StyleColors.bigText,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Card",
                      style: normalStyle(16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.credit_card,
                      color: StyleColors.bigText,
                      size: 20,
                    )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "PayPal",
                      style: normalStyle(16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset('assets/paypal.svg'))
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Cash",
                      style: normalStyle(16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset('assets/cash.svg'))
                  ],
                ),
              ),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: profileStream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? TabBarView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Card(
                          customerName: snapshot.data.data()['fullName'],
                          shippingAddress:
                              snapshot.data.data()['shippingAddress'],
                          totalPayment: widget.totalPayment,
                        ),
                        PayPal(
                          customerName: snapshot.data.data()['fullName'],
                          shippingAddress:
                              snapshot.data.data()['shippingAddress'],
                          totalPayment: widget.totalPayment,
                        ),
                        Cash(
                          customerName: snapshot.data.data()['fullName'],
                          shippingAddress:
                              snapshot.data.data()['shippingAddress'],
                          totalPayment: widget.totalPayment,
                        ),
                      ],
                    )
                  : Center(
                      child: spinKit,
                    );
            }),
      ),
    );
  }
}

class Card extends StatefulWidget {
  final String customerName;
  final double totalPayment;
  final String shippingAddress;
  String items;
  final int quantity;

  Card(
      {Key key,
      this.customerName,
      this.totalPayment,
      this.shippingAddress,
      this.items,
      this.quantity})
      : super(key: key);

  @override
  _CardState createState() => _CardState();
}

class _CardState extends State<Card> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameOnCard = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expiryDate = TextEditingController();
  TextEditingController ccv = TextEditingController();

  payment(){
    if (_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> paymentMap = {
        "customerName": widget.customerName,
        "totalPayment": widget.totalPayment,
        "shippingAddress": widget.shippingAddress,
        "nameOnCard": nameOnCard.text,
        "cardNumber": cardNumber.text,
        "expiryDate": expiryDate.text,
        "ccv": ccv.text,
      };
      Database().paymentUser(paymentMap);
    }else {
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
                  "Something went wrong, please try again!",
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
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? spinKit : SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              margin: EdgeInsets.only(left: 15, right: 15, top: 20),
              padding: EdgeInsets.all(20),
              decoration: neumorphicButton(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Payment",
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.totalPayment} USD',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Name: ${widget.customerName}',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Shipping Address: ${widget.shippingAddress}',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SvgPicture.asset('assets/Line 1.svg')),
            SizedBox(
              height: 25,
            ),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Supported Card Types!",
                  style: inputBoxStyle(15),
                )),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(15),
                      decoration: neumorphicTextInput(),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset("assets/mastercard.svg")),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(15),
                      decoration: neumorphicTextInput(),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset("assets/visa.svg")),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      margin: EdgeInsets.all(15),
                      decoration: neumorphicTextInput(),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset("assets/Apple_Card.svg")),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Enter your card details!",
                  style: inputBoxStyle(15),
                )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: neumorphicTextInput(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  style: normalStyle(15),
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    return val.isEmpty ? "Cannot leave this field empty!" : null;
                  },
                  controller: nameOnCard,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name on card",
                      hintStyle: inputBoxStyle(12)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: neumorphicTextInput(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  style: normalStyle(15),
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    return val.isEmpty || val.length < 16
                        ? "Enter correct card format"
                        : null;
                  },
                  controller: cardNumber,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Card Number",
                      hintStyle: inputBoxStyle(12)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: neumorphicTextInput(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  style: normalStyle(15),
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    return val.isEmpty || val.length < 5
                        ? "Enter correct date format"
                        : null;
                  },
                  controller: expiryDate,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Expiry Date (eg: mm/yy)",
                      hintStyle: inputBoxStyle(12)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: neumorphicTextInput(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  style: normalStyle(15),
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    return val.isEmpty || val.length < 3
                        ? "Enter correct ccv"
                        : null;
                  },
                  controller: ccv,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "CCV",
                      hintStyle: inputBoxStyle(12)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Material(
              child: Ink(
                child: InkWell(
                  onTap: () {
                    payment();
                    setState(() {
                      isLoading = false;
                    });
                    if(_formKey.currentState.validate()){
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Your Payment Was Successful!",
                              style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  color: Colors.white
                              ),
                            ),
                            backgroundColor: StyleColors.buttonColor,
                          )
                      );
                      nameOnCard.clear();
                      cardNumber.clear();
                      ccv.clear();
                      expiryDate.clear();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.all(12),
                    width: MediaQuery.of(context).size.width,
                    decoration: neumorphicButton(),
                    child: Text(
                      'Proceed To Pay',
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
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class PayPal extends StatelessWidget {
  final String customerName;
  final double totalPayment;
  final String shippingAddress;

  const PayPal(
      {Key key, this.customerName, this.totalPayment, this.shippingAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
        padding: EdgeInsets.all(20),
        decoration: neumorphicButton(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Payment",
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            Text(
              '$totalPayment USD',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Name: $customerName',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Text(
              'Shipping Address: $shippingAddress',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class Cash extends StatefulWidget {
  final String customerName;
  final double totalPayment;
  final String shippingAddress;

  const Cash(
      {Key key, this.customerName, this.totalPayment, this.shippingAddress})
      : super(key: key);

  @override
  _CashState createState() => _CashState();
}

class _CashState extends State<Cash> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
        padding: EdgeInsets.all(20),
        decoration: neumorphicButton(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Payment",
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            Text(
              '${widget.totalPayment} USD',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Name: ${widget.customerName}',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Text(
              'Shipping Address: ${widget.shippingAddress}',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
