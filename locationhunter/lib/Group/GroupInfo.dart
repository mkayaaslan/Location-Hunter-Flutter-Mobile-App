import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:locationhunter/Models/Firebase/GInfo.dart';
import 'package:locationhunter/Models/Firebase/GUsers.dart';
import '../Service/Storage_Service.dart';


class GroupInfo extends StatefulWidget {

  GInfo groupInfo;

  GroupInfo(this.groupInfo, {super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {

  final Storage storage = Storage();


  @override
  Widget build(BuildContext context) {
    var reftest2 = FirebaseDatabase.instance.ref();

    var mediaInfo = MediaQuery.of(context);
    final double screanHeight = mediaInfo.size.height;
    final double screanWidth = mediaInfo.size.width;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:  EdgeInsets.only(left: 1.0),
          child:  Text("Profile"),
        ),
        centerTitle: true,

      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: FutureBuilder(
                  future:  storage.downloadURLForgroup(widget.groupInfo.group_pic),
                  builder: (BuildContext context,
                      AsyncSnapshot<String?> snapshot){
                    if(snapshot.hasData){

                      return CircleAvatar(
                        radius:screanWidth/3.8, // Image radius
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
              padding: const EdgeInsets.only(top: 3.0,bottom: 3),
              child: Container(
                height: 10,
                color: Colors.grey,
              ),
            ),

            Text(widget.groupInfo.group_name,style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,


            ),),

            Padding(
              padding: const EdgeInsets.only(top: 3.0,bottom: 3),
              child: Container(
                height: 10,
                color: Colors.grey,
              ),
            ),

            Column(
              children: [
                Text("Users"),

                StreamBuilder
                <DatabaseEvent>(
                    stream: reftest2.onValue,
                    builder: (context,event){
                      if(event.hasData){

                        var userList = <GUsers>[];
                        var cameValue = event.data!.snapshot.value as dynamic ;
                        if(cameValue != null){
                          cameValue.forEach((key,nesne) {

                            var cameGroup = GUsers.fromJson(nesne);
                            userList.add(cameGroup);

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

                                const Text("There is no any user in Group "),
                              ],
                            ),
                          ) ;
                        }
                        return
                          ListView.builder(
                            itemCount: userList.length,
                            itemBuilder: (context,indeks){
                              var friend= userList[indeks];
                              return GestureDetector(

                                onTap:() {


                                //  Navigator.push(context, MaterialPageRoute(builder: (context) =>  Groups(group,screenwith.toInt(),screenheight.toInt(),widget.userInfo)));

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
                                              future:  storage.downloadURLForPerson(friend.group_user_pic),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String> snapshot){
                                                if(snapshot.hasData){

                                                  return CircleAvatar(
                                                    radius:screanWidth/2.8, // Image radius
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

                                        Text(friend.group_user_fullname,style: TextStyle(
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
              ],
            ),

          ],
        ),

      ),

    );

  }
}
