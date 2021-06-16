import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'signUpPage.dart';

import 'firebaseQueries.dart';
class selectiveChatsPageScreen extends StatefulWidget {
  @override
  String chatRoomId;
  String name;
  String url;
  selectiveChatsPageScreen(this.chatRoomId,this.name,this.url);
  _selectiveChatsPageScreenState createState() => _selectiveChatsPageScreenState();
}

class _selectiveChatsPageScreenState extends State<selectiveChatsPageScreen> {
  @override
  TextEditingController msgController;
  String currentMsg;
  Stream chatMessagesStreamBuilder;
  DataBaseMethods dataBaseMethods=new DataBaseMethods();
  void initState(){
    dataBaseMethods.getConservationMessage(widget.chatRoomId).then((value){
      setState(() {
        chatMessagesStreamBuilder=value;
      });
    });
  }
  sendMessage(String msg)async{
    Map<String,dynamic> msgMap={
      "msg":msg,
      "timestamp":DateTime.now(),
      "id":widget.chatRoomId,
      "send by":gsignin.currentUser.id,
    };
    await Firestore.instance.collection("chatroom").document(widget.chatRoomId).setData(msgMap);
    await Firestore.instance.collection("chatroom").document(widget.chatRoomId).collection("chats").document().setData(msgMap);
  }
  Widget messageList(){
    return StreamBuilder(
        stream: chatMessagesStreamBuilder,
        builder:(context,snapshot){
          return snapshot.data!=null ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,index){
              return MessageTile(snapshot.data.documents[index].data["msg"],snapshot.data.documents[index].data["send by"]);
            },
          ):Container();
        }
    );
  }
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Container(
            height: 70,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                color: Colors.blueAccent
            ),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: (){Navigator.pop(context);},
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      image:DecorationImage(
                          image: NetworkImage(widget.url),
                          fit: BoxFit.cover
                      ),
                      shape:BoxShape.circle
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Container(
                    child: Text(widget.name,style: TextStyle(color: Colors.white,fontSize: 18),),
                  ),
                )
              ],
            ),
          ),
          Expanded(child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[300]
            ),
            child: messageList(),
          ),),
          Container(
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 9),
                    child: TextField(
                      controller: msgController,
                      decoration: InputDecoration(
                        hintText: "Write a Message",
                        icon:Icon(Icons.message,color: Colors.pink,size: 25,),
                      ),
                      onChanged: (String msg){
                        currentMsg=msg;
                      },
                      onSubmitted: (String msg){
                        sendMessage(msg);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(onTap: ()=>sendMessage(currentMsg),child: Icon(Icons.send,color: Colors.pink,size: 25,)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class MessageTile extends StatelessWidget {
  final String message;
  final String sendBy;
  MessageTile(this.message,this.sendBy);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        alignment: sendBy==gsignin.currentUser.id?Alignment.bottomRight:Alignment.bottomLeft,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: sendBy==gsignin.currentUser.id?Colors.lightBlueAccent:Colors.white70,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(message,style: TextStyle(color: Colors.black,fontSize: 18),),
          ),
        ),
      ),
    );
  }
}