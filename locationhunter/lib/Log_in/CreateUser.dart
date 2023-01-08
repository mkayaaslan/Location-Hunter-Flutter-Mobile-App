import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locationhunter/Log_in/Verify.dart';
import 'package:locationhunter/Log_in/register.dart';
import '../Service/auth.dart';


class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);



  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {


  var eMailTfController = TextEditingController();
  var passwordTfController = TextEditingController();
  var passwordagainTfController = TextEditingController();
  final AuthService _authservice = AuthService();


  Future<void> saveThePerson() async{
    if(passwordTfController.text== passwordagainTfController.text){
      _authservice.regesterUser(eMailTfController.text, passwordTfController.text).then((value) async {


        _authservice.currentUser!.sendEmailVerification();


        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            Verify(eMailTfController.text)));


        print("3");

      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
            msg: error.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.green);
      });
    }

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: eMailTfController,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,

              ),
              decoration: InputDecoration(

                hintText: "E-Mail ",
                hintStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                suffixIcon: Icon(Icons.email),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: TextField(
                controller: passwordTfController,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,

                ),
                decoration: InputDecoration(

                  hintText: "Password ",
                  hintStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  ),
                  suffixIcon: Icon(Icons.email),
                ),
              ),
            ),
            TextField(
              controller: passwordagainTfController,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,

              ),
              decoration: InputDecoration(
                hintText: "Password Again",
                hintStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                suffixIcon: Icon(Icons.email),
              ),
            ),


            ElevatedButton(
              child: Text("Verify"),
              onPressed: (){
                saveThePerson();

              },
            ),

          ],
        ),
      ),

    );
  }
}
