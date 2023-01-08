import 'package:flutter/material.dart';
import 'package:locationhunter/Models/Firebase/U%C4%B0nfo.dart';

import '../Service/Storage_Service.dart';




class FriendProfile extends StatefulWidget {
   UInfo uInfo;


   FriendProfile(this.uInfo, {super.key});

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {

  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[




            FutureBuilder(
                future:  storage.downloadURLForPerson(widget.uInfo.user_pic),
                builder: (BuildContext context,
                    AsyncSnapshot<String?> snapshot){
                  if(snapshot.hasData){

                    return CircleAvatar(
                      radius:screanWidth/4.3, // Image radius
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  }
                  if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData){

                    return CircularProgressIndicator();
                  }
                  return Container();
                }
            ),


            Column(
              children: [

                Padding(
                  padding: const EdgeInsets.only(top:15.0,bottom: 15.0),
                  child: Text(widget.uInfo.user_name + " " + widget.uInfo.user_username),
                ),
                Text(widget.uInfo.user_eMail),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(widget.uInfo.user_username),
                ),

              ],
            ),

          ],
        ),
      ),


    );
  }
}
