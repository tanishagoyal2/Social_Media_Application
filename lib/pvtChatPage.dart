import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatScreen.dart';
import 'profilePage.dart';
import 'signUpPage.dart';
import 'constants.dart';

class PvtChatPage extends StatefulWidget {
  @override
  _PvtChatPageState createState() => _PvtChatPageState();
}

class _PvtChatPageState extends State<PvtChatPage> {
  @override
  List<String> chatsOf=["Direct messages","Request messages"];
  Stream pvtMsgStream;
  bool loading=true;
  getAllMessageList()async{
    String TypeofMsg=selectedIndex==0?"DM":"RM";
    Stream msgStream=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("personalchats").where("msgType",isEqualTo: TypeofMsg).snapshots();
    setState(() {
      pvtMsgStream=msgStream;
      loading=false;
    });
  }
  void initState(){
    getAllMessageList();
    super.initState();
  }
  Widget choices() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chatsOf.length,
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
            getAllMessageList();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              chatsOf[index],
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
                height: 60,
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                    color: Colors.blueAccent
                ),
                child: GestureDetector(
                  onTap: (){Navigator.pop(context);},
                  child: Icon(Icons.arrow_back),
                )
            ),
            choices(),
            pvtMsgStream!=null?Expanded(
              child: Container(
                child: usernameList(),
              ),
            ):circularProgress(),
          ],
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
  Widget usernameList() {
    return StreamBuilder(
      stream: pvtMsgStream,
      builder: (context, snapshot) {
        return snapshot.data!=null?ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return snapshot.data!=null?searchTile(snapshot.data.documents[index].data["documentId"],
                snapshot.data.documents[index].data["id"],
                snapshot.data.documents[index].data["name"],
                snapshot.data.documents[index].data["url"],
                snapshot.data.documents[index].data["to"]):Container();
          },
        ): Container(child: Text("No chats",style: TextStyle(fontSize: 20,color: Colors.black),),);
      },
    );
  }
}
int selectedIndex=0;


class searchTile extends StatefulWidget {
  @override
  String documentId;
  String id;
  String name;
  String url;
  String recieveracType;
  searchTile(this.documentId,this.id,this.name,this.url,this.recieveracType);
  _searchTileState createState() => _searchTileState();
}

class _searchTileState extends State<searchTile> {
  @override
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
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> chatScreen(widget.id,widget.name,widget.url,acType,widget.recieveracType)));},
            onDoubleTap: ()=>AlertBox(),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
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
                              Text(widget.name,style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
                          //Text(widget.username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
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
  AlertBox(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: Text("Add user to selective chats?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: ()=>addUserInSelectiveChats(),
              ),
              FlatButton(
                child: Text("No"),
                onPressed:(){ Navigator.pop(context);},
              )
            ],
          );
        }
    );
  }
  addUserInSelectiveChats()async{
    Map<String, dynamic> datamap={
      "documentId":widget.documentId,
      "id":widget.id,
      "name":widget.name,
      "to":widget.recieveracType,
      "url":widget.url
    };
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("selectiveChats").document(widget.documentId).setData(datamap);
    await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("personalchats").document(widget.documentId).delete();
    Navigator.pop(context);
  }
}