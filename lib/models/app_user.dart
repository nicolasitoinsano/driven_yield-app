class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.phone,
    required this.role,
  });

  final int id;
  final String name;
  final String? username;
  final String email;
  final String? phone;
  final String role; // 'admin' | 'cliente'

  bool get isAdmin => role.trim().toLowerCase() == 'admin';
  bool get isClient => !isAdmin;

  factory AppUser.fromMap(Map<String, dynamic> map, {String? defaultRole}) {
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
    );
  }

  Map<String, dynamic> toMap() => {
        'id_usuario': id,
        'nombre': name,
        'username': username,
        'email': email,
        'telefono': phone,
        'rol': role,
      };
}
