import 'package:flutter/material.dart';

class NarrationInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final int maxLength;

  const NarrationInput({
    super.key,
    required this.controller,
    this.labelText = "Narration (optional)",
    this.maxLength = 100,
  });

  @override
  State<NarrationInput> createState() => _NarrationInputState();
}

class _NarrationInputState extends State<NarrationInput> {
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.maxLength;
    widget.controller.addListener(_updateCounter);
  }

  void _updateCounter() {
    setState(() {
      _remaining = widget.maxLength - widget.controller.text.length;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCounter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: "Add a short note for this transaction",
        counterText: "$_remaining characters left",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
