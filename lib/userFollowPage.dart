import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatScreen.dart';
import 'constants.dart';
import 'firebaseQueries.dart';
import 'signUpPage.dart';
import 'widgets/postTileWidget.dart';
import 'widgets/postWidget.dart';
import 'profilePage.dart';
class userFollowPage extends StatefulWidget {
  @override
  String userId;
  String username;
  String url;
  String displayname;
  userFollowPage(this.userId,this.username,this.url,this.displayname);
  _userFollowPageState createState() => _userFollowPageState();
}
class _userFollowPageState extends State<userFollowPage> {
  @override
  bool loading= false;
  String owneractype=acType;  //TODO: From where this Actype is coming?
  int countpersonalPost=0;
  int countProfPosts=0;
  String acType1="private";
  List<Post> postList=[];
  DataBaseMethods dataBaseMethods=DataBaseMethods();
  QuerySnapshot querySnapshotPosts;
  QuerySnapshot querySnapshotprfposts;
  QuerySnapshot querySnapshotFollowers;
  QuerySnapshot querySnapshotFollowing;
  QuerySnapshot followrequestforPersonal;
  QuerySnapshot followrequestforProf;      //TODO: remove request here
  QuerySnapshot querySnapshotProfFollowers;
  QuerySnapshot querySnapshotProfFollowing;
  getAllProfileInfo()async{
    setState(() {
      loading=true;
    });
    QuerySnapshot querySnapshotP=await Firestore.instance.collection("Users").document(widget.userId).collection("PersonalPosts").orderBy("timestamp",descending: true).getDocuments();
    QuerySnapshot querySnapshotPrf=await Firestore.instance.collection("Users").document(widget.userId).collection("ProfPosts").orderBy("timestamp",descending: true).getDocuments();
    QuerySnapshot querySnapshotFl=await Firestore.instance.collection("Users").document(widget.userId).collection("Followers").getDocuments();  //pvt followers
    QuerySnapshot querySnapshotFg=await Firestore.instance.collection("Users").document(widget.userId).collection("Following").getDocuments();   //pvt followings
    QuerySnapshot querySnapshotpfr=await Firestore.instance.collection("Users").document(widget.userId).collection("Followers").where("id",isEqualTo: gsignin.currentUser.id).getDocuments();   //pvt follow request
    QuerySnapshot querySnapshotprfr=await Firestore.instance.collection("Users").document(widget.userId).collection("ProfFollowers").where("id",isEqualTo: gsignin.currentUser.id).getDocuments(); //prof follow request
    QuerySnapshot querySnapshotProfFl=await Firestore.instance.collection("Users").document(widget.userId).collection("ProfFollowers").getDocuments();
    QuerySnapshot querySnapshotProfFg=await Firestore.instance.collection("Users").document(widget.userId).collection("profFollowings").getDocuments();
    setState(() {
      followrequestforPersonal=querySnapshotpfr;
      followrequestforProf=querySnapshotprfr;
      querySnapshotProfFollowers=querySnapshotProfFl;
      querySnapshotProfFollowing =querySnapshotProfFg;
      querySnapshotprfposts=querySnapshotPrf;
      querySnapshotPosts=querySnapshotP;
      querySnapshotFollowers=querySnapshotFl;
      querySnapshotFollowing =querySnapshotFg;
      loading=false;
      countpersonalPost=querySnapshotP.documents.length;
      countProfPosts=querySnapshotPrf.documents.length;
      postList=querySnapshotP.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }
  void initState(){
    getAllProfileInfo();
    super.initState();
  }
  addUser(type){
    Navigator.pop(context);
    Map<String,dynamic> sendMap={
      "id":currentid,
      "For":type,
      "profileurl":gsignin.currentUser.photoUrl,
      "displayname":gsignin.currentUser.displayName,
      "ToFollow":acType1,
    };
    dataBaseMethods.sendFollowRequest(widget.userId, sendMap, gsignin.currentUser.id);
  }
  addUserInProfessionalAccount()async{
    Map<String,dynamic> datamap1={
      "MyRelation":"Follower",
      "OtherRelation":"Following",
      "displayname":gsignin.currentUser.displayName,
      "id":gsignin.currentUser.id,
      "profileurl":gsignin.currentUser.photoUrl,
    };
    Map<String,dynamic> datamap2={
      "MyRelation":"Following",
      "OtherRelation":"Follower",
      "displayname":widget.displayname,
      "id":widget.userId,
      "profileurl":widget.url
    };
    await Firestore.instance.collection("Users").document(widget.userId).collection("ProfFollowers").document(currentid).setData(datamap1);
    owneractype=="private"?await Firestore.instance.collection("Users").document(currentid).collection("Following").document(widget.userId.toString()+"pr").setData(datamap2):await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("profFollowings").document(widget.userId).setData(datamap2);
  }
  addUserInListAs(mcontext){
    return showDialog(context: mcontext, builder:(context)
    {
      return SimpleDialog(
        title: Text("Add As",),
        children: <Widget>[
          SimpleDialogOption(
            child: Text("As a Friend"),
            onPressed: () => addUser("F"),
          ),
          SimpleDialogOption(
            child: Text("As a Close Friend"),
            onPressed: () => addUser("CF"),
          ),
          SimpleDialogOption(
            child: Text("As a Acquaintance"),
            onPressed: () => addUser("AQ"),
          ),
          SimpleDialogOption(
            child: Text(
              "Cancel", style: TextStyle(color: Colors.black, fontSize: 15),),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("InstaGram"),),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(widget.displayname,style: TextStyle(fontSize: 15),),
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(widget.url),fit: BoxFit.cover
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
                            Text(acType1=="private"?querySnapshotPosts!=null?"${querySnapshotPosts.documents.length}":"0":querySnapshotprfposts!=null?"${querySnapshotprfposts.documents.length}":"0",style: TextStyle(fontSize: 18),)
                          ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Followers",style: TextStyle(fontSize: 18),),
                            Text(acType1=="private"?querySnapshotFollowers!=null?"${querySnapshotFollowers.documents.length}":"0":querySnapshotProfFollowers!=null?"${querySnapshotProfFollowers.documents.length}":"0",style: TextStyle(fontSize: 18),)
                          ],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Following",style: TextStyle(fontSize: 18),),
                            Text(acType1=="private"?querySnapshotFollowing!=null?"${querySnapshotFollowing.documents.length}":"0":querySnapshotProfFollowing!=null?"${querySnapshotProfFollowing.documents.length}":"0",style: TextStyle(fontSize: 18),)
                          ],),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  child: owneractype=="private"?
                  acType1=="private"?
                  followrequestforPersonal.documents.length==0?
                  RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: Text("Add to",style: TextStyle(color: Colors.black,fontSize: 20),),
                    color: Colors.blueAccent,
                    onPressed: ()=>addUserInListAs(context),    //private wants to follow private account
                  )
                      :RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: Text("Message",style: TextStyle(color: Colors.black,fontSize: 20),),
                    color: Colors.blueAccent,
                    onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>chatScreen(widget.userId,widget.username,widget.url,owneractype,acType1)));}    //private wants to follow private account
                  )
                      :Row(
                    children: <Widget>[
                      followrequestforProf.documents.length==0?
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text("Follow",style: TextStyle(color: Colors.black,fontSize: 20),),
                        color: Colors.blueAccent,
                        onPressed: ()=>addUserInProfessionalAccount(),    //private wants to follow professional account
                      )
                          :Container(),
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text("Message",style: TextStyle(color: Colors.black,fontSize: 20),),
                        color: Colors.blueAccent,
                        onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> chatScreen(widget.userId,widget.username,widget.url,owneractype,acType1)));},    //private wants to follow professional account
                      )
                    ],
                  )
                      :acType1=="professional"?Row(
                    children: <Widget>[
                      followrequestforProf.documents.length==0?
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text("Follow",style: TextStyle(color: Colors.black,fontSize: 20),),
                        color: Colors.blueAccent,
                        onPressed: ()=>addUserInProfessionalAccount(),    //professional wants to follow professional account
                      )
                          : Container(),
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Text("Message",style: TextStyle(color: Colors.black,fontSize: 20),),
                        color: Colors.blueAccent,
                        onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>chatScreen(widget.userId,widget.username,widget.url,owneractype,acType1)));},    //professional wants to follow professional account
                      )
                    ],
                  ):Container()
                ),
                Container(decoration: BoxDecoration(border: Border.all(width: 2.0,color: basicColor)),child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
                  GestureDetector(
                    child: Text("Personal",style: TextStyle(fontSize: 20),),
                    onTap: (){
                      setState(() {
                        acType1="private";
                      });
                    },
                  ),
                  GestureDetector(onTap: (){
                    setState(() {
                      acType1="professional";
                    });
                  },
                    child: Text("Professional",style: TextStyle(fontSize: 20),),)
                ],
                ),
                ),
                Divider(color: Colors.black,),
                followrequestforPersonal.documents.length!=0?displayProfilePost():Container(),
              ],
            )
        ),
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
              child: Text("No posts",style: TextStyle(color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold),),)
          ],
        ),
      );
    }
    else if(acType1=="private"){
      postList=querySnapshotPosts.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
      List<GridTile> gridTiles=[];
      postList.forEach((eachpost) {gridTiles.add(GridTile(child:postTile(eachpost)));
      });
      //print(postList);
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
    else if(acType1=="professional"){
      postList=querySnapshotprfposts.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
      List<GridTile> gridTiles=[];
      postList.forEach((eachpost) {gridTiles.add(GridTile(child:postTile(eachpost)));
      });
      //print(postList);
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
