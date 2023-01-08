import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locationhunter/Log_in/CreateUser.dart';
import 'package:locationhunter/Log_in/Verify.dart';
import 'package:locationhunter/Log_in/register.dart';
import 'package:locationhunter/Models/UserMainInfo.dart';
import 'package:email_validator/email_validator.dart';
import 'package:locationhunter/Service/auth.dart';
import '../Friend/AddFriend.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../MySelf/main.dart';



class Log_in extends StatefulWidget {
   Log_in({Key? key}) : super(key: key);
  @override

  State<Log_in> createState() => _Log_inState();
}


class _Log_inState extends State<Log_in> {
  var eMailTfController = TextEditingController();
  var passwordTfController = TextEditingController();
  var updateUserInfo = HashMap<String,dynamic>();
  var formKey = GlobalKey<FormState>();
  var isEmailVerified = false;
  final AuthService _authService = AuthService();


  Future<void> tumKisiler() async {

    final User? user = AuthService().currentUser;

    var reftest =  FirebaseDatabase.instance.ref();
    reftest.once().then((value) {
      var gelenDegerler = value.snapshot.value as dynamic ;

      if(gelenDegerler != null){
        var gelenkisi = UInfo.fromJson(gelenDegerler);
        if(gelenkisi.user_using_account){

          showDialog(
              context: context,
              builder: (BuildContext context){

                return AlertDialog(
                  title: Text("This Account is using another device"),
                  content: Text("if You use the account more then one account, The app wiil not run properly"),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          await _authService.signOut();
                          Navigator.pop(context);
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Log_in()));
                        },
                        child: Text("cancel")),

                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage(gelenkisi)),
                              (Route<dynamic> route) => false,

                        );
                      },
                      child: Text("Sign in"),
                  ),
                  ],


                );
              }

          );

        }else{
          var reftest = FirebaseDatabase.instance.ref();

          updateUserInfo["is_user_using_account"] = true;

          reftest.update(updateUserInfo).then((value) async {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(gelenkisi)));

        });
        }

      }else{
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Regester()));
      }


    });
  }

  @override
  void initState() {
    if(FirebaseAuth.instance.currentUser != null){
      tumKisiler();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;
    AuthService _authService = AuthService();


    return Scaffold(

      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: screanWidth/19,right: screanWidth/19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key:formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: eMailTfController,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                      ),
                      validator: (cameEMail){

                        if(cameEMail!.isEmpty){
                          return "Enter an E Mail";
                        }else{
                          final bool _isValid = EmailValidator.validate(cameEMail);
                          if(_isValid == true){
                            return null;

                          }else{
                            return "Enter a Valid E Mail" ;
                          }
                        }
                      },
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
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextFormField(
                        controller: passwordTfController,
                        obscureText: false,
                        maxLength: 10,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                        ),
                        validator: (camePassword){
                          if(camePassword!.isEmpty){
                            return"Enter a Password";
                          }else{
                            return null;
                          }

                        },
                        decoration: InputDecoration(
                          hintText: "Password ",
                          hintStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                          ),
                          suffixIcon: Icon(Icons.password),

                        ),
                      ),
                    ),
                  ],
                ),
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text("Sign in"),
                    onPressed: (){
                      bool reasonControl = formKey.currentState!.validate();
                      if(reasonControl == true){
                        _authService.signIn(eMailTfController.text, passwordTfController.text).then((value)  {

                          setState(()  {
                            isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
                            print(isEmailVerified);

                          });

                          if(isEmailVerified){
                            tumKisiler();
                          }else{
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  Verify(eMailTfController.text)));
                          }

                        }).onError((error, stackTrace) {

                          Fluttertoast.showToast(

                              msg: error.toString(),

                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.green);
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 58.0),
                    child: ElevatedButton(
                      child: Text("Sign up"),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUser()));
                        },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
