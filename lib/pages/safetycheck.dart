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
    if (_elementsx.isNotEmpty) {
      return GroupedListView<dynamic, String>(
        elements: jsonDecode(jsonEncode(_elementsx)),
        groupBy: (element) => "${element["seq_sort"]} ${element["topic_name"]}",
        // ASCENDING order for group sequences
        groupComparator: (value1, value2) => value1.compareTo(value2),
        itemComparator: (item1, item2) =>
            item1['topic_item_name'].compareTo(item2['topic_item_name']),
        sort: true,
        order: GroupedListOrder.ASC, // Changed from DESC to ASC
        useStickyGroupSeparators: true,
        stickyHeaderBackgroundColor: const Color(0xFFF5F7FB),
        groupSeparatorBuilder: (String value) {
          // Remove the seq_sort number from the display text if desired, or keep it.
          // The format is "seq_sort topic_name"
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9B73),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemBuilder: (c, element) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9B73).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_box_outline_blank_rounded,
                    color: Color(0xFF0F9B73),
                    size: 20,
                  ),
                ),
                title: Text(
                  '${element['topic_item_name']}',
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 20),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.playlist_add_check_rounded,
                  size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "ไม่มีข้อมูลหัวข้อการตรวจ",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "หัวข้อการตรวจ",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<TopicItemData>(
        builder: (context, _topicdata, _) =>
            _buildlist(_topicdata.getTopicitemNew()),
      ),
    );
  }
}
