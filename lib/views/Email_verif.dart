import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_service.dart';

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
        title: const Text('Verify your account'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you an email in order to verify your account."),
          const Text(
              "If don't recive the email, pleace press the button below"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Restart'))
        ],
      ),
    );
  }
}
