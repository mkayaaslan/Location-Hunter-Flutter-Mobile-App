class Kisiler{
   String kisi_ad;
   String kisi_soyad;

   Kisiler(this.kisi_ad, this.kisi_soyad);

   factory Kisiler.fromJson(Map<dynamic,dynamic> json){
      return Kisiler(json["kisiler1"] as String, json["kisiler2"] as String);
   }

}