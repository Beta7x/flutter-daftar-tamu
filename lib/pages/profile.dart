import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uts/pages/home_page.dart';
import 'package:flutter_uts/pages/login.dart';
import 'package:flutter_uts/utils/config.dart';
import 'package:flutter_uts/widgets/button_profile_widget.dart';
import 'package:flutter_uts/widgets/profile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _AboutPageState();
}

class _AboutPageState extends State<ProfilePage> {
  bool isLoading = false;
  String name = '';
  String email = '';
  String imageUrl = '';
  String address = '';
  String about = '';

  Future<void> getSessionProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var key = pref.getString('key');
    debugPrint(key);

    try {
      var uri = "https://lrg2ak.deta.dev/users/$key";
      var userDetail = await http.get(Uri.parse(uri), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      // controlling response
      if (userDetail.statusCode == 200) {
        final profile = json.decode(userDetail.body) as Map;
        setState(() {
          name = profile['name'];
          email = profile['email'];
          imageUrl = profile['imageUrl'];
          address = profile['address'];
          about = profile['about'];
        });
        debugPrint(userDetail.statusCode.toString());
      }
      debugPrint(imageUrl);
    } catch (e) {
      debugPrint('$e');
    }

    setState(() {
      isLoading = true;
    });
  }

  void loginPageRoute() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void homePageRoute() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext contenxt) => const HomeScreen(),
        ),
        result: (route) => false);
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove('key');
    });
    loginPageRoute();
  }

  @override
  void initState() {
    getSessionProfile();
    super.initState();
    debugPrint(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            // Importan: Remove any padding from the ListView
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                ),
                accountName: Text(
                  "Admin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  "admin@example.com",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                currentAccountPicture: FlutterLogo(),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: homePageRoute,
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {},
              ),
              const AboutListTile(
                icon: Icon(
                  Icons.info,
                ),
                applicationIcon: Icon(
                  Icons.local_play,
                ),
                applicationName: 'Flutter UTS',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2022 Company',
                aboutBoxChildren: [
                  ///Content goes here...
                ],
                child: Text('About app'),
              ),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    logOut();
                  }),
            ],
          ),
        ),
        body: Visibility(
          visible: isLoading,
          child: RefreshIndicator(
            onRefresh: getSessionProfile,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 58),
                child: ListView(
                  children: [
                    ProfileWidget(
                      imagePath: imageUrl,
                      onClicked: () {},
                    ),
                    const SizedBox(height: 24),
                    buildName(name, email),
                    const SizedBox(height: 24),
                    Center(child: buildUpgradeButton()),
                    const SizedBox(height: 48),
                    buildAbout(address, about),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildName(String userName, String email) => Column(
        children: [
          Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Log Out',
        onClicked: logOut,
      );

  Widget buildAbout(String address, String about) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              address,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              about,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
