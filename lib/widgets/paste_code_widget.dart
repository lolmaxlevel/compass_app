import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasteCode extends StatefulWidget {
  const PasteCode({Key? key}) : super(key: key);

  @override
  State<PasteCode> createState() => _PasteCodeState();
}


class _PasteCodeState extends State<PasteCode> {
  final TextEditingController _controller = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //#TODO сделать сохранения кода
  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      var id = prefs.getInt('id') ?? 0;
      if (id == 0){
        id = UniqueKey().hashCode % 1000000;
      }
      prefs.setInt('id', id);
      _controller.text = id.toString();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 0),
      child: PinCodeTextField(
          appContext: context,
          length: 6,
          useHapticFeedback: true,
          hapticFeedbackTypes: HapticFeedbackTypes.light,
          controller: _controller,
          pinTheme: PinTheme(
              fieldWidth: 20,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          ],
          keyboardType: TextInputType.number,
          animationType: AnimationType.scale,
          autoDismissKeyboard: true,
          onTap: () {
            _controller.text='112311';
          },
          onChanged: (text) {
            if (kDebugMode) {
              print(text);
            }
          }),
    );
  }
}
