//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';
import 'firebaseQueries.dart';
import 'modals/user.dart';
class setUserName extends StatefulWidget {
  @override
  GoogleSignInAccount  googleSignInAccount;
  setUserName({this.googleSignInAccount});
  _setUserNameState createState() => _setUserNameState();
}

class _setUserNameState extends State<setUserName> {
  @override
  final _scaffoldKey=GlobalKey<ScaffoldState>();
  final _formKey=GlobalKey<FormState>();
  String username;
  DataBaseMethods dataBaseMethods=DataBaseMethods();
  User currentUser;
  //Future<QuerySnapshot> usernameresult;
  submitUsername()async{
    print("function call");
    final form=_formKey.currentState;
    if(form.validate()){
      form.save();
      Map<String,dynamic> userInfoMap={
        "emailId":widget.googleSignInAccount.email,
        "id":widget.googleSignInAccount.id,
        "profileurl":widget.googleSignInAccount.photoUrl,
        "username":username,
        "displayname":widget.googleSignInAccount.displayName,
      };
      dataBaseMethods.saveUserInfo(widget.googleSignInAccount,userInfoMap);

    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: basicColor,title: Text("Create Account Page",style: TextStyle(color: highlightingColor,fontSize: 20),),),
      body: Container(
        color: secondaryColor,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top:26.0),
                    child: Center(
                      child: Text("Set up a username",style: TextStyle(fontSize: 26.0),),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          validator: (val){
                            if(val.trim().length<5||val.isEmpty){
                              // ignore: missing_return
                              return "User name is very short";
                            }
                            else if(val.trim().length>15){
                              return "User name is very long";
                            }
                            else{
                              return null;
                            }
                          },
                          onSaved: (val)=> username=val,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 16.0),
                              hintText: "must be atleast 5 characters",
                              hintStyle: TextStyle(color: Colors.grey)
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: submitUsername,
                    child: Container(
                      height: 60.0,
                      width: 370.0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [basicColor,Colors.white70]
                          ),
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Center(
                        child: Text("proceed",style: TextStyle(color: highlightingColor,fontSize: 16.0,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
