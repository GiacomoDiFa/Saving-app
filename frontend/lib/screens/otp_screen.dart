import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _apiService = ApiService();
  late String _email;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _loginButton(context),
              _gotologinButton(context), // Aggiungi questo
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your email to continue"),
      ],
    );
  }

  _inputField(context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserisci l\'email';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          )
        ],
      ),
    );
  }

  _loginButton(context) {
    return _isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {
                  _isLoading = true;
                });
                bool success = await _apiService.sendOtp(_email);
                setState(() {
                  _isLoading = false;
                });
                if (success) {
                  Navigator.pushReplacementNamed(context, '/signup');
                } else {
                  _showErrorDialog(context, 'Something went wrong');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              "Send Email",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          );
  }

  _gotologinButton(context) {
    return TextButton(
      onPressed: () {
        // Naviga alla schermata di login
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text(
        "Torna alla pagina di login",
        style: TextStyle(fontSize: 16, color: Colors.purple),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
