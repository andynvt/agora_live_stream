import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController(text: 'lecle');
  ClientRole role = ClientRole.Audience;

  void onJoin() async {
    if (controller.text.isNotEmpty) {
      await [Permission.camera, Permission.microphone].request();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            channelName: controller.text,
            role: role,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Live Stream'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 32),
            Text('Channel name'),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
                hintText: 'Channel name',
              ),
            ),
            SizedBox(height: 32),
            Text('Select role'),
            SizedBox(height: 16),
            ListTile(
              title: const Text('Broadcaster'),
              leading: Radio(
                value: ClientRole.Broadcaster,
                groupValue: role,
                onChanged: (ClientRole? v) {
                  setState(() {
                    role = v!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  role = ClientRole.Broadcaster;
                });
              },
            ),
            ListTile(
              title: const Text('Audience'),
              leading: Radio(
                value: ClientRole.Audience,
                groupValue: role,
                onChanged: (ClientRole? v) {
                  setState(() {
                    role = v!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  role = ClientRole.Audience;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      onPressed: onJoin,
                      child: Text('Join'),
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
