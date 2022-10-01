import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:my_app/constants/routes.dart';
import 'package:my_app/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Email'),
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: _password,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamed(verifEmailRoute);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  await showErrorDialog(
                    context,
                    "Weal password",
                  );
                } else if (e.code == 'email-already-in-use') {
                  await showErrorDialog(
                    context,
                    "Mail is already in use",
                  );
                } else if (e.code == 'invalid-email') {
                  await showErrorDialog(
                    context,
                    "Invalid Email",
                  );
                } else {
                  await showErrorDialog(
                    context,
                    "Unspected Error: ${e.code}",
                  );
                }
              } catch (e) {
                showErrorDialog(
                  context,
                  "Not Auth Error: ${e}",
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Login')),
        ],
      ),
    );
  }
}
