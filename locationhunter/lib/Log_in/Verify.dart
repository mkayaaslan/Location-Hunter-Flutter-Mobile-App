

import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:locationhunter/Log_in/log_in.dart';
import 'package:locationhunter/Log_in/register.dart';
import 'package:locationhunter/Models/Firebase/UFriends.dart';

import '../Models/UserMainInfo.dart';
import '../Service/auth.dart';

class Verify extends StatefulWidget {

  String eMAil;


  Verify(this.eMAil);

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {

  EmailAuth emailAuth =  new EmailAuth(sessionName: "Sample session");
  final User? user = AuthService().currentUser;
  var eMailTfController = TextEditingController();
  var passwordTfController = TextEditingController();
  var isEmailVerified = false;
  final AuthService _authService = AuthService();

  
  Future<void> verified() async{

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      print(isEmailVerified);

    });

  }

  @override
  void initState() {
    if(user!.emailVerified){
      isEmailVerified = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.eMAil),

          Padding(
            padding: const EdgeInsets.only(bottom: 18.0,top: 50),
            child: Text("Please Controll your E-Mail and click to link to verify your E-Mail"),
          ),

            ElevatedButton(
              child: Text("Control Verify"),
              onPressed: (){

                verified();
                if(isEmailVerified){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Regester()));
                }else{
                  const snackBar = SnackBar(
                    content: Text('E-mail is not Verified Please Control your E-Mail Again'),
                   /* action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),

                    */
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
            ElevatedButton(
              child: Text("Sign Out"),
              onPressed: () async {

               await _authService.signOut();
                Navigator.push(context,MaterialPageRoute(builder: (context) => Log_in()));

              },
            ),

          ],
        ),
      ),

    );

  }
}
