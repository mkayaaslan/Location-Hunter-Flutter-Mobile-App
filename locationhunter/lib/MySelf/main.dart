
import 'dart:collection';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locationhunter/Friend/AddFriend.dart';
import 'package:locationhunter/Friend/FriendRequests.dart';
import 'package:locationhunter/Friend/Friends.dart';
import 'package:locationhunter/Group/Groups.dart';
import 'package:locationhunter/Group/NewGroupSelectUsers.dart';
import 'package:locationhunter/Log_in/ControlPage.dart';
import 'package:locationhunter/Log_in/Verify.dart';
import 'package:locationhunter/Log_in/log_in.dart';
import 'package:locationhunter/Models/Firebase/FriendRequestModel.dart';
import 'package:locationhunter/Models/Firebase/UGroups.dart';
import 'package:locationhunter/Models/Firebase/U%C4%B0nfo.dart';
import 'package:locationhunter/Service/auth.dart';
import '../Models/Firebase/UFriends.dart';
import '../Service/Storage_Service.dart';
import 'Profile.dart';
import 'Settings.dart';

void main() async{

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blueGrey
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( const MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home:  FirebaseAuth.instance.currentUser==null ? Log_in() :
          const ControlPAge()
    );
  }
}
class MyHomePage extends StatefulWidget {

  UInfo userInfo;


