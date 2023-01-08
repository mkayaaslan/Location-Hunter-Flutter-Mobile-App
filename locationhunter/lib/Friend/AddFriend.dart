import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:locationhunter/Models/Firebase/UFriends.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';

class AddFriend extends StatefulWidget {

 final List<String> friendsId;
 final UInfo userOwnInfo;
 final List<String> getRequests;
 final  List<String> sendRequests;


  const AddFriend(
      this.friendsId, this.userOwnInfo, this.getRequests, this.sendRequests, {super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();

}

class _AddFriendState extends State<AddFriend> {

  @override
  void initState() {

    super.initState();
  }

  var toogle = <bool>[];
  var wrotenWord = "";
  @override
  Widget build(BuildContext context) {

    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;

    User? user = AuthService().currentUser;

    var reftest2 = FirebaseDatabase.instance.ref();
    var friendHashmap = HashMap<dynamic,dynamic>();
    var addownHashmap = HashMap<dynamic,dynamic>();
    var addSendownHashmap = HashMap<dynamic,dynamic>();
    final Storage storage = Storage();

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

              var friendList = <UFriends>[];
              var cameValue = event.data!.snapshot.value as dynamic ;

              if(cameValue != null){

                  cameValue.forEach((key,nesne)  {
                    var camefriend = UFriends.fromJson(nesne);
                    if(!widget.friendsId.contains(camefriend.friend_id) && !widget.getRequests.contains(camefriend.friend_id) && !widget.sendRequests.contains(camefriend.friend_id)){
                      if((camefriend.friend_name.contains(wrotenWord) || camefriend.friend_username.contains(wrotenWord) ) ){
                        toogle.add(false);
                        friendList.add(camefriend);
                      }
                    }
                  });

              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("There is no any group Add New Groups to See Where are your friends "),
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
                        //Navigator.push(context, MaterialPageRoute(builder: (context) =>  Groups(group)));
                      },
                      child: Card(
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:12.0),
                                child:      FutureBuilder(
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
                              ),Spacer(),

                              Text(friend.friend_name,style: TextStyle(
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
                                        var refforsendRequrest = FirebaseDatabase.instance.ref();

                                              friendHashmap["sendRequest"] = widget.userOwnInfo.user_id;
                                              friendHashmap["sendPic"] = widget.userOwnInfo.user_pic;
                                              friendHashmap["sendName"] = widget.userOwnInfo.user_name + " " +widget.userOwnInfo.user_surname;
                                              friendHashmap["sendUserName"] = widget.userOwnInfo.user_username ;
                                              friendHashmap["getRequest"] = friend.friend_id;
                                              friendHashmap["getName"] = friend.friend_name;
                                              friendHashmap["getUsername"] = friend.friend_username;
                                              friendHashmap["getUserPic"] = friend.friend_pic;

                                              refforsendRequrest.set(friendHashmap).then((value) {
                                                var refforsendRequresttoUsersend = FirebaseDatabase.instance.ref();


                                                addownHashmap["sendRequest"] = widget.userOwnInfo.user_id;
                                                addownHashmap["sendPic"] = widget.userOwnInfo.user_pic;
                                                addownHashmap["sendName"] = widget.userOwnInfo.user_name + " " +widget.userOwnInfo.user_surname;
                                                addownHashmap["sendUserName"] = widget.userOwnInfo.user_username ;
                                                addownHashmap["getRequest"] = friend.friend_id;
                                                addownHashmap["getName"] = friend.friend_name;
                                                addownHashmap["getUsername"] = friend.friend_username;
                                                addownHashmap["getUserPic"] = friend.friend_pic;


                                                refforsendRequresttoUsersend.set(addownHashmap).then((value) {

                                                  var refforsendRequresttoUserown = FirebaseDatabase.instance.ref();


                                                  addSendownHashmap["sendRequest"] = widget.userOwnInfo.user_id;
                                                  addSendownHashmap["sendPic"] = widget.userOwnInfo.user_pic;
                                                  addSendownHashmap["sendName"] = widget.userOwnInfo.user_name + " " +widget.userOwnInfo.user_surname;
                                                  addSendownHashmap["sendUserName"] = widget.userOwnInfo.user_username ;
                                                  addSendownHashmap["getRequest"] = friend.friend_id;
                                                  addSendownHashmap["getName"] = friend.friend_name;
                                                  addSendownHashmap["getUsername"] = friend.friend_username;
                                                  addSendownHashmap["getUserPic"] = friend.friend_pic;

                                                  refforsendRequresttoUserown.set(addSendownHashmap).then((value) {
                                                    setState(() {
                                                      toogle[indeks] = !toogle[indeks];
                                                    });
                                                  });


                                                });

                                              });


                                      }else{
                                        var reffordeleteRequest = FirebaseDatabase.instance.ref();

                                        reffordeleteRequest.remove().then((value) {
                                          var reffordeleteRequresttoUserown = FirebaseDatabase.instance.ref();
                                          reffordeleteRequresttoUserown.remove().then((value) {
                                            var reffordeletesendRequresttoUserown = FirebaseDatabase.instance.ref();
                                           reffordeletesendRequresttoUserown.remove().then((value) {
                                             setState(() {
                                               toogle[indeks] = !toogle[indeks];
                                             });
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
