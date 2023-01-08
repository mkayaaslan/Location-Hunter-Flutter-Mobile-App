import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:locationhunter/Friend/FriendProfile.dart';
import 'package:locationhunter/Models/Firebase/FriendRequestModel.dart';
import '../Models/Firebase/UFriends.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';

class FriendRequests extends StatefulWidget {

  @override
  State<FriendRequests> createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {

  final Storage storage = Storage();

  var toogle = <bool>[];
  var wrotenWord = "";

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


  @override
  Widget build(BuildContext context) {

    User? user = AuthService().currentUser;

    var reftest2 = FirebaseDatabase.instance.ref();
    var friendHashmap = HashMap<dynamic,dynamic>();
    var addownHashmap = HashMap<dynamic,dynamic>();

    Future<void> userFriends()  async {

      User? user = AuthService().currentUser;
      var allreadyFriendsid =<String>[];
      var reftest = await FirebaseDatabase.instance.ref();
      reftest.once().then((value) async {
        var gelenDegerler = value.snapshot.value as dynamic ;

        if(gelenDegerler != null){
          await gelenDegerler.forEach((key,nesne ) async {
            var  gelenkisi =  UFriends.fromJson(nesne);
            allreadyFriendsid.add(gelenkisi.friend_id);
            print("for each ${gelenkisi.friend_id}");
          });
        }
      }).then((value)
      {

      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: TextField(
          style: TextStyle(
            color: Colors.green,

            fontSize: 20,
          ),
          decoration: InputDecoration(
            hintText: "wrote friends name",
            hintStyle: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (searcWord){
            setState(() {
              print(wrotenWord);
              wrotenWord = searcWord;
            });
          },
        ),
      ),
      body: StreamBuilder
      <DatabaseEvent>(
          stream: reftest2.onValue,
          builder: (context,event){

            if(event.hasData){

              var friendList = <FriendRequestModel>[];
              var cameValue = event.data!.snapshot.value as dynamic ;

              if(cameValue != null){

                cameValue.forEach((key,nesne)  {
                  var camefriend = FriendRequestModel.fromJson(nesne);

                      toogle.add(false);
                      friendList.add(camefriend);

                });

              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(" There is no any new Notification"),

                    ],
                  ),
                ) ;
              }
              return
                ListView.builder(
                  itemCount: friendList.length,
                  itemBuilder: (context,indeks){
                    var friend= friendList[indeks];
                    return GestureDetector(

                      onTap:() {
                        goToFriendProfile(friend.sendRequest);
                      },
                      child: Card(
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:12.0),
                                child:   FutureBuilder(
                                    future:  storage.downloadURLForPerson(friend.sendPic),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String?> snapshot){
                                      if(snapshot.hasData){

                                        return CircleAvatar(
                                          radius:20, // Image radius
                                          backgroundImage: NetworkImage(snapshot.data!),
                                        );
                                      }
                                      if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData){

                                        return CircularProgressIndicator();
                                      }
                                      return Container();
                                    }
                                ),
                              ),Spacer(),

                              Text(friend.sendName,style: TextStyle(
                                fontWeight: FontWeight.bold,

                              ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: IconButton(
                                    icon: toogle[indeks]
                                        ? Icon(Icons.check,
                                      color: Colors.green,)
                                        : Icon(
                                      Icons.add,
                                    ),
                                    onPressed: () {

                                      if(toogle[indeks]!= true){
                                        var refforaddFriend = FirebaseDatabase.instance.ref();

                                        friendHashmap["friend_id"]=friend.sendRequest;
                                        friendHashmap["friend_name"]=friend.sendName;
                                        friendHashmap["friend_pic"]=friend.sendPic;
                                        friendHashmap["friend_username"]=friend.sendUserName;

                                        refforaddFriend.set(friendHashmap).then((value) {

                                          var reftest =  FirebaseDatabase.instance.ref();
                                          reftest.once().then((value) async {
                                            Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;

                                            var gelenkisi = UInfo.fromJson(gelenDegerler);

                                            var refforaddmyself = FirebaseDatabase.instance.ref();

                                            addownHashmap["friend_id"]=gelenkisi.user_id;
                                            addownHashmap["friend_name"]=gelenkisi.user_name + " "+ gelenkisi.user_surname;
                                            addownHashmap["friend_pic"]=gelenkisi.user_pic;
                                            addownHashmap["friend_username"]=gelenkisi.user_username;

                                            refforaddmyself.set(addownHashmap).then((value) {
                                              var reffordeleteRequest = FirebaseDatabase.instance.ref();

                                              reffordeleteRequest.remove().then((value) {
                                                var reffordeleteRequresttoUserown = FirebaseDatabase.instance.ref();
                                                reffordeleteRequresttoUserown.remove().then((value) {

                                                });
                                              }).then((value) {
                                                var reffordeletesendRequresttoUserown = FirebaseDatabase.instance.ref();

                                             reffordeletesendRequresttoUserown.remove().then((value) {
                                               setState(() {
                                                 toogle[indeks] = !toogle[indeks];
                                               });
                                             });
                                              });

                                            });
                                          });
                                        });

                                      }else{
                                        var refforaddFriend = FirebaseDatabase.instance.ref();
                                        var refforaddmyself = FirebaseDatabase.instance.ref();

                                        refforaddFriend.remove().then((value) {
                                          refforaddmyself.remove().then((value) {
                                            setState(() {
                                              toogle[indeks] = !toogle[indeks];
                                            });
                                          });
                                        });
                                      }

                                    }),
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
