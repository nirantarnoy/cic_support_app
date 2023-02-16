import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/safetytopicitem.dart';
import 'package:flutter_cic_support/providers/topicitem.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class SafetyCheckPage extends StatefulWidget {
  const SafetyCheckPage({Key? key}) : super(key: key);

  @override
  State<SafetyCheckPage> createState() => _SafetyCheckPageState();
}

class _SafetyCheckPageState extends State<SafetyCheckPage> {
  @override
  void initState() {
    // TODO: implement initState

    Provider.of<TopicItemData>(context, listen: false).fetchSafetyTopicItem();
    super.initState();
  }

  Widget _buildlist(List<SafetyTopicItem> _elementsx) {
    Widget carditem;
    if (_elementsx.length > 0) {
      carditem = GroupedListView<dynamic, String>(
        elements: jsonDecode(jsonEncode(_elementsx)),
        groupBy: (element) => element["seq_sort"] + " " + element["topic_name"],
        groupComparator: (value1, value2) => value2.compareTo(value1),
        itemComparator: (item1, item2) =>
            item1['topic_item_name'].compareTo(item2['topic_item_name']),
        sort: true,
        order: GroupedListOrder.DESC,
        useStickyGroupSeparators: true,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (c, element) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: GestureDetector(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                elevation: 2.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: SizedBox(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    title: Text('${element['topic_item_name']}'),
                  ),
                ),
              ),
              onTap: () {},
            ),
          );
        },
      );

      return carditem;
    } else {
      return Center(
        child: Text('No Data'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("หัวข้อการตรวจ"),
        backgroundColor: Color.fromARGB(255, 45, 172, 123),
      ),
      body: Column(children: <Widget>[
        // Text(""),
        Expanded(
          child: Consumer<TopicItemData>(
            builder: (context, _topicdata, _) =>
                _buildlist(_topicdata.getTopicitemNew()),
          ),
        ),
      ]),
    );
  }
}
