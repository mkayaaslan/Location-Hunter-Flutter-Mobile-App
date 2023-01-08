class UGroups{
  String group_id;
  String? group_name;
  String group_pic;
  String create_time;


  UGroups(this.group_id, this.group_name, this.group_pic, this.create_time);

  factory UGroups.fromJson(Map<dynamic,dynamic> json){
    return UGroups(json["group_id"] as String, json["group_name"] as String?,json["group_pic"] as String ,json["create_time"] as String);
  }

}