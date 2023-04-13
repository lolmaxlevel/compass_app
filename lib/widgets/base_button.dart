import 'package:flutter/material.dart';

class BaseButton extends StatefulWidget {
  const BaseButton(String this.text {Key? key}) : super(key: key);

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {

  Widget _animatedButton = const Text(text);
  bool _buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: _onButtonPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 4/6,
        height: MediaQuery.of(context).size.height * 1/15,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.rectangle,
          border: Border.all(
            width: 3,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: _animatedButton,
          ),
        ),
      ),
    );
  }
}
