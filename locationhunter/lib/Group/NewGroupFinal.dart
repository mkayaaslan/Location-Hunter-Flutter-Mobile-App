
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locationhunter/Models/Firebase/UFriends.dart';
import 'package:locationhunter/Models/UserMainInfo.dart';
import 'package:uuid/uuid.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../MySelf/main.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';

class NewGroupFinal extends StatefulWidget {
  List<String> uFriends ;

  NewGroupFinal(this.uFriends);

  @override
  State<NewGroupFinal> createState() => _NewGroupFinalState();
}

class _NewGroupFinalState extends State<NewGroupFinal> {





  var choosenFriends = <UFriends>[];
  final Storage storage = Storage();
  var path ;
  File? pickedFile;
  var groupNameTfController = TextEditingController();


  void _getFromCamera() async {

    XFile? pickedfile = await ImagePicker().pickImage(source: ImageSource.camera);
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
      maxHeight: 1000,
      maxWidth: 1000,

    );

    if(croppedImage != null){

      setState(() {

        pickedFile = File(croppedImage.path);
        path = croppedImage.path;


      });
    }

  }



  @override
  Widget build(BuildContext context) {

    var groupHashmap = HashMap<dynamic,dynamic>();
    var usergroupHashmap = HashMap<dynamic,dynamic>();
    var ownGroupUserHashmap = HashMap<dynamic,dynamic>();
    var ownUsergroupHashmap = HashMap<dynamic,dynamic>();
    var groupFriendHashmap = HashMap<dynamic,dynamic>();


    bool isThereSavingPhoto = false;

    var uuid = Uuid();

    var groupId = uuid.v1();






    Future<void> saveGroup() async {


      storage.uploadFileForGroup(path,groupId).then((value) async {


      final User? user = AuthService().currentUser;

      var reftest =  await FirebaseDatabase.instance.ref();
      groupHashmap["group_id"]=groupId.toString();
      groupHashmap["group_name"]=groupNameTfController.text;
      groupHashmap["admin_id"]=user!.uid.toString();
      groupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();
      groupHashmap["group_pic"]=groupId;


      await reftest.set(groupHashmap).then((value)
      async {


          var refGetUserFriends = await FirebaseDatabase.instance.ref();

          refGetUserFriends.once().then((value) async{

            var gelenDegerler = value.snapshot.value as dynamic ;
            if(gelenDegerler != null){
              await gelenDegerler.forEach((key,nesne ) async {
                var  gelenkisi =  UFriends.fromJson(nesne);
                if(widget.uFriends.contains(gelenkisi.friend_id)){
                  choosenFriends.add(gelenkisi);
                }
              });
              for(var i=0;i<choosenFriends.length;i++){

                var reftestFriend = await FirebaseDatabase.instance.ref();

                print(choosenFriends[i].friend_pic);

                groupFriendHashmap["group_user_id"]=choosenFriends[i].friend_id.toString();
                groupFriendHashmap["group_user_fullname"]=choosenFriends[i].friend_name;
                groupFriendHashmap["group_user_pic"]=choosenFriends[i].friend_pic;
                groupFriendHashmap["group_user_username"]=choosenFriends[i].friend_username;
                groupFriendHashmap["group_user_latitude"]=1123123.1 ;
                groupFriendHashmap["group_user_longitude"]=1123123.1;


                await reftestFriend.set(groupFriendHashmap).then((value) => null);
                var refUserGroupsinfo = await FirebaseDatabase.instance.ref();

                usergroupHashmap["group_id"]=groupId.toString();
                usergroupHashmap["group_name"]=groupNameTfController.text;
                usergroupHashmap["group_pic"]=groupId;
                usergroupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();

                await refUserGroupsinfo.set(usergroupHashmap).then((value) => null);
              }
            }
          });



        var reftest =  FirebaseDatabase.instance.ref();
        reftest.once().then((value) async {
          Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;

          var gelenkisi = UInfo.fromJson(gelenDegerler);

          var reftestown = await  FirebaseDatabase.instance.ref();

          ownGroupUserHashmap["group_user_id"]=gelenkisi.user_id;
          ownGroupUserHashmap["group_user_username"]=gelenkisi.user_username;
          ownGroupUserHashmap["group_user_pic"]=gelenkisi.user_pic;
          ownGroupUserHashmap["group_user_fullname"]=gelenkisi.user_name + " " + gelenkisi.user_surname;
          ownGroupUserHashmap["group_user_latitude"]=1123123.1;
          ownGroupUserHashmap["group_user_longitude"]=1123123.1;


          await reftestown.set(ownGroupUserHashmap).then((value)=> null);
          var reftestuserGroup = await FirebaseDatabase.instance.ref();

          ownUsergroupHashmap["group_id"]=groupId.toString();
          ownUsergroupHashmap["group_name"]=groupNameTfController.text;
          ownUsergroupHashmap["group_pic"]=groupId;
          ownUsergroupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();

          await reftestuserGroup.set(ownUsergroupHashmap).then((value){
            /*Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(UserMainInfo((gelenkisi.user_name + " " + gelenkisi.user_surname),
                gelenkisi.user_pic, gelenkisi.user_username,user.uid))));

             */
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(gelenkisi)),
                  (Route<dynamic> route) => false,

            );
          });
        });
      });
      });
    }

    Future<void> saveGroupWithoutPicture() async {





        final User? user = AuthService().currentUser;

        var reftest =  await FirebaseDatabase.instance.ref();
        groupHashmap["group_id"]=groupId.toString();
        groupHashmap["group_name"]=groupNameTfController.text;
        groupHashmap["admin_id"]=user!.uid.toString();
        groupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();
        groupHashmap["group_pic"]="noImage.jpg";


        await reftest.set(groupHashmap).then((value)
        async {


          var refGetUserFriends = await FirebaseDatabase.instance.ref();

          refGetUserFriends.once().then((value) async{

            var gelenDegerler = value.snapshot.value as dynamic ;
            if(gelenDegerler != null){
              await gelenDegerler.forEach((key,nesne ) async {
                var  gelenkisi =  UFriends.fromJson(nesne);
                if(widget.uFriends.contains(gelenkisi.friend_id)){
                  choosenFriends.add(gelenkisi);
                }
              });
              for(var i=0;i<choosenFriends.length;i++){

                var reftestFriend = await FirebaseDatabase.instance.ref();


                groupFriendHashmap["group_user_id"]=choosenFriends[i].friend_id.toString();
                groupFriendHashmap["group_user_fullname"]=choosenFriends[i].friend_name;
                groupFriendHashmap["group_user_pic"]="noImage.jpg";
                groupFriendHashmap["group_user_username"]=choosenFriends[i].friend_username;
                groupFriendHashmap["group_user_latitude"]=1123123.1 ;
                groupFriendHashmap["group_user_longitude"]=1123123.1;


                await reftestFriend.set(groupFriendHashmap).then((value) => null);
                var refUserGroupsinfo = await FirebaseDatabase.instance.ref();

                usergroupHashmap["group_id"]=groupId.toString();
                usergroupHashmap["group_name"]=groupNameTfController.text;
                usergroupHashmap["group_pic"]="noImage.jpg";
                usergroupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();

                await refUserGroupsinfo.set(usergroupHashmap).then((value) => null);
              }
            }
          });



          var reftest =  FirebaseDatabase.instance.ref();
          reftest.once().then((value) async {
            Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;

            var gelenkisi = UInfo.fromJson(gelenDegerler);

            var reftestown = await  FirebaseDatabase.instance.ref();

            ownGroupUserHashmap["group_user_id"]=gelenkisi.user_id;
            ownGroupUserHashmap["group_user_username"]=gelenkisi.user_username;
            ownGroupUserHashmap["group_user_pic"]=gelenkisi.user_pic;
            ownGroupUserHashmap["group_user_fullname"]=gelenkisi.user_name + " " + gelenkisi.user_surname;
            ownGroupUserHashmap["group_user_latitude"]=1123123.1;
            ownGroupUserHashmap["group_user_longitude"]=1123123.1;


            await reftestown.set(ownGroupUserHashmap).then((value)=> null);
            var reftestuserGroup = await FirebaseDatabase.instance.ref();

            ownUsergroupHashmap["group_id"]=groupId.toString();
            ownUsergroupHashmap["group_name"]=groupNameTfController.text;
            ownUsergroupHashmap["group_pic"]="noImage.jpg";
            ownUsergroupHashmap["create_time"]=DateTime.now().millisecondsSinceEpoch.toString();

            await reftestuserGroup.set(ownUsergroupHashmap).then((value){
              /*Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(UserMainInfo((gelenkisi.user_name + " " + gelenkisi.user_surname),
                gelenkisi.user_pic, gelenkisi.user_username,user.uid))));

             */
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(gelenkisi)),
                    (Route<dynamic> route) => false,

              );
            });
          });
        });

    }

    return Scaffold(
        appBar: AppBar(
        title: Column(
        children: const [
        Text("New Group",style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold
         )),
        Text("add subject",style: TextStyle(
        fontSize: 12,
        )),
        ],
        ),
    centerTitle: true,
        ),
      body: Center(
        child: Column(

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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28.0),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 3.0,

                        ),
                        image: DecorationImage(
                            image: FileImage(
                                File(pickedFile!.path.toString())
                            ),
                            fit: BoxFit.fill
                        ),
                      ),
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28.0),
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
                  ),
                );
              }

            }()),
            TextField(
              controller: groupNameTfController,
              autofocus: true,
              style: TextStyle(
                color: Colors.green,

                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: "Group Name",
                hintStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
                suffixIcon: Icon(Icons.group),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(path != null ){
            if(groupNameTfController.text.isNotEmpty){
              saveGroup();
            }else{
              Fluttertoast.showToast(

                  msg: "Please Enter a Group Name",

                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.green);
            }

          }else {
            if(groupNameTfController.text.isNotEmpty){
              saveGroupWithoutPicture();

            }else{
              Fluttertoast.showToast(

                  msg: "Please Enter a Group Name",

                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.green);
            }
          }
        },
        tooltip: "Add new Group or Friend",
        child: const Icon(Icons.check_circle_rounded),
      ),

    );
  }
}
