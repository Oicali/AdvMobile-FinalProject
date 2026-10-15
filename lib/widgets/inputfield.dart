import 'package:flutter/material.dart';

// Rounded white text field with label, optional error and a built-in show/hide eye for passwords
class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  final bool obscure; // true = password field (gets the eye toggle)
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines; // above 1 makes a multi-line box (ignored for password fields)

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.hasError = false,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  // Starts hidden for password fields; the eye flips it
  late bool hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final bad = widget.hasError || widget.errorText != null;
    OutlineInputBorder outline(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: 1.5),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B2626))),
        ),
        // Soft shadow wrapper + the actual input
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: hidden,
            keyboardType: widget.keyboard,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B2626)),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF98A4A2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              // Eye icon only on password fields
              suffixIcon: widget.obscure
                  ? IconButton(
                      icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: const Color(0xFF6A7776)),
                      onPressed: () => setState(() => hidden = !hidden),
                    )
                  : null,
              enabledBorder: outline(bad ? const Color(0xFFD64545) : Colors.transparent),
              focusedBorder: outline(bad ? const Color(0xFFD64545) : const Color(0xFF0F5C5C)),
            ),
          ),
        ),
        // Error text under the field
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 7),
            child: Text(widget.errorText!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD64545))),
          ),
      ],
    );
  }
}