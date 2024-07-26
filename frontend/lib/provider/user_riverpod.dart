import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/provider/provider.dart';
import '../model/user.dart';

// Stato dell'utente
class UserState extends StateNotifier<User?> {
  UserState(this.ref) : super(null) {
    checkAuthStatus();
  }

  final Ref ref;

  // Funzione per controllare se l'utente è autenticato
  Future<void> checkAuthStatus() async {
    final apiService = ref.read(apiServiceProvider);
    if (apiService.authToken != null) {
      // L'utente è autenticato se c'è un token
      state =
          await apiService.getUser(); // Metodi per ottenere i dati dell'utente
    } else {
      state = null;
    }
  }

  // Funzione per registrare un nuovo utente
  Future<bool> signUp(User user, String otp) async {
    final apiService = ref.read(apiServiceProvider);
    bool success = await apiService.signUp(user, otp);
    if (success) {
      state = user; // Aggiorna lo stato dell'utente
    }
    return success;
  }

  // Funzione per effettuare il login
  Future<bool> login(String email, String password) async {
    final apiService = ref.read(apiServiceProvider);
    bool success = await apiService.loginUser(email, password);
    if (success) {
      state =
          await apiService.getUser(); // Metodi per ottenere i dati dell'utente
    }
    return success;
  }

  // Funzione per effettuare il logout
  Future<void> logout() async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.logoutUser();
    state = null; // Resetta lo stato dell'utente
  }
}
