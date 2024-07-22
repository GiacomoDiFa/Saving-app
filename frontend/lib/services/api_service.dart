import 'dart:convert';
import 'package:frontend/model/transaction.dart';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../model/label.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _singleton = ApiService._internal();
  String? _authToken; // Utilizza una variabile privata per l'authtoken

  factory ApiService() {
    return _singleton;
  }

  ApiService._internal();

  String? get authToken => _authToken;

  set authToken(String? token) {
    _authToken = token;
  }

  Future<bool> signUp(User user, String otp) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/user/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        ...user.toJson(),
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/user/sendotp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Aggiorna l'authtoken dopo il login se necessario
      _authToken = response.headers['set-cookie'];

      RegExp regExp = RegExp(r'token=([^;]+)');
      Match? match = regExp.firstMatch(_authToken ?? '');

      if (match != null) {
        _authToken = match.group(1)!;
      } else {
        print('Nessun token trovato nella stringa.');
      }

      return true;
    } else {
      return false;
    }
  }

  Future<bool> logoutUser() async {
    // Implementa la logica per il logout, ad esempio invalidando il token lato server
    _authToken = null; // Cancella il token di accesso salvato
    return true;
  }

  Future<List<Label>> getLabels() async {
    final uri = Uri.parse('$apiBaseUrl/label/getall');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
    );

    if (response.statusCode == 200) {
      // Stampa la risposta per il debug

      // Decodifica il corpo della risposta come un oggetto
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Accedi alla lista di etichette
      List<dynamic> jsonList = jsonResponse['labels'];

      // Mappa la lista di oggetti JSON alla lista di oggetti Label
      List<Label> labels =
          jsonList.map((json) => Label.fromJson(json)).toList();

      // Stampa le etichette per il debug

      return labels;
    } else {
      throw Exception('Failed to load labels');
    }
  }

  Future<bool> addLabel(String label, String field) async {
    final uri = Uri.parse('$apiBaseUrl/label/add');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{'label': label, 'field': field}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteLabel(String label) async {
    final uri = Uri.parse('$apiBaseUrl/label/delete');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{'label': label}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateLabel(
      String oldLabel, String newLabel, String newFieldValue) async {
    final uri = Uri.parse('$apiBaseUrl/label/modify');
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'oldLabel': oldLabel,
        'newLabel': newLabel,
        'newField': newFieldValue
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    final uri = Uri.parse('$apiBaseUrl/transaction/getall');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
    );

    if (response.statusCode == 200) {
      // Stampa la risposta per il debug

      // Decodifica il corpo della risposta come un oggetto
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Accedi alla lista di etichette
      List<dynamic> jsonList = jsonResponse['transactions'];

      // Mappa la lista di oggetti JSON alla lista di oggetti Label
      List<Transaction> transactions =
          jsonList.map((json) => Transaction.fromJson(json)).toList();

      return transactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<List<Transaction>> filterTransactions(
      String? labelId, int? month, int? year) async {
    try {
      String url = '$apiBaseUrl/transaction/getfiltered';

      // Costruzione dell'URL in base ai parametri forniti
      if (labelId != null || month != null || year != null) {
        url += '/';
        url += labelId ?? 'null';
        url += '/';
        url += month != null ? month.toString() : 'null';
        url += '/';
        url += year != null ? year.toString() : 'null';
      } else {
        // Se nessun parametro è fornito, ottieni tutte le transazioni
        url += '/null/null/null';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'token=$_authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Transaction> transactions =
            data.map((item) => Transaction.fromJson(item)).toList();
        return transactions;
      } else {
        throw Exception('Failed to filter transactions');
      }
    } catch (e) {
      throw Exception('Failed to filter transactions');
    }
  }

  Future<bool> addTransaction(String label, String transactionType,
      String amount, String description) async {
    final uri = Uri.parse('$apiBaseUrl/transaction/add');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'label': label,
        'transactionType': transactionType,
        'amount': amount,
        'description': description
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<num> getFundamentalMonthly(String month) async {
    final uri = Uri.parse('$apiBaseUrl/summary/fundamentals');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'yearMonth': month,
      }),
    );
    if (response.statusCode == 200) {
      return num.parse(response.body);
    } else {
      return 0;
    }
  }

  Future<num> getFunMonthly(String month) async {
    final uri = Uri.parse('$apiBaseUrl/summary/fun');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'yearMonth': month,
      }),
    );
    if (response.statusCode == 200) {
      return num.parse(response.body);
    } else {
      return 0;
    }
  }

  Future<num> getFutureYouMonthly(String month) async {
    final uri = Uri.parse('$apiBaseUrl/summary/futureyou');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'yearMonth': month,
      }),
    );
    if (response.statusCode == 200) {
      return num.parse(response.body);
    } else {
      return 0;
    }
  }

  Future<num> getMonthlyIncome(String month) async {
    final uri = Uri.parse('$apiBaseUrl/income/monthly');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'token=$_authToken',
      },
      body: jsonEncode(<String, String>{
        'yearMonth': month,
      }),
    );
    if (response.statusCode == 200) {
      return num.parse(response.body);
    } else {
      return 0;
    }
  }
}
