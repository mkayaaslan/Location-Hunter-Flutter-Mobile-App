import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:locationhunter/Log_in/register.dart';
import 'package:locationhunter/MySelf/main.dart';

import '../Models/Firebase/Uİnfo.dart';
import '../Service/auth.dart';
import 'Verify.dart';

class ControlPAge extends StatefulWidget {
  const ControlPAge({Key? key}) : super(key: key);

  @override
  State<ControlPAge> createState() => _ControlPAgeState();
}

class _ControlPAgeState extends State<ControlPAge> {


  Future<void> controlTheAccount() async {

    if(FirebaseAuth.instance.currentUser!.emailVerified){
      User? user = AuthService().currentUser;


      var reftest = FirebaseDatabase.instance.ref();
      await reftest.once().then((value) async {
        var gelenDegerler = value.snapshot.value as dynamic ;
        if(gelenDegerler != null){
          var  camePersonInfo = UInfo.fromJson(gelenDegerler);

          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyHomePage(camePersonInfo)));

        }else{
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Regester()));
        }

      });
    }else{
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Verify(FirebaseAuth.instance.currentUser!.email!) ));

    }
  }

  @override
  void initState() {
    controlTheAccount();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
