import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modals/user.dart';
import '../userFollowPage.dart';
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String url;
  final String displayname;
  final String PostFor;
  final profileurl;
  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.url,
    this.displayname,
    this.PostFor,
    this.profileurl,
  });
  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["acId"],
      ownerId: documentSnapshot["emailId"],
      username: documentSnapshot["username"],
      url: documentSnapshot["imageurl"],
      displayname:documentSnapshot["displayname"],
      PostFor:documentSnapshot["PostFor"],
      profileurl:documentSnapshot["profileurl"],
    );
  }
  _PostState createState() => _PostState(
    postId:this.postId,
    ownerId:this.ownerId,
    username:this.username,
    url:this.url,
    displayname:this.displayname,
    PostFor:this.PostFor,
    profileurl:this.profileurl,
  );
}
class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String url;
  final String displayname;
  final String PostFor;
  final String profileurl;
  bool isliked=false;
  bool showHeart=false;
  Color _iconColor=Colors.black;
  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.url,
    this.displayname,
    this.PostFor,
    this.profileurl
  });
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Column(
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostBottom(),
        ],
      ),
    );
  }
  circularProgress(){
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black26),),
    );
  }
  createPostHead(){
    return FutureBuilder(
        future: Firestore.instance.collection("Users").document(postId).get(),
        builder: (context,dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          //print(dataSnapshot.data);
          User user=User.fromDocument(dataSnapshot.data);
          //print(user.url);
          // ignore: missing_return, missing_return, missing_return
          //bool isPostOwner=currentOnlineUser==ownerId;
          return ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url),backgroundColor: Colors.grey,),
            title: GestureDetector(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>userFollowPage(postId,username,profileurl,displayname))),
              child: Text(user.username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ),
            subtitle: Text(user.displayname,style: TextStyle(color: Colors.black),),
            trailing:IconButton(
              color: Colors.black,
              onPressed:()=>print("deleted"), icon: Icon(Icons.more_vert),
            ),
          );
        }
    );
  }
  createPostPicture(){
      return GestureDetector(
        onDoubleTap: ()=>print("pic liked"),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.network(url),
          ],
        ),
      );
    }
  createPostBottom(){
    return Column(
      children: <Widget>[
        Divider(color: Colors.grey,thickness: 2.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40,left: 20),
            ),
            GestureDetector(
              onTap: ()=>setLike(),
              child: Icon(
                isliked?Icons.favorite:Icons.favorite_border,
                size: 28.0,
                color: _iconColor,
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.chat,color: Colors.black,size: 28.0,
              ),
              onTap: ()=>print("show comments"),
            ),
            GestureDetector(
              onTap: ()=>print("sharing files"),
              child: Icon(
                Icons.share,color: Colors.black,size: 28.0,
              ),
            ),
            Container(
              width: 270,
              alignment: AlignmentDirectional.bottomEnd,
              child: GestureDetector(
                onTap: ()=>print("saved post"),
                child: Icon(
                  Icons.save,color: Colors.black,size: 35.0,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "678  likes",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15),
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text("   description",style: TextStyle(color: Colors.black),),
            )
          ],
        )
      ],
    );
  }
  setLike(){
    if(isliked==true){
      setState(() {
        _iconColor=Colors.black;
        isliked=false;
      });
    }
    else{
      setState(() {
        _iconColor=Colors.red;
        isliked=true;
      });}
  }
}
