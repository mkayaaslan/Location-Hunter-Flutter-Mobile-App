import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:custom_marker/marker_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:locationhunter/Group/GroupChatScreen.dart';
import 'package:locationhunter/Group/GroupInfo.dart';
import 'package:locationhunter/Log_in/log_in.dart';
import 'package:locationhunter/Models/Firebase/GChat.dart';
import 'package:locationhunter/Models/Firebase/GInfo.dart';
import 'package:locationhunter/Models/Firebase/GUsers.dart';
import 'package:locationhunter/Models/Firebase/UGroups.dart';
import 'package:locationhunter/MySelf/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';
import 'dart:ui' as ui;
import 'dart:ui';

class Groups extends StatefulWidget {

  UGroups uGroups;
  int screenwithFromMain;
  int screenheightFromMain;
  UInfo userInfo;


  Groups(this.uGroups, this.screenwithFromMain, this.screenheightFromMain,
      this.userInfo);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {

  final Storage storage = Storage();
  bool isUserHere = true;
  var latitude= [];
  var longitude= [];
  var locationNumbers = 0;
  double enlem = 0.0;
  double boylam = 0.0;
  List<Marker> addMarker = <Marker>[];
  Completer<GoogleMapController> haritaKontrol = Completer();
  Location location = new Location();
  var chatTextController = TextEditingController();

  var saveMyChat = HashMap<dynamic,dynamic>();
  var saveFriendChat = HashMap<dynamic,dynamic>();
  late LocationData _locationData;
  var baslangicPosition = CameraPosition(target: LatLng(38.1244,33.1844276),zoom: 4,);





  Future<void> getFriendsLocationAddMarker()async{


    var  usersFromGroup = <GUsers>[];

    User? user = AuthService().currentUser;

    var reftest = FirebaseDatabase.instance.ref();
    reftest.onValue.listen((event)   {


      var gelenDegerler = event.snapshot.value as dynamic ;

        gelenDegerler.forEach((key,nesne ) async {
        var gelenkisi = await GUsers.fromJson(nesne);
        
        

        if(isUserHere){

        if(gelenkisi.group_user_id.toString().contains(user!.uid)){



            var gidilecekMarker = Marker(
                markerId: MarkerId(gelenkisi.group_user_id),
                position: LatLng(gelenkisi.group_user_latitude,gelenkisi.group_user_longitude),
                infoWindow: InfoWindow(title: gelenkisi.group_user_fullname,snippet: gelenkisi.group_user_username),
              icon: await MarkerIcon.downloadResizePictureCircle("",
                  size: widget.screenwithFromMain,
                  addBorder: true,
                  borderColor: Colors.white),
            );

            setState(() {
              addMarker.add(gidilecekMarker);
              reftest.onDisconnect().cancel();
            });


        }else{


            var gidilecekMarker = Marker(
                markerId: MarkerId(gelenkisi.group_user_id),
                position: LatLng(gelenkisi.group_user_latitude,gelenkisi.group_user_longitude),
                infoWindow: InfoWindow(title: gelenkisi.group_user_fullname,snippet: gelenkisi.group_user_username),
              icon: await MarkerIcon.downloadResizePictureCircle("",
                  size: widget.screenwithFromMain,
                  addBorder: true,
                  borderColor: Colors.red),

            );

            setState(() {
              addMarker.add(gidilecekMarker);

            });

        }
        }else{

        }
        usersFromGroup.add(gelenkisi);
      });
    });

  }

  Future<void> locationTry() async{

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    bool _backRoundserviceEnabled;

    _backRoundserviceEnabled = await location.isBackgroundModeEnabled();
    if (!_backRoundserviceEnabled) {

      _backRoundserviceEnabled = await location.enableBackgroundMode();
      if(!_backRoundserviceEnabled){
        Fluttertoast.showToast(

            msg: "if you dont enable using location on background you just use it open",

            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.green);
      }

    }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      enlem = _locationData.latitude!;
      boylam = _locationData.longitude!;
    });

  }

  Future<void> saveLocationtoFirebase(double latitude, double longitude) async{

    var newLocation = HashMap<String,dynamic>();
    User? user = AuthService().currentUser;
    var reftest = FirebaseDatabase.instance.ref();
    newLocation["group_user_latitude"]=latitude;
    newLocation["group_user_longitude"]=longitude;

    reftest.child(user!.uid).update(newLocation);

  }

  Future<void> saveMessage() async{

    var uuid = Uuid();

    var messageId = uuid.v1();

    var  usersFromGroup = <GUsers>[];
    // var mySelf =GUsers;
    User? user = AuthService().currentUser;

    var reftest = FirebaseDatabase.instance.ref();
    reftest.once().then((value)  {


      var gelenDegerler = value.snapshot.value as dynamic ;

      gelenDegerler.forEach((key,nesne ) async {
        var gelenkisi = await GUsers.fromJson(nesne);

        usersFromGroup.add(gelenkisi);

        if(isUserHere){

            var refSaveMessagetoOwn = FirebaseDatabase.instance.ref();

            saveMyChat["send_id"]=widget.userInfo.user_id;
            saveMyChat["send_name"]="${widget.userInfo.user_name} ${widget.userInfo.user_surname}";
            saveMyChat["message"]=chatTextController.text;
            saveMyChat["message_id"]=messageId.toString();

            refSaveMessagetoOwn.set(saveMyChat).then((value) {

            });

        }

      });
    });


  }


  Future<void> konumaGitInit()async{

    locationTry().then((value) async {
      GoogleMapController controller = await haritaKontrol.future;
      var gidilecekPosition = CameraPosition(target: LatLng(enlem,boylam),zoom: 14,);

      controller.animateCamera(CameraUpdate.newCameraPosition(gidilecekPosition));
    });
  }
  Future<void> konumaGit()async{


      GoogleMapController controller = await haritaKontrol.future;
      var gidilecekPosition = CameraPosition(target: LatLng(enlem,boylam),zoom: 14,);

      controller.animateCamera(CameraUpdate.newCameraPosition(gidilecekPosition));

  }


  Future<void> goToGroupInfo()async{

    User? user = AuthService().currentUser;


    var reftest = FirebaseDatabase.instance.ref();
    await reftest.once().then((value) async {
      var gelenDegerler = value.snapshot.value as dynamic;

      if(gelenDegerler != null){
        var cameGroupInfo = GInfo.fromJson(gelenDegerler);
        Navigator.push(context,MaterialPageRoute(builder: (context) =>  GroupInfo(cameGroupInfo)));


      }


    });
  }






  Future<bool>  backStagePushButton(BuildContext context) async{

    isUserHere = false;

    return true;
  }


  @override
  void initState() {

    widget.userInfo.user_surname.isEmpty? backStagePushButton(context) : null;
    getFriendsLocationAddMarker();
    konumaGitInit();

    super.initState();
  }

   PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    StreamSubscription<LocationData> locationSubscription;
    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;



    isUserHere ?  location.onLocationChanged.listen((LocationData currentLocation) {



      var lastLatitude  = 0.0;
      var lastLongitude  = 0.0;
      if(locationNumbers == 0){

        saveLocationtoFirebase(currentLocation.latitude!,currentLocation.longitude!).then((value) {
          latitude.add(currentLocation.latitude);
          longitude.add(currentLocation.longitude);
          locationNumbers++;

        });

        enlem= currentLocation.latitude!;
        boylam=currentLocation.longitude!;

      }else if(locationNumbers > 3){
        if(currentLocation.latitude != latitude[3] || currentLocation.longitude != longitude[3] ) {
          print(latitude.length);
          print(latitude);
          print(longitude);
          print(locationNumbers);

          for (int i = 0; i < 3; i++) {
            latitude[i] = latitude[i + 1];

            longitude[i] = longitude[i + 1];
          }
          latitude[3] = currentLocation.latitude;
          longitude[3] = currentLocation.longitude;

          for (var element in latitude) {
            lastLatitude += element;
          }
          for (var element in longitude) {
            lastLongitude += element;
          }

          lastLatitude = lastLatitude / 4.0;

          lastLongitude = lastLongitude / 4.0;
          locationNumbers++;

          saveLocationtoFirebase(lastLatitude, lastLongitude).then((value) {

          });
        }

      }else{
        latitude.add(currentLocation.latitude);
        longitude.add(currentLocation.longitude);
        for (var element in latitude) {
          lastLatitude += element;
        }
        for (var element in longitude) {
          lastLongitude += element;
        }

        lastLatitude = lastLatitude/latitude.length.toDouble();

        lastLongitude = lastLongitude/longitude.length.toDouble();
        locationNumbers++;

        saveLocationtoFirebase(lastLatitude,lastLongitude).then((value) {

        });

      }

    }):null;


    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title:  Column(
          children: [
            GestureDetector(
              onTap: (){

                goToGroupInfo();
              },
              child: widget.uGroups.group_name == null? Text(" "):Text(widget.uGroups.group_name!,style: TextStyle(
                color: Colors.white,
                fontSize: 20,

              ),),
            ),

          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              konumaGit();
            },
            
            icon: const Icon(Icons.location_pin,color: Colors.blue,),
          ),
        ],
        leading: GestureDetector(
          onTap: (){
            setState(() {
              isUserHere = false;
            });
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyHomePage(widget.userInfo)));
          },
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back)
              , onPressed: () {

                setState(() {
                  isUserHere = false;
                });
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyHomePage(widget.userInfo)));

              },
              ),
              FutureBuilder(
                  future:  storage.downloadURLForPerson(widget.userInfo.user_pic),
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
            ],
          ),
        ),
        leadingWidth: screanWidth/3,
      ),


      body:

      SlidingUpPanel(

        maxHeight: widget.screenheightFromMain*7/1,
        minHeight: screanHeight/14,

        controller: _pc,

        collapsed: _floatingCollapsed(screanWidth, screanHeight),
        panel: GroupChatScreen(widget.uGroups,widget.userInfo,_pc),


          body: WillPopScope(
            onWillPop: ()=> backStagePushButton(context),
            child: GoogleMap(

              mapType: MapType.normal,
              markers: Set<Marker>.of(addMarker),

              myLocationButtonEnabled: true,
              initialCameraPosition: baslangicPosition,
              onMapCreated: (GoogleMapController controller){

                haritaKontrol.complete(controller);
              },


            ),
          ),

        borderRadius: radius,
      ),
      


    );
  }

  Widget _floatingCollapsed(double screenwidth, double screanHeight){
    return GestureDetector(onTap: (){
      _pc.open();
    },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 2.0,
              color: Colors.grey,
            ),
          ],
          color: Colors.blueGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
        child: Center(
          child: Text(
            "click to open the Chat",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

}
