import 'package:flutter/material.dart';

class BookingService {
  const BookingService({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });

  final String name;
  final String description;
  final String price;
  final IconData icon;
}
