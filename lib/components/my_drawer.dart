import 'package:flutter/material.dart';
import 'package:social_buzz/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? profileOnTap;
  final void Function()? logoutOnTap;
  const MyDrawer({required this.logoutOnTap, required this.profileOnTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 46,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Divider(color: Colors.grey[500], thickness: 2),
          ),
          MyListTile(
            label: 'H O M E',
            icon: Icons.home_filled,
            onTap: () => Navigator.pop(context),
          ),
          MyListTile(
            label: 'P R O F I L E',
            icon: Icons.person,
            onTap: profileOnTap,
          ),
          MyListTile(
            label: 'L O G O U T',
            icon: Icons.logout,
            onTap: logoutOnTap,
          )
        ],
      ),
    );
  }
}
