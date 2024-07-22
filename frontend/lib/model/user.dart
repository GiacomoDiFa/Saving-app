class User {
  final String? id;
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final int age;
  final String sex;

  User({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.age,
    required this.sex,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'age': age,
      'sex': sex,
    };
  }
}
