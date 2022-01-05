import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database{
  Future uploadUserInfo(userMap) async{
    return await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).set(userMap);
  }

  getUserProfile () async{
    return FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots();
  }

  getElectronicsProducts () async{
  return FirebaseFirestore.instance.collection("products")
      .doc("categories").collection("electronics")
      .snapshots();
  }

  getShoesProducts () async{
    return FirebaseFirestore.instance.collection("products")
        .doc("categories").collection("shoes")
        .snapshots();
  }

  getHouseholdProducts () async{
    return FirebaseFirestore.instance.collection("products")
        .doc("categories").collection("household")
        .snapshots();
  }

  getGroceriesProducts () async{
    return FirebaseFirestore.instance.collection("products")
        .doc("categories").collection("groceries")
        .snapshots();
  }

  Future<void> updateProfile(Map data) async {
    return FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update(data);
  }

  uploadUserImage(File img) async{
    return await FirebaseStorage.instance.ref().child("user_image")
        .child(FirebaseAuth.instance.currentUser.email + '.jpg')
        .putFile(img).onComplete;
  }

  Future addItemToUserCart(cartMap) async{
    return await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).collection('item_cart').add(cartMap);
  }

  fetchItemFromUserCart() async{
    return FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).collection("item_cart")
        .snapshots();
  }

  Future addItemToUserFavorite(favoriteMap) async{
    return await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).collection('favorites').add(favoriteMap);
  }

  checkForSameItemInFav(pname) async{
    return FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).collection('favorites')
        .where(pname).get();
  }

  fetchItemFromUserFavorite() async{
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("favorites")
        .snapshots();
  }

  Future paymentUser(paymentMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('payment')
        .add(paymentMap);
  }

  getUserOrders() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('payment')
        .snapshots();
  }

  Future searchProductsElectronics(String search) async {
    return FirebaseFirestore.instance
        .collection('products')
        .doc('categories')
        .collection('electronics')
        .where("search", arrayContains: search)
        .snapshots();
  }
}