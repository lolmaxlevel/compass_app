import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Settings extends StatefulWidget {

  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _host;
  late Future<int> _pooling_rate;
  late TextEditingController _controller;

  Future<void> _setHost(String s) async {
    final SharedPreferences prefs = await _prefs;
    final String host = s;

    setState(() {
      _host = prefs.setString('host', host).then((bool success) {
        return host;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _host = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('host') ?? "";
    });
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text("host:"),
              FutureBuilder<String>(
                  future: _host,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          _controller.text = snapshot.data.toString();
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'host',
                                ),
                                onSubmitted: (string) async {
                                  _setHost(string);
                                },
                              )
                          );
                        }
                    }
                  }
              )
            ],
          ),
        ],
      ),
    );
  }
}
