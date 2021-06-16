import 'package:cloud_firestore/cloud_firestore.dart';
class User{
  final String id;
  final String displayname;
  final String username;
  final String url;
  final String email;
  //final int posts;
  User({
    this.id,
    this.displayname,
    this.username,
    this.url,
    this.email,
    //this.posts,
  });
  factory User.fromDocument(DocumentSnapshot doc){
    return User(
        id:doc.documentID,
        email:doc['emailId'],
        username: doc['username'],
        url: doc['profileurl'],
        displayname: doc['displayname'],
    );
  }
}