import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'buildHomePage.dart';
//import 'appBarPage.dart';
import 'constants.dart';
import 'firebaseQueries.dart';
import 'modals/user.dart';
import 'setUserName.dart';
class signUpPage extends StatefulWidget {
  @override
  _signUpPageState createState() => _signUpPageState();
}
final GoogleSignIn gsignin=GoogleSignIn();
final String currentid=gsignin.currentUser.id;

class _signUpPageState extends State<signUpPage> {
  @override
  bool issigned=false;
  QuerySnapshot signedinusers;
  int getPageIndex=0;
  User currentuser;
  PageController pageController=new PageController();
  void initState() {
    super.initState();
    gsignin.onCurrentUserChanged.listen((gsigninAccount) {
      controlsignin(gsigninAccount);
    }, onError: (gError) {
      print("errror occur" + gError.toString());
    });
    gsignin.signInSilently(suppressErrors: false).then((gsigninAccount) {
      controlsignin(gsigninAccount);
    }).catchError((gError) {
      print("error" + gError.toString());
    });
  }
  DataBaseMethods dataBaseMethods=new DataBaseMethods();
  controlsignin(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      Map<String,dynamic> userInfoMap={
        "emailId":signInAccount.email,
        "id":signInAccount.id,
        "profileurl":signInAccount.photoUrl,
        "username":signInAccount.displayName,
        "displayname":signInAccount.displayName,
      };
      dataBaseMethods.saveUserInfo(signInAccount,userInfoMap);
      //Navigator.push(context,MaterialPageRoute(builder: (context)=>setUserName(googleSignInAccount:signInAccount)));
      DocumentSnapshot documentSnapshot=await Firestore.instance.collection("Users").document(signInAccount.id).get();
      User userinfo=User.fromDocument(documentSnapshot);
      setState(() {
        currentuser=userinfo;
        issigned = true;
      });
    }
    else {
      setState(() {
        issigned = false;
      });
    }
  }
  loginUser() {
    gsignin.signIn();
  }

  logoutUser() {
    gsignin.signOut();
  }
  Scaffold  buildSignInScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [basicColor,secondaryColor,],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(width:MediaQuery.of(context).size.width,alignment: Alignment.center,child: Text(appName,style: TextStyle(color: highlightingColor,fontSize: 40),)),
            GestureDetector(
              onTap: ()=> loginUser(),
              child: Container(width:270, height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:AssetImage("assets/Google.jpg"),
                  fit: BoxFit.cover
              ),
              ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget build(BuildContext context){
    if(issigned==true){
      return buildHomePage(gsignin,currentuser);
    }
    else{
      return buildSignInScreen();
    }
  }
}
