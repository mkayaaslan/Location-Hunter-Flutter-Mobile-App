import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';

import '../Models/Firebase/GChat.dart';
import '../Models/Firebase/GUsers.dart';
import '../Models/Firebase/UGroups.dart';
import '../Models/Firebase/Uİnfo.dart';
import '../Service/Storage_Service.dart';
import '../Service/auth.dart';

class GroupChatScreen extends StatefulWidget {

  UGroups uGroups;
  UInfo userInfo;
  PanelController _pc;


  GroupChatScreen(this.uGroups, this.userInfo, this._pc);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  var chatTextController = TextEditingController();
  User? user = AuthService().currentUser;
  var saveMyChat = HashMap<dynamic,dynamic>();
  var wrottenMessage ;
  final Storage storage = Storage();
  var chatLength = 5;


  Future<void> saveMessage( String mesagge) async{


    var messageTime = DateTime.now().millisecondsSinceEpoch.toString();
    var uuid = Uuid();

    var messageId = uuid.v1();

    var  usersFromGroup = <GUsers>[];
    User? user = AuthService().currentUser;

    var reftest = FirebaseDatabase.instance.ref();
    reftest.once().then((value)  {

      var gelenDegerler = value.snapshot.value as dynamic ;

      if(gelenDegerler != null){

        gelenDegerler.forEach((key,nesne ) async {
          var gelenkisi = await GUsers.fromJson(nesne);

          usersFromGroup.add(gelenkisi);

          var refSaveMessagetoOwn = FirebaseDatabase.instance.ref();

          saveMyChat["send_time"]=messageTime;
          saveMyChat["send_id"]=widget.userInfo.user_id;
          saveMyChat["get_id"]=gelenkisi.group_user_id;
          saveMyChat["send_name"]="${widget.userInfo.user_name} ${widget.userInfo.user_surname}";
          saveMyChat["message"]=mesagge;
          saveMyChat["message_id"]=messageTime;

          refSaveMessagetoOwn.set(saveMyChat).then((value) {

          });

        });
      }


    });

  }


  @override
  Widget build(BuildContext context) {

    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;
    var reftest =  FirebaseDatabase.instance.ref();




    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );


