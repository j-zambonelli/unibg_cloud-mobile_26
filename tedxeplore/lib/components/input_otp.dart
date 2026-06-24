import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TedxInputOTP extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  const TedxInputOTP({super.key, this.length = 6, required this.onCompleted});

  @override
  State<TedxInputOTP> createState() => _TedxInputOTPState();
}

class _TedxInputOTPState extends State<TedxInputOTP> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isCaretVisible = true;
  Timer? _caretTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _caretTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_focusNode.hasFocus) {
        setState(() => _isCaretVisible = !_isCaretVisible);
      }
    });
  }

  @override
  void dispose() {
    _caretTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: (v) {
                  setState(() {});
                  if (v.length == widget.length) widget.onCompleted(v);
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (index) {
              final text = _controller.text;
              final isFocused = _focusNode.hasFocus && text.length == index;
              final char = index < text.length ? text[index] : '';
              final isHalf = index == widget.length ~/ 2;

              return Row(
                children: [
                  if (isHalf) 
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4), 
                      child: Icon(Icons.remove, color: Colors.grey, size: 14),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isFocused ? const Color(0xFFFF3B30) : Colors.grey[800]!, 
                        width: isFocused ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(char, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        if (isFocused && _isCaretVisible) 
                          Container(width: 2, height: 18, color: const Color(0xFFFF3B30)),
                      ],
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}