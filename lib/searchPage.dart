import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebaseQueries.dart';
import 'signUpPage.dart';
import 'userFollowPage.dart';
class searchPage extends StatefulWidget {
  searchPage();
  _searchPageState createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  @override
  String searchName="";
  Stream userStream;
  DataBaseMethods dataBaseMethods = DataBaseMethods();

  searchUsername(username) async {
      dataBaseMethods.searchUsernames(username).then((value){
      userStream=value;
      //print(username);
      //print(value!=null?value.documents.length.toString():"null");
    }
    );

  }
  Widget usernameList() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return snapshot.data!=null && snapshot.data.documents[index].data["id"]!=gsignin.currentUser.id?searchTile(snapshot.data.documents[index].data["username"],
                snapshot.data.documents[index].data["displayname"],
            snapshot.data.documents[index].data["profileurl"],
            snapshot.data.documents[index].data["id"]):Container();
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
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
                      decoration: InputDecoration(
                        hintText: "Search by emailId or Username",
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.search, color: Colors.grey, size: 25,),
                      ),
                      onChanged: (String msg) {
                        setState(() {
                          searchName=msg;
                        });
                      },
                      onSubmitted: (String msg) {
                        searchUsername(msg);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () => searchUsername(searchName),
                      child: Icon(Icons.send, color: Colors.grey, size: 25,)),
                )
              ],
            ),
          ),
          userStream!=null?Expanded(child: Container(
            child: usernameList(),
          ),):Container(),
        ],
      ),
    );
  }
}
class searchTile extends StatefulWidget {
  @override
  String username;
  String Displayname;
  String url;
  String id;
  searchTile(this.username,this.Displayname,this.url,this.id);
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
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>userFollowPage(widget.id,widget.username,widget.url,widget.Displayname))),
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
                          Text(widget.Displayname,style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
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

