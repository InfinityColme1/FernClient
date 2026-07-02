import 'package:flutter/material.dart';


class SidebarItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SidebarItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}