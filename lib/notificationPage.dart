//import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebaseQueries.dart';
import 'signUpPage.dart';
class notificationPage extends StatefulWidget {
  @override
  _notificationPageState createState() => _notificationPageState();
}

class _notificationPageState extends State<notificationPage> {
  @override
  DataBaseMethods dataBaseMethods=new DataBaseMethods();
  Stream searchStream;
  fetchNotifications()async{
    dataBaseMethods.fetchrequests(gsignin.currentUser.id).then((value){
      searchStream=value;
      //print(value.documents.length.toString());
    });
  }
  void initState(){
    fetchNotifications();
    super.initState();
  }
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: searchStream,
      builder: (context,snapshot){
        return snapshot.data!=null?ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context,index){
            return searchTile(snapshot.data.documents[index].data["id"],snapshot.data.documents[index].data["For"],snapshot.data.documents[index].data["profileurl"],snapshot.data.documents[index].data["displayname"],snapshot.data.documents[index].data["ToFollow"]);
          },
        ):Container();
      },
    );
  }
}
class searchTile extends StatefulWidget {
  @override
  String id;
  String asA;
  String url;
  String displayname;
  String toFollow;
  searchTile(this.id,this.asA,this.url,this.displayname,this.toFollow);
  _searchTileState createState() => _searchTileState();
}

class _searchTileState extends State<searchTile> {
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              alignment: Alignment.bottomLeft,
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.url),
                      fit: BoxFit.fill
                  ),
                  color: Colors.pink,
                  shape: BoxShape.circle
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width-60,
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.displayname+" wants to be your friend",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                          widget.toFollow=="private"?Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
                            RaisedButton(child: Text("Friend",style: TextStyle(color: Colors.white,fontSize: 12),),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),color: Colors.green,onPressed: ()=>addInFollowersList("F"),),
                            RaisedButton(child: Text("Close Friend",style: TextStyle(color: Colors.white,fontSize: 12),),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),color: Colors.green,onPressed: ()=>addInFollowersList("CF"),),
                            RaisedButton(child: Text("Acquaintance",style: TextStyle(color: Colors.white,fontSize: 12),),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),color: Colors.green,onPressed: ()=>addInFollowersList("AQ"),)
                          ],):Row(children: <Widget>[
                            RaisedButton(child: Text("Accept",style: TextStyle(color: Colors.white,fontSize: 12),),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),color: Colors.green,onPressed: ()=>addInFollowersList("Followers"),),
                          ],)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(thickness: 3,),
        ],
      ),
    );
  }
  addInFollowersList(type)async{
    Map<String,dynamic> dataMap1={
      "id":widget.id,
      "OtherRelation":widget.asA,
      "profileurl":widget.url,
      "displayname":widget.displayname,
      "MyRelation":type,
    };
    Map<String,dynamic> dataMap2={
      "id":gsignin.currentUser.id,
      "otherRelation":type,
      "profileurl":gsignin.currentUser.photoUrl,
      "displayname":gsignin.currentUser.displayName,
      "MyRelation":widget.asA
    };
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Followers").document(widget.id).setData(dataMap1);
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Following").document(widget.id).setData(dataMap1);
    await Firestore.instance.collection("Users").document(widget.id).collection("Followers").document(gsignin.currentUser.id).setData(dataMap2);
    await Firestore.instance.collection("Users").document(widget.id).collection("Following").document(gsignin.currentUser.id).setData(dataMap2);
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("Notifications").document(widget.id).delete();
  }
}
