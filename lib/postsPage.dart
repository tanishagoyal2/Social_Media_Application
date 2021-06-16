import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'signUpPage.dart';
import 'widgets/postWidget.dart';
class postsPage extends StatefulWidget {
  @override
  _postsPageState createState() => _postsPageState();
}
int selectedIndex=0;
String selectedText="CloseFriends";
class _postsPageState extends State<postsPage> {
  @override
  Map<String,String> FollowingList={};
  List<Post> postList=[];
  bool loading=false;
  List<String> choice=["CloseFriends","Friends","Acquaintance","Following","All"];
  List<String> showPostOf=["CF","F","AQ","Following"];
  Map<String,dynamic> postShowMap={"CF":["CF","F","AQ"],"F":["F","AQ"],"AQ":["AQ"],"Follower":["Follower","Following"]};
  List<String> idList=[];
  getListOfFollowing()async{
    setState(() {
      idList=[];
      FollowingList={};
      postList=[];
      loading=true;
    });
    QuerySnapshot querySnapshot=choice[selectedIndex]!="Following" && choice[selectedIndex]!="All"?
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Following").where("MyRelation",isEqualTo: showPostOf[selectedIndex],).getDocuments():
    choice[selectedIndex]=="Following"?await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("profFollowings").getDocuments():await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Following").getDocuments();
    if(querySnapshot.documents.length==0){
      setState(() {
        loading=false;
      });
    }
    print(querySnapshot.documents.length.toString());
    for(int i=0;i<querySnapshot.documents.length;i++){
     idList.add(querySnapshot.documents[i].data["id"].toString());
     FollowingList[querySnapshot.documents[i].data["id"].toString()]=querySnapshot.documents[i].data["OtherRelation"];
    }
    print("following list $FollowingList");
    print(idList);
    QuerySnapshot querySnapshot1=await Firestore.instance.collection("Posts").where("acId",whereIn: idList).getDocuments();
    for (int i=0;i<querySnapshot1.documents.length;i++){
      String relation=FollowingList[querySnapshot1.documents[i].data["acId"]];
      print(postShowMap[relation]);
      if(postShowMap[relation].contains(querySnapshot1.documents[i].data["PostFor"])){
        postList.add(Post.fromDocument(querySnapshot1.documents[i]));
      }
    }
    setState(() {
      FollowingList={};
      loading=false;
    });
  }
  void initState(){
    getListOfFollowing();
  }
  Widget choices() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: choice.length,
        itemBuilder: (context,index){
          return choiceTile(index);
        },
      ),
    );
  }
  Widget choiceTile(int index){
    return Padding(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: (){
          setState(() {
            selectedIndex=index;
            selectedText=choice[index];
            getListOfFollowing();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              choice[index],
              style: TextStyle(
                  color: selectedIndex==index?highlightingColor:Colors.grey,
                  fontSize: selectedIndex==index?16:14
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin:EdgeInsets.only(top: basicPadding/4),
              height: 3,
              width: 50,
              color: selectedIndex==index?highlightingColor:Colors.grey,
            )
          ],
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          choices(),
          displayProfilePost(),
        ],
      ),
    );
  }
  displayProfilePost(){
    if(loading){
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black26),),
      );
    }
    else if(postList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(30),
              child: Icon(Icons.photo_library,color: Colors.grey,size: 200.0,),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0),
              child: Text("no posts",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),),)
          ],
        ),
      );
    }
    else{
      return Column(
          children: postList
      );
    }
  }
}
class choices extends StatefulWidget {
  @override
  List<String> choice=["CloseFriends","Friends","Acquaintance","Following","All"];
  _choicesState createState() => _choicesState();
}

class _choicesState extends State<choices> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.choice.length,
        itemBuilder: (context,index){
          return choiceTile(index);
        },
      ),
    );
  }
Widget choiceTile(int index){
  return Padding(
    padding: EdgeInsets.all(8),
    child: GestureDetector(
      onTap: (){
        setState(() {
          selectedIndex=index;
          selectedText=widget.choice[index];
          //final postpage=postsPage();
          //postpage.getListOfFollowing();
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.choice[index],
            style: TextStyle(
                color: selectedIndex==index?highlightingColor:Colors.grey,
                fontSize: selectedIndex==index?16:14
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin:EdgeInsets.only(top: basicPadding/4),
            height: 3,
            width: 50,
            color: selectedIndex==index?highlightingColor:Colors.grey,
          )
        ],
      ),
    ),
  );
}
}
