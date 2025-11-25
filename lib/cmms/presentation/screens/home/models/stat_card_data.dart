import 'package:flutter/material.dart';

class StatCardData {
  final String title;
  final String description;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  StatCardData(this.title,this.description, this.value, this.icon, this.color, this.onTap);
}
