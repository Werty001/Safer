import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerify;
  const AuthUser(this.isEmailVerify);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
