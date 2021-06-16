import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';
import 'modals/user.dart';
import 'notificationPage.dart';
import 'postsPage.dart';
import 'profilePage.dart';
import 'searchPage.dart';
import 'uploadPost.dart';
class buildHomePage extends StatefulWidget {
  @override
  User currentuser;
  GoogleSignIn googleSignIn;
  buildHomePage(this.googleSignIn,this.currentuser);
  _buildHomePageState createState() => _buildHomePageState();
}
class _buildHomePageState extends State<buildHomePage> {
  @override
  int getPageIndex=0;
  PageController pageController=new PageController();
  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex=pageIndex;
    });
  }
  void initState(){
    print(widget.currentuser.url);
  }
  void dispose(){
    pageController.dispose();
    super.dispose();
  }
  onTapPageChanges(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut,);
  }
  logoutuser(){
    widget.googleSignIn.signOut();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName,),
      actions: <Widget>[GestureDetector(onTap: ()=>logoutuser(),child: Icon(Icons.exit_to_app))],),
      body: Container(
        child: PageView(
          children: <Widget>[
            postsPage(),
            notificationPage(),
            uploadPost(widget.currentuser),
            searchPage(),
            profilePage(widget.currentuser),
          ],
          controller: pageController,
          onPageChanged: whenPageChanges,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapPageChanges,
        activeColor: highlightingColor,
        inactiveColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(icon: Icon(Icons.file_upload)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.person))
        ],
      ),
    );
  }
}
