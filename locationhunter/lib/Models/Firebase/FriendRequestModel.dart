class FriendRequestModel{

  String getRequest;
  String getName;
  String getUserPic;
  String getUsername;
  String sendRequest;
  String sendPic;
  String sendName;
  String sendUserName;


  FriendRequestModel(
      this.getRequest,
      this.getName,
      this.getUserPic,
      this.getUsername,
      this.sendRequest,
      this.sendPic,
      this.sendName,
      this.sendUserName);

  factory FriendRequestModel.fromJson(Map<dynamic,dynamic> json){
    return FriendRequestModel(json["getRequest"] as String,json["getName"] as String,json["getUserPic"] as String,json["getUsername"] as String,
        json["sendRequest"] as String,json["sendPic"] as String,json["sendName"] as String,json["sendUserName"] as String);
  }

}