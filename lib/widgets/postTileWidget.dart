//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'postWidget.dart';
class postTile extends StatelessWidget {
  @override
  bool isliked=false;
  Color _iconColor=Colors.black;
  final Post post;
  postTile(this.post);
  Widget build(BuildContext context){
    return GestureDetector(
      child: Image.network(post.url),
      onTap: showPost(post),
    );
  }
  showPost(Post post) {
  }
}

