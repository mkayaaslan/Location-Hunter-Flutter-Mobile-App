
import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locationhunter/Models/Firebase/U%C4%B0nfo.dart';
import 'package:locationhunter/Models/Firebase/UFriends.dart';
import 'package:locationhunter/Models/Firebase/UGroups.dart';
import 'package:locationhunter/Models/UserMainInfo.dart';
import 'package:locationhunter/MySelf/main.dart';
import 'package:locationhunter/Service/Storage_Service.dart';
import '../Service/auth.dart';

class Profile extends StatefulWidget {

  UInfo uInfo;


  Profile(this.uInfo, {super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
    final Storage storage = Storage();
    var fileName ;
    var path ;
    File? pickedFile;

    User? user = AuthService().currentUser;
   // File? imageFile;


  void _getFromCamera() async {

    XFile? pickedfile = await ImagePicker().pickImage(source: ImageSource.camera,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 100,
    );
    cropImage(pickedfile!.path);
    Navigator.pop(context);

  }
    void _getFromGalery() async {

      XFile? pickedfile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        maxHeight: 1000,
        maxWidth: 1000,
        imageQuality: 100,
      );
      cropImage(pickedfile!.path);
      print(pickedfile);
      Navigator.pop(context);

    }

    void cropImage(filePath) async{

    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath:filePath,
      maxHeight: 400,
      maxWidth: 400,

    );

    if(croppedImage != null){

      setState(() {

        pickedFile = File(croppedImage.path);
        path = croppedImage.path;


      });
    }

    }


  Future<void> saveTheProfilePhoto()async{

    var uInfoProfileChange = HashMap<String,dynamic>();
    var uFriendsProfileChange = HashMap<String,dynamic>();
    var uGroupProfileChange = HashMap<String,dynamic>();
    var uSearchProfileChange = HashMap<String,dynamic>();


     await storage.uploadFile(path).then((value) async {
      User? user = AuthService().currentUser;
      var refChangeUInfoImage = await FirebaseDatabase.instance.ref();

      uInfoProfileChange["user_pic"]= user!.uid;
     await refChangeUInfoImage.update(uInfoProfileChange).then((value)  async {
        var refChangeUserSearchImage =  FirebaseDatabase.instance.ref();
        uSearchProfileChange["friend_pic"]= user.uid;

        await refChangeUserSearchImage.update(uSearchProfileChange).then((value) async {


          var refGetOwnFriends = FirebaseDatabase.instance.ref();
          await refGetOwnFriends.once().then((value) async {


            var gelenDegerler = value.snapshot.value as dynamic ;
            if(gelenDegerler != null){
              gelenDegerler.forEach((key,nesne ) async {
                var cameFriend =  UFriends.fromJson(nesne);
                var refChangeUserFriendsImage = FirebaseDatabase.instance.ref();

                uFriendsProfileChange["friend_pic"] = user.uid;

                await refChangeUserFriendsImage.update(uFriendsProfileChange).then((value) {

                });

              });

            }

          }).then((value) async {
            var refGetOwnGroups = FirebaseDatabase.instance.ref();
            await refGetOwnGroups.once().then((value) async {

              var gelenDegerler = value.snapshot.value as dynamic ;

              if(gelenDegerler != null){
                await gelenDegerler.forEach((key,nesne ) async {
                  var cameGroup = await UGroups.fromJson(nesne);

                  var refChangeUserGroupsImage = FirebaseDatabase.instance.ref();

                  uGroupProfileChange["group_user_pic"] = user.uid;

                  await refChangeUserGroupsImage.update(uGroupProfileChange).then((value) async {


                  });
                });
              }

            });

          });

        });

      });

    });

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("pictures/img.png"),
          fit: BoxFit.cover
        ),


      ),

      child:  Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Padding(
            padding:  EdgeInsets.only(left: 1.0),
            child:  Text("Profile"),
          ),
          centerTitle: true,

        ),
        body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ((){

                if(pickedFile != null){
                  return GestureDetector(
                    onTap: (){

                      showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("where you add image from"),
                              content: Text("içerik"),
                              actions: [
                                ElevatedButton(
                                    onPressed: (){
                                      _getFromCamera();
                                    },
                                    child: Text("camera")
                                ),
                                ElevatedButton(onPressed: (){
                                  _getFromGalery();
                                },
                                    child: Text("gallery"))

                              ],

                            );

                          });

                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: FileImage(
                                File(pickedFile!.path.toString())
                            ),
                            fit: BoxFit.fill
                        ),
                      ),
                    ),
                  );

                }else if (widget.uInfo.user_pic == widget.uInfo.user_id){

                  return GestureDetector(
                    onTap: (){
                      showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("where you add image from"),
                              content: Text("içerik"),
                              actions: [
                                ElevatedButton(
                                    onPressed: (){
                                      _getFromCamera();
                                    },
                                    child: Text("camera")
                                ),
                                ElevatedButton(onPressed: (){
                                  _getFromGalery();
                                },
                                    child: Text("gallery"))
                              ],

                            );

                          });
                    },
                    child: Container(
                      child: FutureBuilder(
                          future:  storage.downloadURLForPerson(widget.uInfo.user_pic),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot){
                            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){

                              return Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(snapshot.data.toString()),
                                      fit: BoxFit.fill
                                  ),
                                ),
                              );
                            }
                            if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData){

                              return CircularProgressIndicator();
                            }
                            return Container();
                          }
                      ),
                    ),
                  );
                }else{
                  return GestureDetector(
                    onTap: (){
                      showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("where you add image from"),
                              content: Text("içerik"),
                              actions: [
                                ElevatedButton(
                                    onPressed: (){
                                      _getFromCamera();
                                    },
                                    child: Text("camera")
                                ),
                                ElevatedButton(onPressed: (){
                                  _getFromGalery();
                                },
                                    child: Text("gallery"))

                              ],

                            );

                          });
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("pictures/no_image.png"),
                            fit: BoxFit.fill
                        ),
                      ),
                    ),
                  );
                }

              }()),

              Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top:15.0,bottom: 5.0),
                    child:
                    Card(

                      color: Colors.white54,
                      elevation: 25,

                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.black, width: 0.5),

                      ),

                      child: SizedBox(

                        height: 60,
                        child: Row(

                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(widget.uInfo.user_name + " " + widget.uInfo.user_surname,style: TextStyle(

                                  color: Colors.red

                              ),),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    borderOnForeground: true,
                    color: Colors.white70,
                    elevation: 15,

                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.black, width: 0.5),

                    ),

                    child: SizedBox(

                      height: 60,
                      child: Row(

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(widget.uInfo.user_eMail,style: TextStyle(

                                color: Colors.red

                            ),),
                          ),

                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child:
                    Card(
                      borderOnForeground: true,
                      color: Colors.white12,
                      elevation: 15,

                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.black, width: 0.8),

                      ),

                      child: SizedBox(

                        height: 60,
                        child: Row(

                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(widget.uInfo.user_username,style: TextStyle(

                                  color: Colors.red

                              ),),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),

            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){

            if(pickedFile != null && path != null ){

              saveTheProfilePhoto().then((value) {

                setState(() {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        MyHomePage((widget.uInfo))),
                        (Route<dynamic> route) => false,
                  );
                });
              });

            }else{
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) =>
                    MyHomePage(widget.uInfo)),
                    (Route<dynamic> route) => false,
              );
            }

          },

          tooltip: "Save",
          child: const Icon(Icons.save),
        ),

      ),
    );





  }
}
