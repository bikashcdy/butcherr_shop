// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:    int.parse(json['id'].toString()),
      name:  json['name'],
      email: json['email'],
      role:  json['role'],
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  Map<String, dynamic> toJson() => {
    'id':    id,
    'name':  name,
    'email': email,
    'role':  role,
  };
}