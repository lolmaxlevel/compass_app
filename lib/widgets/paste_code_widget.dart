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
  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      var partnerId = prefs.getString('partner_id') ?? "";
      _controller.text = partnerId.toString();
    });
    super.initState();
  }

  Future<void> _setPartnerId(String s) async {
    final SharedPreferences prefs = await _prefs;
    final String partnerId = s;

    prefs.setString('partner_id', partnerId);
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
            fieldHeight: 45,
              fieldWidth: 20,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          ],
          keyboardType: TextInputType.number,
          animationType: AnimationType.scale,
          autoDismissKeyboard: true,
          onCompleted: (String s) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                const SnackBar(
                  content: Text("Code saved!"),
                  duration: Duration(seconds: 1),
                ));
          },
          onChanged: (text) {
            _setPartnerId(text);
          }),
    );
  }
}
