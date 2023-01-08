import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;

   Future<User?> signIn(String email, String password)  async{
    var user =await _auth.signInWithEmailAndPassword(email: email, password: password);
    return user.user;
  }

    signOut() async{
     return await _auth.signOut();
    }

    Future<User?> regesterUser( String email, String password) async{


     var user = await _auth.createUserWithEmailAndPassword(email: email, password: password).whenComplete(() => null);

     return user.user;

    }


}