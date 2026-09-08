class ManagedService {
  const ManagedService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.active,
  });

  final String id;
  final String name;
  final String description;
  final String price;
  final bool active;

  ManagedService copyWith({
    String? name,
    String? description,
    String? price,
    bool? active,
  }) {
    return ManagedService(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      active: active ?? this.active,
    );
  }
}
