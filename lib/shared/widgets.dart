import 'package:flutter/material.dart';
import 'package:shopper/shared/colors.dart';


Widget appBarAuthScreen(BuildContext context){
  return AppBar(
    elevation: 0,
  );
}


TextStyle logoStyle(){
  return TextStyle(
    fontFamily: "ProductSans",
    color: StyleColors.bigText,
    fontSize: 35,
    fontWeight: FontWeight.bold
  );
}

TextStyle normalStyle(double fs){
  return TextStyle(
      fontFamily: "ProductSans",
      color: StyleColors.bigText,
      fontSize: fs,
      fontWeight: FontWeight.bold
  );
}

TextStyle menuStyle(double fs){
  return TextStyle(
      fontFamily: "ProductSans",
      color: Colors.white,
      fontSize: fs,
      fontWeight: FontWeight.bold
  );
}

TextStyle priceStyle(double fs, BuildContext context){
  return TextStyle(
      fontFamily: "ProductSans",
      color: Theme.of(context).accentColor,
      fontSize: fs,
      fontWeight: FontWeight.bold
  );
}

BoxDecoration neumorphicTextInput(){
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff000000).withOpacity(.16),
        offset: Offset(
          6,
          6,
        ),
      ),
      BoxShadow(
        blurRadius: 18,
        color: Color(0xffffffff),
        offset: Offset(
          -6,
          -6,
        ),
      ),
    ],
    borderRadius: BorderRadius.all(
      Radius.circular(
        15,
      ),
    ),
  );
}

BoxDecoration neumorphicSearch(){
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff000000).withOpacity(.10),
        offset: Offset(
          6,
          6,
        ),
      ),
      BoxShadow(
        blurRadius: 18,
        color: Color(0xffffffff),
        offset: Offset(
          -6,
          -6,
        ),
      ),
    ],
    borderRadius: BorderRadius.all(
      Radius.circular(
        15,
      ),
    ),
  );
}

BoxDecoration neumorphicGrid(){
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        blurRadius: 10,
        color: Color(0xff000000).withOpacity(.16),
        offset: Offset(
          2,
          3,
        ),
      ),
      BoxShadow(
        blurRadius: 18,
        color: Color(0xffffffff),
        offset: Offset(
          -3,
          -3,
        ),
      ),
    ],
    borderRadius: BorderRadius.all(
      Radius.circular(
        15,
      ),
    ),
  );
}

BoxDecoration neumorphicButton(){
  return BoxDecoration(
    color: StyleColors.buttonColor,
    boxShadow: [
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff000000).withOpacity(.20),
        offset: Offset(
          6,
          6,
        ),
      ),
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff727bd9).withOpacity(.20),
        offset: Offset(
          -6,
          -6,
        ),
      ),
    ],
    borderRadius: BorderRadius.all(
      Radius.circular(
        15,
      ),
    ),
  );
}

BoxDecoration neumorphicOrderButton() {
  return BoxDecoration(
      color: Color(0xfffb7850),
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          color: Color(0xff000000).withOpacity(.20),
          offset: Offset(
            6,
            6,
          ),
        ),
        BoxShadow(
          blurRadius: 18,
          color: Color(0xffff8a5c).withOpacity(.10),
          offset: Offset(
            -6,
            -6,
          ),
        ),
      ],
      gradient: null,
      borderRadius: BorderRadius.all(Radius.circular(
        15,
      )));
}

BoxDecoration neumorphicBag(BuildContext context) {
  return BoxDecoration(
    color: Colors.deepOrange,
    boxShadow: [
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff000000).withOpacity(.20),
        offset: Offset(
          6,
          6,
        ),
      ),
      BoxShadow(
        blurRadius: 18,
        color: Color(0xff727bd9).withOpacity(.20),
        offset: Offset(
          -6,
          -6,
        ),
      ),
    ],
    borderRadius: BorderRadius.all(
      Radius.circular(
        50,
      ),
    ),
  );
}

TextStyle inputBoxStyle(double fs) {
  return TextStyle(
    color: StyleColors.hintText,
    fontFamily: "ProductSans",
    fontWeight: FontWeight.bold,
    fontSize: fs,
  );
}

TextStyle profileStyle(double f) {
  return TextStyle(
    color: StyleColors.buttonColor,
    fontFamily: "ProductSans",
    fontWeight: FontWeight.bold,
    fontSize: f,
  );
}



