import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TopicItemData extends ChangeNotifier {
  final String url_topic_item_list =
      "http://192.168.60.58:1223/api/topicitem/findtopicbyplan";

  late List<JobCheckDetail> _topicitem = [];
  // ignore: unnecessary_getters_setters
  List<JobCheckDetail> get listTopic => _topicitem;

  set listTopic(List<JobCheckDetail> val) {
    _topicitem = val;
  }

  Future<dynamic> fetchTopicItem() async {
    String plan_id = "1";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_topic_item_list + "/" + plan_id),
          headers: {'Authorization': _token});

      if (response.statusCode == 200) {
        print("api OK");
        List<dynamic> res = json.decode(response.body);
        List<JobCheckDetail> data = [];
        if (res == null) {
          print('no data');
        } else {
          // print("ok");
          for (var i = 0; i < res.length; i++) {
            final JobCheckDetail personRes = JobCheckDetail(
              plan_id: "",
              topicid: res[i]['topic_id'].toString(),
              topicname: res[i]['topic_name'].toString(),
              topic_detail_id: res[i]['topic_item_id'].toString(),
              topic_detail_name: res[i]['topic_item_name'].toString(),
              status: res[i]['status'].toString(),
              is_enable: res[i]['is_enable'].toString(),
              score: "-1",
              seq_sort: res[i]['seq_sort'].toString(),
              seq_sort_item: '',
            );
            data.add(personRes);
          }

          print(data[0].topicid);

          listTopic = data;
          notifyListeners();
          return listTopic;
        }
      } else {
        print('error');
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }
}
