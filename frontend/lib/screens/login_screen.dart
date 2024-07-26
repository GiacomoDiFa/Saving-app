import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/provider/provider.dart'; // Assicurati che il percorso sia corretto

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),
            _inputFields(context),
            _loginButton(context),
            _goToRegisterButton(context),
          ],
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Bentornato",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Inserisci i tuoi dati per continuare"),
      ],
    );
  }

  _inputFields(context) {
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
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserisci la password';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
          ),
        ],
      ),
    );
  }

  _loginButton(context) {
    final userState2 = ref.watch(userProvider);
    print(userState2?.firstname);
    final userState = ref.watch(userProvider.notifier);

    return _isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {
                  _isLoading = true;
                });
                bool success = await userState.login(_email, _password);
                setState(() {
                  _isLoading = false;
                });
                if (success) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  _showErrorDialog(context, 'Credenziali errate');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          );
  }

  _goToRegisterButton(context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/otp');
      },
      child: const Text(
        "Non hai un account? Registrati",
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
