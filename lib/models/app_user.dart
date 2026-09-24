class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.phone,
    required this.role,
    this.token,
  });

  final int id;
  final String name;
  final String? username;
  final String email;
  final String? phone;
  final String role; // 'admin' | 'cliente'
  final String? token; // JWT Session Token

  bool get isAdmin => role.trim().toLowerCase() == 'admin';
  bool get isClient => !isAdmin;

  AppUser copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? role,
    String? token,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? defaultRole, String? token}) {
    final rawId = map['id_usuario'] ?? map['id_admin'] ?? map['id'];
    final int parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '1') ?? 1;

    final String resolvedRole = (map['rol']?.toString().trim().isNotEmpty ?? false)
        ? map['rol'].toString().trim().toLowerCase()
        : (defaultRole ?? 'cliente');

    return AppUser(
      id: parsedId,
      name: map['nombre']?.toString() ?? 'Usuario',
      username: map['username']?.toString(),
      email: map['email']?.toString() ?? map['correo']?.toString() ?? '',
      phone: map['telefono']?.toString(),
      role: resolvedRole,
      token: token ?? map['token']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id_usuario': id,
        'nombre': name,
        'username': username,
        'email': email,
        'telefono': phone,
        'rol': role,
        if (token != null) 'token': token,
      };
}
