import 'dart:collection';
import 'dart:core';
import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locationhunter/Log_in/Verify.dart';
import 'package:locationhunter/Models/Firebase/U%C4%B0nfo.dart';
import 'package:locationhunter/Models/UserMainInfo.dart';
import 'package:locationhunter/Service/auth.dart';
import '../Models/Firebase/UFriends.dart';
import '../MySelf/main.dart';

class Regester extends StatefulWidget {
  const Regester({Key? key}) : super(key: key);

  @override
  State<Regester> createState() => _RegesterState();
}

class _RegesterState extends State<Regester> {


  final User? user = AuthService().currentUser;
  var eMailTfController = TextEditingController();
  var passwordTfController = TextEditingController();
  var passwordagainTfController = TextEditingController();
  var usernameTfController = TextEditingController();
  var nametfController = TextEditingController();
  var surnametfController = TextEditingController();
  var controlledusername = "          ";
  var userHashmap = HashMap<String,dynamic>();
  var userSearchHashmap = HashMap<String,dynamic>();
  final AuthService _authservice = AuthService();

  Future<void> createUser(String? uid) async{

    var reftest = FirebaseDatabase.instance.ref();


    userHashmap["user_id"]=uid.toString();
    userHashmap["user_username"]= usernameTfController.text;
    userHashmap["is_user_using_account"]= true;
    userHashmap["user_pic"]= "noImage.jpg";
    userHashmap["user_eMail"]= eMailTfController.text;
    userHashmap["user_name"]= nametfController.text;
    userHashmap["user_surname"]= surnametfController.text;

    await reftest.set(userHashmap).then((value) {
      print("2");

      var reftestforusersearch = FirebaseDatabase.instance.ref();

      userSearchHashmap["friend_id"]=uid.toString();
      userSearchHashmap["friend_name"]=nametfController.text + " " + surnametfController.text;
      userSearchHashmap["friend_username"]=usernameTfController.text;
      userSearchHashmap["friend_pic"]="noImage.jpg";

      reftestforusersearch.set(userSearchHashmap).then((value) {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(UInfo(user!.uid, usernameTfController.text, "noImage.jpg", eMailTfController.text, nametfController.text, surnametfController.text,true))),
              (Route<dynamic> route) => false,

        );

      });
    });
  }

  Future<void> controlTheUsername(String cameUsername)async{
    if(cameUsername.isEmpty){

      Fluttertoast.showToast(

          msg: "Please Enter a Valid Username",

          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.green);
      return;

    }else if(nametfController.text.isEmpty || surnametfController.text.isEmpty){

      Fluttertoast.showToast(

          msg: "Please Enter a Valid Name or Surname ",

          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.green);
      return;

    }

    var  uFriendsUsername= <String>[];

    var reftest = FirebaseDatabase.instance.ref();
   await reftest.onValue.listen((event)  async {
      var gelenDegerler = event.snapshot.value as dynamic ;

      if(gelenDegerler != null){
        await gelenDegerler.forEach((key,nesne ) async {
          var  gelenkisi =  UFriends.fromJson(nesne);
          uFriendsUsername.add(gelenkisi.friend_username);
        });
        if(uFriendsUsername.contains(cameUsername)){
          Fluttertoast.showToast(

              msg: "this username is Already used ",

              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.green);
          return;
        }else{
          createUser(user!.uid);
        }
      }else{
        createUser(user!.uid);
      }
    });

  }



  @override
  void initState() {
   eMailTfController.text =FirebaseAuth.instance.currentUser!.email.toString();


super.initState();
  }


  @override
  Widget build(BuildContext context) {


    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;


    return Scaffold(
      body: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding:  EdgeInsets.only(top: 13,bottom: 13),
            child: TextField(
              controller: eMailTfController,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
              ),
              readOnly: true,
              decoration: InputDecoration(
                filled: true,

                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                ),
                hintStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                suffixIcon: Icon(Icons.email),
              ),
            ),
          ),

          TextField(
            controller: usernameTfController,
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              hintText: "Username ",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),
              hintStyle: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
              suffixIcon: Icon(Icons.email),
            ),
          ),

          TextField(

            controller: nametfController,
            style: TextStyle(

              color: Colors.green,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              hintText: "Name",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))
              ),
              hintStyle: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
              suffixIcon: Icon(Icons.email),
            ),
          ),Padding(
            padding: EdgeInsets.only(top: 13,bottom: 13),
            child: TextField(
              controller: surnametfController,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: "Surname",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                ),
                hintStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                suffixIcon: Icon(Icons.email),
              ),
            ),
          ),




          ElevatedButton(


            child: Text("     Save     "),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),

            onPressed: (){
              if(controlledusername != usernameTfController.text){
                controlledusername= usernameTfController.text;
                controlTheUsername(usernameTfController.text);
              }

            },

          ),



        ],
      ),

    );
  }
}
