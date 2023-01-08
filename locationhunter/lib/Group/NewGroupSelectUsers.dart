import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locationhunter/Friend/AddFriend.dart';
import 'package:locationhunter/Group/NewGroupFinal.dart';
import 'package:locationhunter/Models/Firebase/UFriends.dart';
import '../Models/Firebase/FriendRequestModel.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/auth.dart';

class NewGroupSelectUser extends StatefulWidget {
  const NewGroupSelectUser({Key? key}) : super(key: key);

  @override
  State<NewGroupSelectUser> createState() => _NewGroupSelectUserState();
}

class _NewGroupSelectUserState extends State<NewGroupSelectUser> {


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
      allreadyFriendsid.add(user!.uid);
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

                sendRequestPeople.add(gelenkisi.sendRequest);

              });
            }

          }).then((value) async {
            await Navigator.push(context,MaterialPageRoute(builder: (context)  => AddFriend(allreadyFriendsid,ownInfo!,getRequestPeople,sendRequestPeople)));

          });

        });
      });
    });

  }

  var toogle = <bool>[];
   var choosenFriends = <String>[];

  @override
  Widget build(BuildContext context) {

    User? user = AuthService().currentUser;
    var reftest2 = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text("New Group",style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )),
            Text("x/y Chosen",style: TextStyle(
              fontSize: 12,
            )),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){

            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
          stream: reftest2.onValue,
          builder: (context,event){
            if(event.hasData){
              var friendList = <UFriends>[];
              var cameValue = event.data!.snapshot.value as dynamic ;
              if(cameValue != null){
                cameValue.forEach((key,nesne) {
                  toogle.add(false);
                  var camefriend = UFriends.fromJson(nesne);
                  friendList.add(camefriend);
                });
              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text("There is no any Friend Add New Friends "),

                      GestureDetector(
                        onTap: (){
                          userFriends();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child:
                          Icon(Icons.person_add,
                          size:50,
                            color: Colors.green,
                            ),
                        ),
                      ),
                    ],
                  ),
                ) ;
              }
              return ListView.builder(
                itemCount: friendList.length,
                itemBuilder: (context,indeks){
                  var friend= friendList[indeks];
                  return
                      Card(
                        child: SizedBox(
                          height: 50,

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          ''),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(friend.friend_name,style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              Spacer(),

                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                    icon: toogle[indeks]
                                        ? Icon(Icons.check,
                                      color: Colors.green,)
                                        : Icon(
                                      Icons.add,
                                    ),
                                    onPressed: () {
                                      if(toogle[indeks] != true){

                                        setState(() {
                                          choosenFriends.contains(friendList);
                                          choosenFriends.add(friend.friend_id);
                                          toogle[indeks] = !toogle[indeks];

                                        });
                                      }else{
                                        setState(() {
                                          toogle[indeks] = !toogle[indeks];
                                          choosenFriends.removeWhere((item) => item == friend.friend_id);
                                        });

                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      );
                },
              );
            }else{
              return CircularProgressIndicator();
            }
          }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(choosenFriends.isEmpty){

            Fluttertoast.showToast(

                msg: "You have not choosen any friend to add group ",

                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.green);

          }else{
            Navigator.push(context,MaterialPageRoute(builder: (context) => NewGroupFinal(choosenFriends)));

          }
          print("fab add");
        },
        tooltip: "Add new Group or Friend",
        child: const Icon(Icons.arrow_right_alt),
      ),
    );
  }
}
