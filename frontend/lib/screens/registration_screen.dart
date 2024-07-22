import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/user.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late String _firstname, _lastname, _email, _password, _sex, _otp;
  late int _age;
  bool _isLoading = false;

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
              inputFields(context),
              _registerButton(context),
              _goToLoginButton(context)
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
          "Bentornato",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Inserisci i tuoi dati per continuare")
      ],
    );
  }

  inputFields(context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: "Firsname",
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
                return 'Insert the first name';
              }
              return null;
            },
            onSaved: (value) {
              _firstname = value!;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Last Name",
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
                return 'Insert the last name';
              }
              return null;
            },
            onSaved: (value) {
              _lastname = value!;
            },
          ),
          SizedBox(height: 16.0),
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
                return 'Insert the email';
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
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insert the password';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Age",
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
                return 'Insert the age';
              }
              return null;
            },
            onSaved: (value) {
              _age = int.parse(value!);
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Age",
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
                return 'Insert the sex';
              }
              return null;
            },
            onSaved: (value) {
              _sex = value!;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: "OTP",
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
                return 'Insert the OTP';
              }
              return null;
            },
            onSaved: (value) {
              _otp = value!;
            },
          ),
        ],
      ),
    );
  }

  _registerButton(context) {
    return _isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {
                  _isLoading = true;
                });
                bool success = await _apiService.signUp(
                    User(
                        firstname: _firstname,
                        lastname: _lastname,
                        email: _email,
                        password: _password,
                        age: _age,
                        sex: _sex),
                    _otp);
                setState(() {
                  _isLoading = false;
                });
                if (success) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  _showErrorDialog(context, 'Something went wrong, try again');
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

  _goToLoginButton(context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text(
        "Do you already have an account? Login In",
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
