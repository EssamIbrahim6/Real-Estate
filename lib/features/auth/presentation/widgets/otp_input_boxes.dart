import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

class OtpInputBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  const OtpInputBoxes({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  @override
  State<OtpInputBoxes> createState() => _OtpInputBoxesState();
}

class _OtpInputBoxesState extends State<OtpInputBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onFieldChanged(String value, int index) {
    if (value.length > 1) {
      final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < widget.length && i < clean.length; i++) {
        _controllers[i].text = clean[i];
      }
      final otp = _currentOtp;
      widget.onChanged?.call(otp);
      if (otp.length == widget.length) {
        widget.onCompleted(otp);
      }
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _currentOtp;
    widget.onChanged?.call(otp);
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.hasError
                  ? AppColors.error
                  : (_focusNodes[index].hasFocus
                        ? AppColors.brandNavy
                        : AppColors.transparent),
              width: 1.5,
            ),
          ),
          child: Center(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  if (_controllers[index].text.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                    _controllers[index - 1].clear();
                  }
                }
              },
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandNavy,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => _onFieldChanged(val, index),
              ),
            ),
          ),
        );
      }),
    );
  }
}
