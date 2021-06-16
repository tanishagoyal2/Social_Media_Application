import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
class DataBaseMethods{
  saveUserInfo(GoogleSignInAccount googleSignInAccount,userinfo)async{
   await Firestore.instance.collection("Users").document("${googleSignInAccount.id}").setData(userinfo);
  }
  getPostsInfo(userid )async{
    return await Firestore.instance.collection("Users").document(userid).collection("Posts").getDocuments();
  }
  getFollowersInfo(userid)async{
    return await Firestore.instance.collection("Users").document(userid).collection("Followers").snapshots();
  }
  getFollowingList(userid)async{
    return await Firestore.instance.collection("Users").document(userid).collection("Following").snapshots();
  }
  uploadPostsDatabase(postMap)async{
    await Firestore.instance.collection("Posts").document().setData(postMap);
  }
  uploadPostUserData(accountType,id,dataMap)async{
    await Firestore.instance.collection("Users").document(id).collection(accountType).document().setData(dataMap);
  }
  searchUsernames(name)async{
    return await Firestore.instance.collection("Users").where("username",isEqualTo: name,).snapshots();
  }
  sendFollowRequest(id,sendMap,senderid)async{
    await Firestore.instance.collection("Users").document(id).collection("Notifications").document(senderid).setData(sendMap);
  }
  fetchrequests(String id)async{
    return await Firestore.instance.collection("Users").document(id).collection("Notifications").snapshots();
  }
  getAllUserinfo(id)async{
    return await Firestore.instance.collection("Users").where("id",isEqualTo: id).getDocuments();
  }
  getConservationMessage(String chatRoomId)async{
    return await Firestore.instance.collection("chatroom").document(chatRoomId).collection("chats").orderBy("timestamp",descending:false).snapshots();
  }
}