    return Scaffold(

      resizeToAvoidBottomInset: true,

      body:
        Column(
          children: [

            GestureDetector(
              onTap: (){
                chatLength +=5;
              },
              child: Container(

                color: Colors.black12,
                child: Row(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:4.0,bottom: 4,left: 8),
                      child: FutureBuilder(
                          future:  storage.downloadURLForgroup(widget.uGroups.group_pic),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot){
                            if(snapshot.hasData){

                              return CircleAvatar(
                                radius:35, // Image radius
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

                    Padding(
                      padding: const EdgeInsets.only(right: 8.0,left: 8),
                      child: SizedBox(
                        width:screanWidth -100 ,
                        child: widget.uGroups.group_name == null? Text(" "):Text(widget.uGroups.group_name!),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Expanded(

              child: StreamBuilder

              <DatabaseEvent>(

              stream: reftest.onValue,

              builder: (context,AsyncSnapshot<DatabaseEvent> event){

                if(event.hasData){

                  var cameMessages = <GChat>[];
                  var cameValue = event.data!.snapshot.value as dynamic ;
                  if(cameValue != null){
                    cameValue.forEach((key,nesne) {

                      var cameMessage = GChat.fromJson(nesne);
                      cameMessages.add(cameMessage);

                    });
                    Comparator<GChat> sortedGroup= (y,x) => x.send_time.compareTo(y.send_time);
                    cameMessages.sort(sortedGroup);

                  }else{

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Text(" Write a Message "),

                        ],
                      ),
                    ) ;
                  }

                  return
                    ListView.builder(

                    reverse: true,
                      itemCount: cameMessages.length,
                      itemBuilder: (context,indeks){
                        var message= cameMessages[indeks];
                        return message.send_id.contains(widget.userInfo.user_id) ?
                            //My Chat

                          Container(

                            padding: ((){
                              if(message.message_id==cameMessages.last.message_id){
                                return EdgeInsets.only(top: 6,right: 8,left: 4);
                              }else{
                                if(message.message_id == cameMessages.first.message_id){
                                  return EdgeInsets.only(top: 2,right: 8,left: 4,bottom: 10);
                                }

                                if(cameMessages[indeks+1].send_id.contains(message.send_id)){
                                  return EdgeInsets.only(top: 0.8,right: 8,left: 4);
                                }else{
                                  return EdgeInsets.only(top: 3,right: 8,left: 4);
                                }
                              }
                            }()),
                            alignment: Alignment.centerRight,

                            child: Container(
                              margin: EdgeInsets.only(left: screanWidth/2.3),
                              padding: EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                color: Colors.greenAccent
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                ((){
                                  if(message.message_id==cameMessages.last.message_id){
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0,top: 4),
                                      child: Text(message.send_name,style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Colors.red
                                      ),),
                                    );
                                  }else{
                                    if(cameMessages[indeks+1].send_id.contains(message.send_id)){
                                      return SizedBox(
                                        height: 10,
                                          child: Text(""));
                                    }else{
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8.0,top: 4,bottom: 4),
                                        child: Text(message.send_name,style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: Colors.red
                                        ),),
                                      );
                                    }
                                  }
                                    }()),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0,right: 5,bottom: 4),
                                    child: Text(message.message,style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                      fontSize: 12,

                                    ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ):
                        // Others Chat
                        Container(

                          padding: ((){
                            if(message.message_id==cameMessages.last.message_id){
                              return EdgeInsets.only(top: 3,right: 4,left: 8);
                            }else{
                              if(message.message_id == cameMessages.first.message_id){
                                return EdgeInsets.only(top: 2,right: 4,left: 8,bottom: 10);
                              }
                              if(cameMessages[indeks+1].send_id.contains(message.send_id)){
                                return EdgeInsets.only(top: 0.8,right: 4,left: 8);
                              }else{
                                return EdgeInsets.only(top: 3,right: 4,left: 8);
                              }
                            }
                          }()),
                          alignment: Alignment.centerLeft,

                          child: Container(
                            margin: EdgeInsets.only(right: screanWidth/2.3),
                            padding: EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                color: Colors.grey
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                ((){
                                  if(message.message_id==cameMessages.last.message_id){
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0,top: 4,),
                                      child: Text(message.send_name,style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Colors.red
                                      ),),
                                    );
                                  }else{
                                    if(cameMessages[indeks+1].send_id.contains(message.send_id)){
                                      return Text(" ");
                                    }else{
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8.0,top: 4,bottom: 4),
                                        child: Text(message.send_name,style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: Colors.red
                                        ),),
                                      );
                                    }
                                  }
                                }()),

                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0,right: 5,bottom: 8),
                                  child: Text(message.message,style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,

                                  ),
                                  ),
                                ),



                              ],
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


            Container(

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 0.5,
                      color: Colors.white,
                    ),
                  ]
              ),
              margin: const EdgeInsets.all(1),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(

                    onPressed: (){

                      widget._pc.close();

                    },
                    tooltip: "Send Message",
                    child: const Icon(Icons.arrow_downward,color: Colors.blue,),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 8.0,left: 8),
                    child: SizedBox(
                      width:screanWidth -170 ,
                      child: TextField(

                        controller: chatTextController,
                        obscureText: false,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: "Message ",
                          hintStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                          ),

                        ),
                      ),
                    ),
                  ),

                  FloatingActionButton(

                    onPressed: (){


                      if(chatTextController.text.isNotEmpty){
                        wrottenMessage = chatTextController.text;
                        saveMessage(wrottenMessage);
                        chatTextController.clear();
                        chatLength +=1;
                      }


                    },
                    tooltip: "Send Message",
                    child: const Icon(Icons.send,color: Colors.blue,),
                  ),
                ],
              ),
            ),

          ],
        ),







    );
  }
}
