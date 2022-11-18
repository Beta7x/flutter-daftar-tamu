import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uts/pages/login.dart';
import 'package:flutter_uts/pages/profile.dart';
import 'package:flutter_uts/pages/visitor_add.dart';
import 'package:flutter_uts/pages/visitor_detail.dart';
import 'package:flutter_uts/utils/config.dart';
import 'package:flutter_uts/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScrennState();
}

class _HomeScrennState extends State<HomeScreen> {
  bool isLoading = true;
  List data = [];

  @override
  void initState() {
    super.initState();
    getPref();
    fetchAllVisitor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> deleteByKey(String key) async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    final url = 'https://lrg2ak.deta.dev/visitors/$key';
    final uri = Uri.parse(url);
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        final filtered =
            data.where((element) => element['key'] != key).toList();
        setState(() {
          data = filtered;
        });
        showSuccessMessage("Delete successfully");
      } else {
        showErrorMessage("Error when deleting visitor");
      }
    } catch (e) {
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
      debugPrint('$e');
    }
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var isLogin = pref.getBool("is_login");
    if (isLogin != null && isLogin == true) {
      setState(() {
        // ignore: unused_local_variable
        String? key = pref.getString('key');
      });
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
        (route) => false,
      );
    }
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

  Future<void> fetchAllVisitor() async {
    try {
      // GET data visitor from server
      const url = 'https://lrg2ak.deta.dev/visitors';
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      // controlling data form server
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map;
        final result = json['items'] as List;
        setState(() {
          data = result;
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  void navigateDetailPage(Map item) {
    final route = MaterialPageRoute(
        builder: (context) => DetailVisitorPage(visitor: item));
    Navigator.push(context, route);
  }

  Future<void> navigateVisitorAdd() async {
    final route =
        MaterialPageRoute(builder: (context) => const AddVisitorPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchAllVisitor();
  }

  void profilePageRoute() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext contenxt) => const ProfilePage(),
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
    showSuccessMessage("Logout");
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blue,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 65),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: const Text('Daftar Tamu'),
      ),
      backgroundColor: Colors.white,
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: profilePageRoute,
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
        replacement: RefreshIndicator(
          onRefresh: fetchAllVisitor,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index] as Map;
                final key = item['key'] as String;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(item['name']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'detail') {
                        navigateDetailPage(item);
                      } else if (value == 'delete') {
                        deleteByKey(key);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Text("Detail"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                      ];
                    },
                  ),
                  onTap: () {
                    debugPrint(item['key']);
                  },
                  subtitle: Text(item['address']),
                );
              },
            ),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: navigateVisitorAdd,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
