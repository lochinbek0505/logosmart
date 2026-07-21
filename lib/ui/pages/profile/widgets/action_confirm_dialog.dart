import 'package:flutter/material.dart';

class ActionConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ActionConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    this.confirmColor = Colors.red,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialogni yopish
          },
          child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Oldin dialogni yopamiz
            onConfirm(); // Keyin asosiy funksiyani chaqiramiz
          },
          child: Text(
            confirmText,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}