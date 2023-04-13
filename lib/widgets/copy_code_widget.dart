import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CopyCode extends StatefulWidget {
  const CopyCode({Key? key}) : super(key: key);

  @override
  State<CopyCode> createState() => _CopyCodeState();
}

class _CopyCodeState extends State<CopyCode> {
  final TextEditingController _controller = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
        controller: _controller,
        length: 6,
        enabled: false,
        pinTheme: PinTheme(
          fieldHeight: 45,
          fieldWidth: 20,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        keyboardType: TextInputType.number,
        onTap: () {
          Clipboard.setData(
              ClipboardData(text: _controller.text))
              .then((_){ScaffoldMessenger.of(context)
              .showSnackBar(
              const SnackBar(
                content: Text("Code copied to clipboard!"),
                duration: Duration(seconds: 1),
              ));
          });
        },
        onChanged: (String value) {
          if (kDebugMode) {
            print(value);
          }},),
    );
  }
}
