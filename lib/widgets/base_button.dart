import 'package:flutter/material.dart';

class BaseButton extends StatefulWidget {
  final String data;

  final Widget child;

  const BaseButton({Key? key, required this.data, required this.child}) : super(key: key);

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  late Widget _animatedButton;

  @override
  void initState() {
    _animatedButton = Text(widget.data, style: const TextStyle(fontSize: 20),);
    super.initState();
  }

  bool _buttonPressed = false;

  void _onButtonPressed() {
    setState(() {
      _buttonPressed = !_buttonPressed;
      if (_buttonPressed) {
        _animatedButton = widget.child;
      } else {
        _animatedButton = Text(widget.data,style: const TextStyle(fontSize: 20),);
      }
    });
  }
  
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
            color: Theme.of(context).primaryColor,
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
