import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_to_do_list/data/firestore.dart';
import 'package:flutter_to_do_list/data/user_info_service.dart';

abstract class AuthenticationDatasource {
  Future<void> register(String email, String password, String PasswordConfirm);
  Future<void> login(String email, String password);
}

class AuthenticationRemote extends AuthenticationDatasource {
  @override
  Future<void> login(String email, String password) async {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    print('userCredential: $userCredential');
    print('userCredential.user: ${userCredential.user}');
    print('userCredential.user?.uid: ${userCredential.user?.uid}');

    final uid = userCredential.user?.uid;
    if (uid != null) {
      await UserInfoService().fetchUserInfo(uid);
    } else {
      print('UID is null');
    }

  }

  @override
  Future<void> register(
      String email, String password, String PasswordConfirm) async {
    if (PasswordConfirm == password) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim())
          .then((value) {
        Firestore_Datasource().CreateUser(email);
      });
    }
  }
}
