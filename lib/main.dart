import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/views/Email_verif.dart';
import 'package:my_app/views/login_view.dart';
import 'package:my_app/views/risks/new_risk_view.dart';
import 'package:my_app/views/risks/risks_view.dart';
import 'package:my_app/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Safer',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      riskRoute: (context) => const RiskPage(),
      verifEmailRoute: (context) => const EmailVerifView(),
      newRiskRoute: (context) => const NewRiskView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerify) {
                  return const RiskPage();
                } else {
                  return const EmailVerifView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
