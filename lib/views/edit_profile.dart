import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopper/services/auth.dart';
import 'package:shopper/services/database.dart';
import 'package:shopper/shared/colors.dart';
import 'package:shopper/shared/loading.dart';
import 'package:shopper/shared/widgets.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();

  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();

  Database database = Database();
  Stream profileStream;

  bool isLoading = false;
  AuthMethods authMethods = AuthMethods();

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

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  updateProfile(url) async {
    Map<String, String> data = {
      "img": url,
      "fullName": fullNameTextEditingController.text,
      "shippingAddress": addressTextEditingController.text
    };
    database.updateProfile(data);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(color: Colors.white,child: spinKit),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Edit Profile",
                style: normalStyle(20),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: StreamBuilder(
                    stream: profileStream,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Hero(
                                          tag: 'pic',
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundImage: _image != null
                                                ? FileImage(_image)
                                                : NetworkImage(snapshot.data
                                                    .data()["img"]),
                                            backgroundColor: Theme.of(context).accentColor,
                                            child: IconButton(
                                                onPressed: () {
                                                  getImage();
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          decoration: neumorphicTextInput(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                  primaryColor:
                                                      StyleColors.buttonColor),
                                              child: TextFormField(
                                                style: normalStyle(15),
                                                textInputAction:
                                                    TextInputAction.go,
                                                controller:
                                                    fullNameTextEditingController,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: snapshot.data.data()["fullName"],
                                                    hintStyle: inputBoxStyle(12)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          decoration: neumorphicTextInput(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                  primaryColor:
                                                      StyleColors.buttonColor),
                                              child: TextFormField(
                                                enabled: true,
                                                style: normalStyle(13),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    addressTextEditingController,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        snapshot.data.data()[
                                                            "shippingAddress"],
                                                    hintStyle:
                                                        inputBoxStyle(12)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            authMethods.resetPassword(
                                                FirebaseAuth.instance
                                                    .currentUser.email);
                                            Scaffold.of(context)
                                                .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Theme.of(context).accentColor,
                                                  behavior: SnackBarBehavior.floating,
                                                  content: Text(
                                                  "Password Reset link has been sent to your email!"),
                                            ));
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Text(
                                              "Update Password?",
                                              style: normalStyle(17),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        Hero(
                                          tag: 'edit',
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: neumorphicButton(),
                                            child: FlatButton.icon(
                                              onPressed: () async {
                                                if (_image != null &&
                                                    fullNameTextEditingController
                                                        .text.isNotEmpty &&
                                                    addressTextEditingController
                                                        .text.isNotEmpty) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  await database
                                                      .uploadUserImage(_image);
                                                  final ref = FirebaseStorage
                                                      .instance
                                                      .ref()
                                                      .child("user_image")
                                                      .child(FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      .email +
                                                      '.jpg');
                                                  final url = await ref
                                                      .getDownloadURL();
                                                  updateProfile(url);
                                                  fullNameTextEditingController
                                                      .clear();
                                                  addressTextEditingController
                                                      .clear();
                                                } else {
                                                  setState(() {
                                                    isLoading = false;

                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor: Theme
                                                        .of(context)
                                                        .accentColor,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    content: Text(
                                                        "You have to select an image & fill all the fields"),
                                                  ));
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.update,
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
                                        SizedBox(height: 50,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Center(child: CircularProgressIndicator());
                    }),
              ),
            ),
          );
  }
}
