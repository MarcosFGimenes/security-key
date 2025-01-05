import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para registrar um novo usuário
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erro ao registrar usuário: $e");
      return null;
    }
  }

  // Função para fazer login
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  // Função para sair
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Função para verificar o estado do usuário (se está logado ou não)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
