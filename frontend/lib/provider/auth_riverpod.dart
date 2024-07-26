import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/user.dart';

final authProvider = StateProvider<User?>((ref) => null);
