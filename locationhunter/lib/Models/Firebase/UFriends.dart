class UFriends{

  String friend_id;
  String friend_name;
  String friend_pic;
  String friend_username;

  UFriends(
      this.friend_id, this.friend_name, this.friend_pic, this.friend_username);

  factory UFriends.fromJson(Map<dynamic,dynamic> json){
    return UFriends(json["friend_id"] as String, json["friend_name"] as String,json["friend_pic"] as String,json["friend_username"] as String);
  }

}