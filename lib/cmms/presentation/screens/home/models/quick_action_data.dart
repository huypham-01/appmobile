import 'package:flutter/material.dart';

class QuickActionData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  QuickActionData(this.icon, this.title, this.color, this.onTap);
}
