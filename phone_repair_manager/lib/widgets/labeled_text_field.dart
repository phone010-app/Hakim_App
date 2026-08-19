import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// حقل إدخال موحّد بعنوان وأيقونة، يُستخدم في كل الشاشات لضمان تناسق التصميم
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isNumber;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final bool required;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isNumber = false,
    this.onChanged,
    this.hint,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
