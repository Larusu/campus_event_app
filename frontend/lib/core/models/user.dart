class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String contact;
  final String role;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contact,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    email: json['email'],
    contact: json['contact'],
    role: json['role'],
  );

}