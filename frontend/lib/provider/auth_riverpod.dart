import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider per gestire lo stato di autenticazione
final authProvider = StateProvider<bool>((ref) => false);
