class User {
  final String? id;
  final String firstname;
  final String lastname;
  final String email;
  final String? password;
  final int age;
  final String sex;

  User({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.password,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      age: json['age'],
      sex: json['sex'],
    );
  }
}
