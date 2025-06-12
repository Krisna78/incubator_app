import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldPage extends StatelessWidget {
  final controller;
  final String hintText;
  final bool isLongText;
  final TextInputType textInputType;
  final int? maxLine;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isFilled;
  final bool isDateField;

  const TextFieldPage({
    super.key,
    required this.controller,
    required this.hintText,
    this.isLongText = false,
    this.textInputType = TextInputType.text,
    this.maxLine,
    this.prefixIcon,
    this.suffixIcon,
    this.isFilled = true,
    this.isDateField = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: maxLine,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: textInputType,
            inputFormatters: textInputType == TextInputType.number
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.deny(RegExp(r'[ \-\,\.]')),
                  ]
                : [],
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorStyle: const TextStyle(
                fontSize: 14,
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A1FF))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A1FF))),
              focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00A1FF))),
              fillColor: Colors.grey.shade100,
              filled: isFilled,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            readOnly: textInputType == TextInputType.datetime ? true : false,
            validator: (value) {
              if (isDateField) {
                return null;
              } else if (isLongText) {
                return null;
              } else if (value == null || value.isEmpty) {
                return "Mohon wajib di isi";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
