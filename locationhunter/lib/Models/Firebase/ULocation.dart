class ULocation{
  String latitude;
  String longitude;


  ULocation(this.latitude, this.longitude);

  factory ULocation.fromJson(Map<dynamic,dynamic> json){
    return ULocation(json["latitude"] as String, json["longitude"] as String);
  }

}