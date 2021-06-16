import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatScreen.dart';
import 'profilePage.dart';
import 'selectiveChatsScreenPage.dart';
import 'signUpPage.dart';
class selectiveChatsPage extends StatefulWidget {
  @override
  _selectiveChatsPageState createState() => _selectiveChatsPageState();
}

class _selectiveChatsPageState extends State<selectiveChatsPage> {
  @override
  Stream selectiveMsgStream;
  bool loading =true;
  getAllMessageList()async{
    Stream msgStream=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("selectiveChats").snapshots();
    setState(() {
      selectiveMsgStream=msgStream;
      loading=false;
    });
  }
  void initState(){
    getAllMessageList();
    super.initState();
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
            selectiveMsgStream!=null?Expanded(
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
      stream: selectiveMsgStream,
      builder: (context, snapshot) {
        return snapshot.data!=null?ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return snapshot.data!=null?searchTile(
                snapshot.data.documents[index].data["documentId"],
                snapshot.data.documents[index].data["name"],
                snapshot.data.documents[index].data["url"],
                snapshot.data.documents[index].data["to"]):Container();
          },
        ): Container(child: Text("No chats",style: TextStyle(fontSize: 20,color: Colors.black),),);
      },
    );
  }
}
class searchTile extends StatefulWidget {
  @override
  String documentId;
  String name;
  String url;
  String recieveracType;
  searchTile(this.documentId,this.name,this.url,this.recieveracType);
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
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> selectiveChatsPageScreen(widget.documentId,widget.name,widget.url)));},
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
}
