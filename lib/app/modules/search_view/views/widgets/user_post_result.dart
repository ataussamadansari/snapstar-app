import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/modules/search_view/controllers/search_controller.dart';

class UserPostResults extends StatelessWidget {
  const UserPostResults({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SearchScreenController>();

    return ListView(
      children: [
        /// USERS
        ...c.users.map(
              (u) => ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(u.photoUrl),
            ),
            title: Text(u.username),
            subtitle: Text(u.name),
          ),
        ),

        /// POSTS
        if (c.posts.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text("Posts", style: TextStyle(fontWeight: FontWeight.bold)),
          ),

        ...c.posts.map(
              (p) => ListTile(
            title: Text(p.caption),
            subtitle: Text(p.user.username),
          ),
        ),
      ],
    );
  }
}
