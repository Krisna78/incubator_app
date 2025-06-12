import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String nameBtn;
  const MyButton({
    super.key,
    required this.onTap,
    required this.nameBtn,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shadowColor: Color(0xFBFBFBFB),
        elevation: 0.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF00A1FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            nameBtn,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
