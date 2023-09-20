import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/jobcheckdetail.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:flutter_cic_support/models/safetytopicitem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TopicItemData extends ChangeNotifier {
  final String url_topic_item_list =
      "http://cic-support.net:1223/api/topicitem/findtopicbyplan";
  final String url_safety_topic_item_list =
      "http://cic-support.net:1223/api/teaminspectionitem/safetytopiclist";

  late List<JobCheckDetail> _topicitem = [];
  // ignore: unnecessary_getters_setters
  List<JobCheckDetail> get listTopic => _topicitem;

  late List<SafetyTopicItem> _safetytopicitem = [];
  List<SafetyTopicItem> get listSafetyTopic => _safetytopicitem;

  set listTopic(List<JobCheckDetail> val) {
    _topicitem = val;
  }

  set listSafetyTopic(List<SafetyTopicItem> val) {
    _safetytopicitem = val;
  }

  List<SafetyTopicItem> getTopicitemNew() {
    // print('area is ${area_id}');

    List<SafetyTopicItem> _list = [];
    listSafetyTopic.forEach((element) {
      // print('topic name enable is ${element.is_enable}');

      SafetyTopicItem _item = SafetyTopicItem(
        topic_id: element.topic_id,
        topic_name: element.topic_name,
        topic_item_id: element.topic_item_id,
        topic_item_name: element.topic_item_name,
        module_type_id: element.module_type_id,
        seq_sort: element.seq_sort,
      );
      _list.add(_item);
    });
    // _list.sort(
    //   (a, b) => int.parse(a.topic_id).compareTo(int.parse(b.topic_id)),
    // );
    _list.sort(
      (a, b) =>
          a.topic_item_id.toString().compareTo(b.topic_item_id.toString()),
    );
    notifyListeners();
    return _list;
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
            print(res[i]['topic_name'].toString());
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

  Future<dynamic> fetchSafetyTopicItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _token = prefs.getString("token").toString();

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_safety_topic_item_list),
          headers: {'Authorization': _token});

      if (response.statusCode == 200) {
        print("api OK");
        List<dynamic> res = json.decode(response.body);
        List<SafetyTopicItem> data = [];
        if (res == null) {
          print('no data');
        } else {
          // print("ok");

          for (var i = 0; i < res.length; i++) {
            print(res[i]['topic_name'].toString());
            final SafetyTopicItem personRes = SafetyTopicItem(
              topic_id: res[i]['topic_id'].toString(),
              topic_name: res[i]['topic_name'].toString(),
              topic_item_id: res[i]['topic_item_id'].toString(),
              topic_item_name: res[i]['topic_item_name'].toString(),
              module_type_id: res[i]['module_type_id'].toString(),
              seq_sort: res[i]['seq_sort'].toString(),
            );
            data.add(personRes);
          }
          //print("data lenght is ${data[0].topic_name}");
          listSafetyTopic = data;
          // print(listSafetyTopic[0]['topic_name']);
          notifyListeners();
          return listSafetyTopic;
        }
      } else {
        print('error');
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }
}
