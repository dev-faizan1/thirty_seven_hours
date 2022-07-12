import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:thirty_seven_hours/constants/routes.dart';

import '../utilities/errordialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    _email = TextEditingController();
    _pass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: 'Enter Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _pass,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter Password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final pass = _pass.text;
              final user = FirebaseAuth.instance.currentUser;
              try {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: email, password: pass);

                if (user?.emailVerified ?? false) {
                  //User email verified
                  Navigator.pushNamedAndRemoveUntil(
                      context, notesRoute, (route) => false);
                } else {
                  //Email not verified
                  Navigator.pushNamedAndRemoveUntil(
                      context, verifyEmailRoute, (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                devtools.log(e.code);
                if (e.code == 'invalid-email') {
                  await errorDialog(context, 'Invalid Email');
                } else if (e.code == 'user-not-found') {
                  await errorDialog(context, 'User not found');
                } else if (e.code == 'wrong-password') {
                  await errorDialog(context, 'Wrong password');
                } else {
                  await errorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                e.toString();
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, registerRoute, (route) => false);
            },
            child: const Text('Register here'),
          ),
        ],
      ),
    );
  }
}
