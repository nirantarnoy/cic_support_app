import 'package:flutter/material.dart';

class TeamNotifyPage extends StatefulWidget {
  const TeamNotifyPage({Key? key}) : super(key: key);

  @override
  State<TeamNotifyPage> createState() => _TeamNotifyPageState();
}

class _TeamNotifyPageState extends State<TeamNotifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเตือน'),
      ),
      body: Column(children: []),
    );
  }
}
