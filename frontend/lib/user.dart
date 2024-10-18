class User {
  final int id;
  final String name;
  final String email;
  final bool active;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // print(json);
    // print(json["active"]);
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      active: json['active'] == 1, // Ensure active field is properly parsed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'active': active ? 1 : 0, // Ensure active field is properly serialized
    };
  }
}
