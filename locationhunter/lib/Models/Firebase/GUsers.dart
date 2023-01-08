
class GUsers{
  String group_user_id;
  String group_user_fullname;
  String group_user_username;
  String group_user_pic;
  double group_user_latitude;
  double  group_user_longitude;


  GUsers(this.group_user_id, this.group_user_fullname, this.group_user_username,
      this.group_user_pic, this.group_user_latitude, this.group_user_longitude);

  factory GUsers.fromJson(Map<dynamic,dynamic> json){
    return GUsers(json["group_user_id"] as String, json["group_user_fullname"] as String,json["group_user_username"] as String,
        json["group_user_pic"] as String,json["group_user_latitude"] as double,json["group_user_longitude"] as double);
  }

}