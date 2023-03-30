import 'package:flutter/material.dart';
import 'package:myassistant/my_colors.dart';
import 'package:myassistant/views/history_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // backgroundColor: Colors.black,
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            // color: Colors.grey,
            child: DrawerHeader(
              // decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        // height: 80,
                        width: 80,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                            color: MyColors.assistantCircleColor,
                            shape: BoxShape.circle),
                      ),
                      Container(
                        height: 90,
                        width: 90,
                        
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/virtual_assistant.png"))),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "My Assistant",
                        style: TextStyle(
                          fontSize: 16,
                          color: MyColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 12,
                          color: MyColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 12.0,
          ),

          //drawer body
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.history,
                color: MyColors.whiteColor,
              ),
              title: Text(
                "History",
                style: TextStyle(color: MyColors.whiteColor),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(
                Icons.person,
                color: MyColors.whiteColor,
              ),
              title: Text(
                "Visit Profile",
                style: TextStyle(color: MyColors.whiteColor),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(
                Icons.info,
                color: MyColors.whiteColor,
              ),
              title: Text(
                "About",
                style: TextStyle(color: MyColors.whiteColor),
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () {
          //     // fAuth.signOut();
          //     // Navigator.push(context,
          //     //     MaterialPageRoute(builder: (c) => const MySplashScreen()));
          //   },
          //   child: const ListTile(
          //     leading: Icon(
          //       Icons.logout,
          //       color: MyColors.whiteColor,
          //     ),
          //     title: Text(
          //       "Sign Out",
          //       style: TextStyle(color: MyColors.whiteColor),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
