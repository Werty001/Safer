import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_provider.dart';
import 'package:my_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initializaed to begin with', () {
      expect(provider.isInitilized, false);
    });
    test('Can not log out if not inicializaed', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedExeption>()),
      );
    });
    test('Should be able to be inicialized', () async {
      await provider.initialize();
      expect(provider.isInitilized, true);
    });
    test('User should be null after inicialization', () {
      expect(provider.currentUser, null);
    });
    test(
      'Should be able to inicialized in less than 2 sec.',
      () async {
        await provider.initialize();
        expect(provider.isInitilized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(
        email: 'werty@gmail.com',
        password: 'candcand1',
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword = provider.createUser(
        email: 'werty1@gmail.com',
        password: 'candcand',
      );
      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'wert3@gmail.com',
        password: 'candcand3',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerify, false);
    });
    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerify, true);
    });
    test('Should be able to LogOut and LogIn again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedExeption implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitilized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitilized) throw NotInitializedExeption();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitilized) throw NotInitializedExeption();
    //Here there are only examples of a logit of the MOCK
    //There are not really funcionals
    if (email == 'werty@gmail.com') throw UserNotFoundAuthException();
    if (password == 'candcand') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerify: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitilized) throw NotInitializedExeption();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitilized) throw NotInitializedExeption();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerify: true);
    _user = newUser;
  }
}
