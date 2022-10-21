import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/teamnotify.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    Provider.of<TeamnotifyData>(context, listen: false).teamnotifyFetch();
    super.initState();
  }

  Widget _buillist(List<Teamnotify> _list) {
    Widget cards;
    if (_list.length > 0) {
      cards = new ListView.builder(
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                leading: Icon(Icons.chat),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${_list[index].title}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    Text("${_list[index].detail}")
                  ],
                ),
              ),
            );
          });
      return cards;
    } else {
      return Card(
        child: Text('No Data naja'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          //Initialize the chart widget

          Expanded(
            flex: 2,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Consumer<TeamnotifyData>(
                      builder: ((context, value, child) =>
                          _buillist(value.listteamnotify)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
