import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'firebaseQueries.dart';
import 'modals/user.dart';
import 'profChatPage.dart';
import 'selectiveChatsPage.dart';
import 'signUpPage.dart';
import 'widgets/postTileWidget.dart';
import 'widgets/postWidget.dart';
import 'pvtChatPage.dart';
class profilePage extends StatefulWidget {
  @override
  User currentuser;
  profilePage(this.currentuser);
  _profilePageState createState() => _profilePageState();
}
String acType="private";
class _profilePageState extends State<profilePage> {
  @override
  bool loading= false;
  int countpersonalPost=0;
  int countProfPosts=0;
  List<Post> postList=[];
  DataBaseMethods dataBaseMethods=DataBaseMethods();
  QuerySnapshot querySnapshotPosts;
  QuerySnapshot querySnapshotprfposts;
  QuerySnapshot querySnapshotFollowers;
  QuerySnapshot querySnapshotFollowing;
  QuerySnapshot querySnapshotProfFollowers;
  QuerySnapshot querySnapshotProfFollowing;
  getAllProfileInfo()async{
    setState(() {
      loading=true;
    });
    QuerySnapshot querySnapshotP=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("PersonalPosts").orderBy("timestamp",descending: true).getDocuments();
    QuerySnapshot querySnapshotPrf=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("ProfPosts").orderBy("timestamp",descending: true).getDocuments();
    QuerySnapshot querySnapshotFl=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Followers").getDocuments();
    QuerySnapshot querySnapshotFg=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Following").getDocuments();
    QuerySnapshot querySnapshotProfFl=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("ProfFollowers").getDocuments();
    QuerySnapshot querySnapshotProfFg=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("profFollowings").getDocuments();

    setState(() {
      querySnapshotprfposts=querySnapshotPrf;
      querySnapshotPosts=querySnapshotP;
      querySnapshotFollowers=querySnapshotFl;
      querySnapshotFollowing =querySnapshotFg;
      querySnapshotProfFollowers=querySnapshotProfFl;
      querySnapshotProfFollowing =querySnapshotProfFg;
      loading=false;
      countpersonalPost=querySnapshotP.documents.length;
      countProfPosts=querySnapshotPrf.documents.length;
      postList=querySnapshotP.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }
  void initState(){
    getAllProfileInfo();
  }
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: ListView(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(widget.currentuser.displayname,style: TextStyle(fontSize: 15),),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(widget.currentuser.url),fit: BoxFit.cover
                            ),
                            borderRadius: BorderRadius.circular(50)
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Posts",style: TextStyle(fontSize: 18),),
                        Text(acType=="private"?querySnapshotPosts!=null?"${querySnapshotPosts.documents.length}":"0":querySnapshotprfposts!=null?"${querySnapshotprfposts.documents.length}":"0",style: TextStyle(fontSize: 18),)
                      ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Followers",style: TextStyle(fontSize: 18),),
                        Text(acType=="private"?querySnapshotFollowers!=null?"${querySnapshotFollowers.documents.length}":"0":querySnapshotProfFollowers!=null?"${querySnapshotProfFollowers.documents.length}":"0",style: TextStyle(fontSize: 18),)
                      ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Following",style: TextStyle(fontSize: 18),),
                        Text(acType=="private"?querySnapshotFollowing!=null?"${querySnapshotFollowing.documents.length}":"0":querySnapshotProfFollowing!=null?"${querySnapshotProfFollowing.documents.length}":"0",style: TextStyle(fontSize: 18),)
                      ],),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed:(){
                    setState(() {
                      acType="private";
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> PvtChatPage()));},
                  child: Text("Private Messages",style: TextStyle(color: highlightingColor,fontSize: 15),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  color: basicColor,

                ),
                SizedBox(width: 5.0),
                RaisedButton(
                  onPressed:(){
                    setState(() {
                      acType="professional";
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfChatPage()));},
                  child: Text("Prof Messages",style: TextStyle(color: highlightingColor,fontSize: 15),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  color: basicColor,
                ),
                SizedBox(width: 5.0),
                RaisedButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>selectiveChatsPage()));
                    },
                  child: Text("selective",style: TextStyle(color: highlightingColor,fontSize: 15),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  color: basicColor,
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 2.0,color: basicColor)),child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
              GestureDetector(
                child: Text("Personal",style: TextStyle(fontSize: 20),),
                onTap: (){
                  setState(() {
                    acType="private";
                  });
                },
              ),
              GestureDetector(onTap: (){
                setState(() {
                  acType="professional";
                });
              },
                child: Text("Professional",style: TextStyle(fontSize: 20),),)
            ],
            ),
            ),
            Divider(color: Colors.black,),
            displayProfilePost(),
          ],
        )
      ),
    );
  }
  circularProgress(){
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black26),),
    );
  }
  displayProfilePost(){
    if(loading){
      return circularProgress();
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
    else if(acType=="private"){
      postList=querySnapshotPosts.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
      List<GridTile> gridTiles=[];
      postList.forEach((eachpost) {gridTiles.add(GridTile(child:postTile(eachpost)));
      });
      print(postList);
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(acType=="professional"){
      postList=querySnapshotprfposts.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
      List<GridTile> gridTiles=[];
      postList.forEach((eachpost) {gridTiles.add(GridTile(child:postTile(eachpost)));
      });
      print(postList);
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }
}
