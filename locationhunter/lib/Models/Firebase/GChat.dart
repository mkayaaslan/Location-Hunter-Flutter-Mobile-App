class GChat{

  String  message_id;
  String  send_id;
  String  send_name;
  String  message;
  String send_time;


  GChat(this.send_id, this.send_name, this.message, this.message_id,
      this.send_time);

  factory GChat.fromJson(Map<dynamic,dynamic> json){
    return GChat(json["send_id"] as String, json["send_name"] as String,json["message"] as String,json["message_id"] as String,json["send_time"] as String);
  }

}