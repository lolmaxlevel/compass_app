import 'dart:convert';
import 'dart:io';

import 'package:compass_app/models/server_io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketWorker{
  var _socket;

  WebSocketWorker(String url){
    _socket = WebSocketChannel.connect(
        Uri.parse('ws://$url')
        );
  }

  void open(String url){
    _socket = WebSocketChannel.connect(
      Uri.parse('ws://$url')
    );
    _socket.stream.listen(
        (data){
          print(data);
        },
        onError: (error) => print(error),
    );
  }

  void close(){
    if (_socket != null){
      _socket.sink.close();
    }
  }

  void send(Request request){
    _socket.sink.add(
      jsonEncode(request)
    );
  }
}