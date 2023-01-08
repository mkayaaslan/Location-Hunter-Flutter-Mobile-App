
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'auth.dart';

class Storage {


  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String filePath)async {

    File file = File(filePath) ;
    User? user = AuthService().currentUser;


    try{

      await storage.ref('').putFile(file);

    }on firebase_core.FirebaseException catch(e){
      print(e);

    }
  }
  Future<void> uploadFileForGroup(String filePath, String uid)async {

    File file = File(filePath);

    try{

      await storage.ref('').putFile(file);

    }on firebase_core.FirebaseException catch(e){
      print(e);

    }
  }



  Future<String> downloadURLForPerson( String imageName ) async {


    String downloadURL = await storage.ref('').getDownloadURL();
    return downloadURL;

  }

  Future<String> downloadURLForgroup( String imageName ) async {

    String downloadURL = await storage.ref('').getDownloadURL();
    return downloadURL;

  }

}