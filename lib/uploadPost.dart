import 'dart:io';
import 'signUpPage.dart';
import 'firebaseQueries.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

import 'modals/user.dart';
class uploadPost extends StatefulWidget {
  @override
  User currentuser;
  uploadPost(this.currentuser);
  _uploadPostState createState() => _uploadPostState();
}

class _uploadPostState extends State<uploadPost> {
  File file;
  String accountType;
  String showPostTo;
  final picker=ImagePicker();
  DataBaseMethods dataBaseMethods=DataBaseMethods();
  String postId=Uuid().v4();
  final StorageReference storageReference=FirebaseStorage.instance.ref().child("posts");
  chooseFile()async{
    accountType=="ProfPosts"?null:Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
      file=File(pickedFile.path);
      print("assigned");
    print(file);
    cropAndCompressImage(file);
  }
  cropAndCompressImage(file)async{
    File cropped=await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(
            ratioX: 0.5,ratioY: 0.5
        ),
        compressQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor:Colors.purpleAccent,
          toolbarTitle: "Crop the image",
          toolbarWidgetColor: Colors.black,
          statusBarColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        iosUiSettings: IOSUiSettings(
            title: 'cropper'
        )
    );
    uploadFile(cropped);
  }
  uploadFile(file)async{
    String downloadurl=await storage(file);
    Map<String,dynamic> postMap={
      "imageurl":downloadurl,
      "timestamp":DateTime.now(),
      "acId":widget.currentuser.id,
      "username":widget.currentuser.username,
      "displayname":widget.currentuser.displayname,
      "profileurl":widget.currentuser.url,
      "PostFor":accountType=="ProfPosts"?"Follower":showPostTo,
      "PostFrom":accountType,
      "emailId":widget.currentuser.email
    };
    dataBaseMethods.uploadPostsDatabase(postMap);
    dataBaseMethods.uploadPostUserData(accountType,widget.currentuser.id, postMap);
  }
  Future<String>storage(filename)async{
    StorageUploadTask storageUploadTask=storageReference.child("post_$postId.jpg").putFile(filename);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    String downloadurl=await storageTaskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }
  dialogueBox(mcontext){
    return showDialog(context: mcontext, builder:(context){
      return SimpleDialog(
        title: Text("Posts Available for",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25.0)),
        children: <Widget>[
          SimpleDialogOption(
            child: Text("Close Friends",style: TextStyle(color: Colors.black,fontSize: 15.0),),
            onPressed: (){
              setState(() {
                showPostTo="CF";
                chooseFile();
              });
            },
          ),
          SimpleDialogOption(
            child: Text("Friends",style: TextStyle(color: Colors.black,fontSize: 15.0),),
            onPressed: (){
              setState(() {
                showPostTo="F";
                chooseFile();
              });
            },
          ),
          SimpleDialogOption(
            child: Text("Acquaintance",style: TextStyle(color: Colors.black,fontSize: 15.0),),
            onPressed: (){
              setState(() {
                showPostTo="AQ";
                chooseFile();
              });
            },
          ),
          SimpleDialogOption(
            child: Text("Cancel",style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold),),
            onPressed: ()=>Navigator.pop(context),
          )
        ],
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_photo_alternate,color: highlightingColor,size: 150,),
            RaisedButton(onPressed: (){
              setState(() {
                accountType="PersonalPosts";
                dialogueBox(context);
              });
            },
              child: Text("for Personal account",style: TextStyle(color: highlightingColor,fontSize: 15),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: basicColor,),
            RaisedButton(onPressed: (){
              accountType="ProfPosts";
              chooseFile();
            },
              child: Text("For Professional account",style: TextStyle(color: highlightingColor,fontSize: 15),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: basicColor,)
          ],
        ),
      ),
    );
  }
}