  MyHomePage(this.userInfo);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  late Future<String> getDataForGroupProfile;
  late AnimationController animationController;
  late Animation<double> scaleAnimationValue;
  late Animation<double> rotateAnimationValue;
  var updateUserInfo = HashMap<String,dynamic>();
  final Storage storage = Storage();
  bool fabStuation = false;
  bool navigate = false;


  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }



  Future<UInfo?> nameAndUserNAme()async{
    UInfo? camePersonInfo;

    User? user = AuthService().currentUser;


    var reftest = FirebaseDatabase.instance.ref();
     await reftest.once().then((value) {
      Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;

      camePersonInfo = UInfo.fromJson(gelenDegerler);

    });
    return camePersonInfo;
  }




  Future<void> userFriends()  async {


    setState(() {
      navigate = true;
    });
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

                sendRequestPeople.add(gelenkisi.getRequest);

              });
            }

          }).then((value) async {
            await Navigator.push(context,MaterialPageRoute(builder: (context)  => AddFriend(allreadyFriendsid,ownInfo!,getRequestPeople,sendRequestPeople)));

            setState(() {
              navigate = false;

            });

          });
        });
      });
    });
  }

  Future<void> goToProfile() async{
    setState(() {
      navigate = true;

    });
    User? user = AuthService().currentUser;
    var reftest =  FirebaseDatabase.instance.ref();
    reftest.once().then((value) {

      Map<dynamic, dynamic> gelenDegerler = value.snapshot.value as Map ;
      var gelenkisi = UInfo.fromJson(gelenDegerler);


      Navigator.pop(context);
      Navigator.push(context,MaterialPageRoute(builder: (context) => Profile(gelenkisi)));

      });
  }

  @override
  void initState() {
    super.initState();

    User? user = AuthService().currentUser;
    getDataForGroupProfile = storage.downloadURLForPerson(user!.uid);

    FirebaseDatabase.instance.setLoggingEnabled(true);

    animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    scaleAnimationValue = Tween(begin: 0.0, end: 1.0).animate(animationController)..addListener(() {
      setState(() {});
    });

    rotateAnimationValue = Tween(begin: 0.0, end: pi /4).animate(animationController)..addListener(() {
      setState(() {});

    });

  }

  User? user = AuthService().currentUser;
  @override
  Widget build(BuildContext context) {

    User? user = AuthService().currentUser;
    var reftest2 = FirebaseDatabase.instance.ref();
    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;
    var screenwith = screanWidth/3;
    var screenheight= screanHeight/8;
    AuthService _authService = AuthService();


    return navigate?  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    ) :SafeArea(
      child: Scaffold(

      body:
      NestedScrollView(

        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(

            backgroundColor: Colors.blueGrey,
            floating: true,
            snap: true,
            title: Text("Location Hunter"),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: (){

                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  FriendRequests()));
                },
                icon: const Icon(Icons.notifications_active),
              ),
            ],
            leading: Builder(
              builder: (BuildContext context) {

                return GestureDetector(
                  onTap: (){
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                  padding: const EdgeInsets.all(4.3),
                  child:  FutureBuilder(
                      future:  storage.downloadURLForPerson(widget.userInfo.user_pic),
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
                  ),
                );
              },
            ),
          ),
        ],



        body: StreamBuilder
        <DatabaseEvent>(
          stream: reftest2.onValue,
          builder: (context,event){
            if(event.hasData){

              var groupList = <UGroups>[];
              var cameValue = event.data!.snapshot.value as dynamic ;
              if(cameValue != null){
                cameValue.forEach((key,nesne) {

                  var cameGroup = UGroups.fromJson(nesne);
                  groupList.add(cameGroup);

                });

              }
              /*else if(event.connectionState == ConnectionState.waiting){
                return CircularProgressIndicator();

              } */
              else{

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      event.connectionState== ConnectionState.waiting? const CircularProgressIndicator():const Text(""),

                      const Text("There is no any group Add New Groups to See Where are your friends "),
                    ],
                  ),
                ) ;
              }
              return
                ListView.builder(
                itemCount: groupList.length,
                  itemBuilder: (context,indeks){
                    var group= groupList[indeks];
                    return GestureDetector(

                      onTap:() {


                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  Groups(group,screenwith.toInt(),screenheight.toInt(),widget.userInfo)));

                      },
                      child:
                              SizedBox(
                                height: screanHeight/9,
                                child: Card(

                                  borderOnForeground: true,
                                      color: Colors.white24,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.only(left:8.0),
                                            child: FutureBuilder(
                                                future:  storage.downloadURLForgroup(group.group_pic),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String> snapshot){
                                                  if(snapshot.hasData){

                                                    return CircleAvatar(
                                                      radius:screenheight/2.8, // Image radius
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

                                          group.group_name == null? Text(" "):Text(group.group_name!,style: TextStyle(
                                          fontWeight: FontWeight.bold,

                                        ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("online: 3"),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3.0),
                                                child: Text("ofline: 2"),
                                              ),
                                            ],
                                          ),
                                        )],
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
      ),
        drawer: Drawer(

          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder(
                        future:  storage.downloadURLForPerson(widget.userInfo.user_pic),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> snapshot){
                          if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){

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
                    Text(widget.userInfo.user_name + " " + widget.userInfo.user_surname,style: TextStyle(fontSize: 25),),
                    Text(widget.userInfo.user_username,style: TextStyle(fontSize: 18),),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                ),
              ),
              ListTile(
                title: Text("Profile"),
                leading: Icon(Icons.person_outline,color: Colors.blue,),
                onTap: (){
                 goToProfile();
                },
              ),
              ListTile(
                title: Text("Friends"),
                leading: Icon(Icons.people_alt_rounded,color: Colors.blue,),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Friends()));
                },
              ),
              ListTile(
                title: Text("Settings"),
                leading: const Icon(Icons.settings,color: Colors.blue,),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Settings()));
                },
              ),
              ListTile(
                title: const Text("Sign out",style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),),
                onTap: () async {

                  var reftest = FirebaseDatabase.instance.ref();

                  updateUserInfo["is_user_using_account"] = false;

                  reftest.update(updateUserInfo).then((value) async {

                    await _authService.signOut();
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (context) => Log_in()));
                  });

                },
              ),
            ],
          ),
        ),

        floatingActionButton:
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.scale(scale: scaleAnimationValue.value,
              child: FloatingActionButton (
                heroTag: "asdasdasdasc",

                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => NewGroupSelectUser() ));
                },

                tooltip: "Add new Group",
                child:
                const Icon(Icons.group_add,color: Colors.blue,),


              ),
            ),
            Transform.scale(scale: scaleAnimationValue.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: FloatingActionButton(
                  heroTag: "asvasvvsdfvsdv",
                  onPressed: (){

                   userFriends();
                  },
                  tooltip: "Add new Friend",
                  child: const Icon(Icons.person_add,color: Colors.blue,),
                ),
              ),
            ),
            Transform.rotate(angle: rotateAnimationValue.value,
              child: FloatingActionButton(
                heroTag: "asdascsdrbesvdas",
                onPressed: (){
                  if(fabStuation){
                    animationController.reverse();
                    fabStuation= false;
                  }else{
                    animationController.forward();
                    fabStuation= true;
                  }
                },
                tooltip: "",
                child: const Icon(Icons.add,color: Colors.blue,),
              ),
            ),
          ],
        ),
      ),
    );
     }
}
