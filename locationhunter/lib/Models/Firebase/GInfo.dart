class GInfo{
  String group_id;
  String group_name;
  String admin_id;
  String create_time;
  String group_pic;


  GInfo(this.group_id, this.group_name, this.admin_id, this.create_time,
      this.group_pic);

  factory GInfo.fromJson(Map<dynamic,dynamic> json){
    return GInfo(
        json["group_id"] as String, json["group_name"] as String,json["admin_id"] as String,
        json["create_time"] as String, json["group_pic"] as String);
  }

}