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

class Booking {
  const Booking({
    required this.date,
    required this.serviceName,
    required this.clientName,
    this.status = 'confirmada',
  });

  final DateTime date;
  final String serviceName;
  final String clientName;
  final String status;
}
