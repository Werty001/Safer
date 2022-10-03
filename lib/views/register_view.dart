import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_service.dart';
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  "Weal password",
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  "Mail is already in use",
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  "Invalid Email",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "Error in registration process",
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
