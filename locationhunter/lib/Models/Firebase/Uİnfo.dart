class UInfo{
  String user_id;
  String user_username;
  String user_pic;
  String user_eMail;
  String user_name;
  String user_surname;
  bool   user_using_account;


  UInfo(this.user_id, this.user_username, this.user_pic, this.user_eMail,
      this.user_name, this.user_surname, this.user_using_account);

  factory UInfo.fromJson(Map<dynamic,dynamic> json){
    return UInfo(json["user_id"] as String,json["user_username"] as String,json["user_pic"] as String ,
        json["user_eMail"] as String, json["user_name"] as String , json["user_surname"] as String,json["is_user_using_account"] as bool);
  }

}