import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebaseQueries.dart';
import 'signUpPage.dart';
class chatScreen extends StatefulWidget {
  @override
  String userId;
  String username;
  String url;
  String owneracType;
  String receiveracType;
  chatScreen(this.userId,this.username,this.url,this.owneracType,this.receiveracType);
  _chatScreenState createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  @override
  TextEditingController msgController;
  String currentMsg;
  Stream chatMessagesStreamBuilder;
  String chatRoomId;
  DataBaseMethods dataBaseMethods=new DataBaseMethods();


  void initState(){
    super.initState();
    setState(() {
      chatRoomId=getChatRoomId(double.parse(gsignin.currentUser.id), double.parse(widget.userId));
    });
    dataBaseMethods.getConservationMessage(chatRoomId).then((value){
      setState(() {
        chatMessagesStreamBuilder=value;
      });
    });

  }


  sendMessage(String msg)async{
    String ownerSearchIn= widget.owneracType=='private'? 'personalchats' : 'profchats';
    String searchIn=widget.receiveracType=="private"?"Following":"profFollowings";
    String chatsStoreIn=widget.receiveracType=="private"?"personalchats":"profchats";
    QuerySnapshot querySnapshot = await Firestore.instance.collection("Users").document(widget.userId).collection(searchIn).where("id",isEqualTo: gsignin.currentUser.id).getDocuments();
    String msgType=querySnapshot.documents.length==0?"RM":querySnapshot.documents[0].data["MyRelation"]=="AQ"?"RM":"DM";
    QuerySnapshot querySnapshotofmsges=await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection(ownerSearchIn).where("documentId",isEqualTo: chatRoomId).getDocuments();

    if(querySnapshotofmsges.documents.length==0){
      Map<String,dynamic> senderMap1={
        "documentId": chatRoomId,
        "msgType":"DM",
        "to":widget.receiveracType,
        "id":widget.userId,
        "url":widget.url,
        "name":widget.username
      };
      Map<String,dynamic> receiverMap2={
        "documentId":chatRoomId,
        "msgType":msgType,
        "to":widget.owneracType,
        "id":gsignin.currentUser.id,
        "url":gsignin.currentUser.photoUrl,
        "name":gsignin.currentUser.displayName
      };
      // await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("personalchats").document(chatRoomId).setData(senderMap1) : await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection("personalchats").document(chatRoomId).setData(senderMap1);
      //widget.receiveracType=='private' ? await Firestore.instance.collection("Users").document(widget.userId).collection('personalchats').document(chatRoomId).setData(receiverMap2): await Firestore.instance.collection("Users").document(widget.userId).collection('profchats').document(chatRoomId).setData(receiverMap2);
     await Firestore.instance.collection("Users").document(gsignin.currentUser.id).collection(ownerSearchIn).document(chatRoomId).setData(senderMap1);
     await Firestore.instance.collection("Users").document(widget.userId).collection(chatsStoreIn).document(chatRoomId).setData(receiverMap2);
    }
    Map<String,dynamic> msgMap={
      "msg":msg,
      "timestamp":DateTime.now(),
      "id":chatRoomId,
      "send by":gsignin.currentUser.id,
    };
    await Firestore.instance.collection("chatroom").document(chatRoomId).setData(msgMap);
    await Firestore.instance.collection("chatroom").document(chatRoomId).collection("chats").document().setData(msgMap);
  }


  getChatRoomId(double a,double b){
    String senderAc=widget.owneracType=="private"?"p":"pr";
    String receiverAc=widget.receiveracType=="private"?"p":"pr";
    if(a>b){
      print("$b$receiverAc\_$a$senderAc");
      return ("$b$receiverAc\_$a$senderAc");
    }
    else{
      print("$a$senderAc\_$b$receiverAc");
      return ("$a$senderAc\_$b$receiverAc");
    }
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
                    child: Text(widget.username,style: TextStyle(color: Colors.white,fontSize: 18),),
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