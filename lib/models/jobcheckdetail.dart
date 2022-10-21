import 'dart:convert';

import 'package:flutter/material.dart';

class JobCheckDetail {
  final String plan_id;
  final String topicid;
  final String topicname;
  final String topic_detail_id;
  final String topic_detail_name;
  final String status;
  final String is_enable;
  final String seq_sort;
  final String seq_sort_item;
  String score;

  JobCheckDetail({
    required this.plan_id,
    required this.topicid,
    required this.topicname,
    required this.topic_detail_id,
    required this.topic_detail_name,
    required this.status,
    required this.score,
    required this.is_enable,
    required this.seq_sort,
    required this.seq_sort_item,
  });

  JobCheckDetail.fromJson(Map<String, dynamic> json)
      : plan_id = json['plan_id'],
        topicid = json['topic_id'],
        topicname = json['topic_name'],
        topic_detail_id = json['topic_detail_id'],
        topic_detail_name = json['topic_detail_name'],
        status = json['status'],
        score = json['score'],
        is_enable = json['is_enable'],
        seq_sort = json['seq_sort'],
        seq_sort_item = json['seq_sort'];

  Map toJson() => {
        "plan_id": plan_id,
        "topicid": topicid,
        "topicname": topicname,
        "topic_detail_id": topic_detail_id,
        "topic_detail_name": topic_detail_name,
        "status": status,
        "score": score,
        "is_enable": is_enable,
        "seq_sort": seq_sort,
        "seq_sort_item": seq_sort_item,
      };
}
