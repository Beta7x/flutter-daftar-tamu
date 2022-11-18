import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uts/pages/home_page.dart';
import 'package:flutter_uts/utils/config.dart';
import 'package:flutter_uts/widgets/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var txtEditEmail = TextEditingController();
  var txtEditPasswd = TextEditingController();

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
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
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Container(
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
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
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  saveSession(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("key", key);
    await pref.setBool("is_login", true);

    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      doLogin(txtEditEmail.text, txtEditPasswd.text);
    }
  }

  doLogin(email, password) async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, 'Proses...');

    try {
      final response =
          await http.post(Uri.parse("https://lrg2ak.deta.dev/login"),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                "email": email,
                "password": password,
              }));

      final output = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        showSuccessMessage(output['message']);
        if (output['success'] == true) {
          saveSession(output['key']);
        }
      } else {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        showErrorMessage(output['message']);
      }
    } catch (e) {
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
      debugPrint('$e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: txtEditEmail,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Masukan email yang valid'
                    : null,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (String? val) => txtEditEmail.text = val!,
            decoration: const InputDecoration(
              hintText: "email address",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: txtEditPasswd,
                onSaved: (String? val) => txtEditPasswd.text = val!,
                validator: (String? args) {
                  if (args == null || args.isEmpty) {
                    return 'Password harus diisi';
                  } else {
                    return null;
                  }
                },
                textInputAction: TextInputAction.done,
                obscureText: true,
                cursorColor: kPrimaryColor,
                decoration: const InputDecoration(
                    hintText: "secure password",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.lock),
                    )),
              )),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () => _validateInputs(),
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
