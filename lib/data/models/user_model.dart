class User{
  String? id;
  String? Username;
  String? email;
  String? token;
  List<dynamic>? roles;
  String? type;
  String? password;


  User({
    this.id,
    this.Username,
    this.email,
    this.token,
    this.roles,
    this.type,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'],
      Username: json['username'],
      email: json['email'],
      token: json['token'],
      roles: json['roles'],
      type: json['type'],
      password: json['password'],
    );
  }
}