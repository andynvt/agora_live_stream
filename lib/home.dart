import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String channelName;
  final ClientRole role;
  Home({Key? key, required this.channelName, required this.role}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const APP_ID = '3ae1ca4f2ed24ad99879a05642873274';
  static const Token = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
