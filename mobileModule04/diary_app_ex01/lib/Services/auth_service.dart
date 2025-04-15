import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "571533552963-rn14i29so7qapp9vm8edoebf7s930em6.apps.googleusercontent.com",
  );

  // Kullanıcının giriş yapıp yapmadığını kontrol et
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Google ile Giriş Yap
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      print("Kullanıcı Adı: ${user?.displayName}");

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }


  // Çıkış Yap
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
