import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locationhunter/Friend/AddFriend.dart';
import 'package:locationhunter/Friend/FriendProfile.dart';

import '../Group/Groups.dart';
import '../Models/Firebase/FriendRequestModel.dart';
import '../Models/Firebase/UFriends.dart';
import '../Models/Firebase/UGroups.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {


  final Storage storage = Storage();


  Future<void> goToFriendProfile(String friendId) async {
    var reftest =  FirebaseDatabase.instance.ref();
    reftest.once().then((value) {

      var gelenDegerler = value.snapshot.value as dynamic ;

      if(gelenDegerler!= null){
        var gelenkisi = UInfo.fromJson(gelenDegerler);

        Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfile(gelenkisi)));
      }

    });

  }




  Future<void> userFriends()  async {

    User? user = AuthService().currentUser;
    var allreadyFriendsid =<String>[];
    UInfo? ownInfo;
    var sendRequestPeople =<String>[];
    var getRequestPeople =<String>[];



    var reftest = await FirebaseDatabase.instance.ref();
    reftest.once().then((value) async {
      var gelenDegerler = value.snapshot.value as dynamic ;

      if(gelenDegerler != null){
        await gelenDegerler.forEach((key,nesne ) async {
          var  gelenkisi =  UFriends.fromJson(nesne);
          allreadyFriendsid.add(gelenkisi.friend_id);
        });
      }

    }).then((value)
    async {
      var reftest =  await FirebaseDatabase.instance.ref();
      reftest.once().then((value) async {

        Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;
        var gelenkisi = UInfo.fromJson(gelenDegerler);

        ownInfo = gelenkisi;


      }).then((value)  async {
        var reftest =  await FirebaseDatabase.instance.ref();

        reftest.once().then((value) async {

          var gelenDegerler = value.snapshot.value as dynamic ;
          if(gelenDegerler != null) {

            await gelenDegerler.forEach((key, nesne) async {
              var gelenkisi = FriendRequestModel.fromJson(nesne);

              getRequestPeople.add(gelenkisi.sendRequest);

            });
          }
        }).then((value) async {
          var reftest =  await FirebaseDatabase.instance.ref();

          reftest.once().then((value) async {
            var gelenDegerler = value.snapshot.value as dynamic ;
            if(gelenDegerler != null) {

              await gelenDegerler.forEach((key, nesne) async {
                var gelenkisi = FriendRequestModel.fromJson(nesne);

                sendRequestPeople.add(gelenkisi.getRequest);

              });
            }

          }).then((value) async {
            await Navigator.push(context,MaterialPageRoute(builder: (context)  => AddFriend(allreadyFriendsid,ownInfo!,getRequestPeople,sendRequestPeople)));

          });

        });
      });
    });

  }



  @override
  Widget build(BuildContext context) {

    User? user = AuthService().currentUser;
    var reftest = FirebaseDatabase.instance.ref();

    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;


    return Scaffold(
      appBar: AppBar(
        title: Text("Friends"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){

            },
            icon: const Icon(Icons.search),

          ),
          IconButton(
            onPressed: (){
             userFriends();
            },
            icon: Icon(Icons.person_add),
          )
        ],
      ),
      body:  StreamBuilder
      <DatabaseEvent>(
          stream: reftest.onValue,
          builder: (context,event){
            if(event.hasData){
              var groupList = <UFriends>[];

              var cameValue = event.data!.snapshot.value as dynamic ;
              if(cameValue != null){
                cameValue.forEach((key,nesne) {

                  var cameGroup = UFriends.fromJson(nesne);
                  groupList.add(cameGroup);

                });

              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text("There is no any group Add New Groups to See Where are your friends "),
                    ],
                  ),
                ) ;
              }
              return
                ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context,indeks){
                    var friend= groupList[indeks];
                    return GestureDetector(

                      onTap:() {
                      goToFriendProfile(friend.friend_id);
                      },
                      child: Card(
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child:  FutureBuilder(
                                    future:  storage.downloadURLForPerson(friend.friend_pic),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String?> snapshot){
                                      if(snapshot.hasData){

                                        return CircleAvatar(
                                          radius:screanWidth/25, // Image radius
                                          backgroundImage: NetworkImage(snapshot.data!),
                                        );
                                      }
                                      if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData){

                                        return CircularProgressIndicator();
                                      }
                                      return Container();
                                    }
                                ),
                              ),
                              Spacer(),
                              Text(friend.friend_name,style: TextStyle(
                                fontWeight: FontWeight.bold,

                              ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  PopupMenuButton(
                                    child: Icon(Icons.more_vert),
                                    itemBuilder: (context) =>[
                                      PopupMenuItem(
                                        value: 1,
                                        child:Text("sil"),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child:Text("kaydet"),
                                      ),
                                    ],
                                    onSelected:(menuItemValue) {
                                      if(menuItemValue==1 ){
                                        showDialog(context: context,
                                          builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text("Sil"),
                                            content: Text("${friend.friend_name} adlı kullanıcı silinecek"),
                                            actions: [
                                              TextButton(
                                                child: Text("Sil"),
                                              onPressed: (){

                                                var refdeletefriendOwn = FirebaseDatabase.instance.ref();
                                                  refdeletefriendOwn.child(friend.friend_id).remove().then((value) {

                                                    var refdeleteFriendIt = FirebaseDatabase.instance.ref();
                                                    refdeleteFriendIt.remove().then((value) {
                                                      Fluttertoast.showToast(

                                                          msg: "${friend.friend_name} adlı Kullanıcı silindi",

                                                          toastLength: Toast.LENGTH_LONG,
                                                          gravity: ToastGravity.BOTTOM,
                                                          backgroundColor: Colors.red,
                                                          textColor: Colors.green);
                                                      Navigator.pop(context);
                                                    });
                                                  });

                                              },
                                              ),
                                              TextButton(
                                                child: Text("iptal"),
                                                onPressed: (){
                                                  Fluttertoast.showToast(

                                                      msg: "işlem iptal edildi",
                                                      toastLength: Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.BOTTOM,
                                                      backgroundColor: Colors.red,
                                                      textColor: Colors.green);
                                                  Navigator.pop(context);

                                                },
                                              ),
                                            ],
                                          );
                                          }
                                        );
                                      }
                                    },
                                  ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
            }else{
              return Center();
            }
          }
      ),

    );
  }
}
