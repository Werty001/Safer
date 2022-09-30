import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifView extends StatefulWidget {
  const EmailVerifView({super.key});

  @override
  State<EmailVerifView> createState() => _EmailVerifViewState();
}

class _EmailVerifViewState extends State<EmailVerifView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Verif'),
      ),
      body: Column(
        children: [
          const Text('Pleace verify your user to continue'),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login/', (route) => false);
              },
              child: const Text('Login'))
        ],
      ),
    );
  }
}
