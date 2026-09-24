/// Lista oficial de marcas de vehículos reconocidas y establecidas en el mercado.
const List<String> kCarBrands = [
  'Audi',
  'BMW',
  'BYD',
  'Changan',
  'Chery',
  'Chevrolet',
  'Citroën',
  'Cupra',
  'Dodge',
  'Fiat',
  'Ford',
  'Foton',
  'Geely',
  'Great Wall',
  'Honda',
  'Hyundai',
  'JAC',
  'Jeep',
  'Kia',
  'Land Rover',
  'Lexus',
  'Mazda',
  'Mercedes-Benz',
  'MG',
  'MINI',
  'Mitsubishi',
  'Nissan',
  'Peugeot',
  'Porsche',
  'RAM',
  'Renault',
  'SEAT',
  'Subaru',
  'Suzuki',
  'Toyota',
  'Volkswagen',
  'Volvo',
  'Otra marca',
];

/// Valida que la marca de vehículo no sea un texto inválido o caracteres sueltos (ej. 'A', '1', etc.)
bool isValidCarBrand(String? brand) {
  if (brand == null) return false;
  final clean = brand.trim();
  if (clean.length < 2) return false;
  // No puede ser exclusivamente dígitos numéricos (ej. '1', '123')
  if (RegExp(r'^\d+$').hasMatch(clean)) return false;
  return true;
}
