import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/teamnotify.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    if (_list.isEmpty) {
      return Center(
        child: Text('ไม่มีการแจ้งเตือน',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          final isUnread = _list[index].read_status == "0";
          String formattedDate = _list[index].notify_date;
          try {
            if (formattedDate.isNotEmpty) {
              DateTime parsedDate = DateTime.parse(formattedDate).toLocal();
              formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
            }
          } catch (e) {
            // Keep original if parsing fails
          }
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: isUnread ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: isUnread ? Colors.green.shade50 : Colors.grey.shade100,
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              onTap: () {
                if (isUnread) {
                  Provider.of<TeamnotifyData>(context, listen: false)
                      .markAsRead(int.parse(_list[index].id));
                }
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(_list[index].title),
                    content: SingleChildScrollView(
                      child: Text(_list[index].detail),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("ปิด", style: TextStyle(fontSize: 16)),
                      )
                    ],
                  ),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUnread ? Colors.green.shade100 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications,
                    color: isUnread ? Colors.green.shade700 : Colors.grey.shade600),
              ),
              title: Text(
                _list[index].title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isUnread ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _list[index].detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              trailing: isUnread
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
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
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Read All',
            onPressed: () {
              Provider.of<TeamnotifyData>(context, listen: false).markAllAsRead();
            },
          )
        ],
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
              width: double.infinity,
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
