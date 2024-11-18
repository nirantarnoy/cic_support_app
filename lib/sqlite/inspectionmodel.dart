import 'package:flutter/material.dart';

class InspectionFields {
  static final String id = 'id';
  static final String module_type_id = 'module_type_id';
  static final String plan_id = 'plan_id';
  static final String trans_date = 'trans_date';
  static final String emp_id = 'emp_id';
  static final String area_group_id = 'area_group_id';
  static final String area_id = 'area_id';
  static final String team_id = 'team_id';
  static final String topic_id = 'topic_id';
  static final String topic_item_id = 'topic_item_id';
  static final String score = 'score';
  static final String status = 'status';
  static final String note = 'note';
  static final String plan_num = 'plan_num';
}

class InspectionTransDB {
  final String id;
  final String module_type_id;
  final String plan_id;
  final String trans_date;
  final String emp_id;
  final String area_group_id;
  final String area_id;
  final String team_id;
  final String topic_id;
  final String topic_item_id;
  String score;
  final String status;
  final String note;
  final String plan_num;

  InspectionTransDB({
    required this.id,
    required this.module_type_id,
    required this.plan_id,
    required this.trans_date,
    required this.emp_id,
    required this.area_group_id,
    required this.area_id,
    required this.team_id,
    required this.topic_id,
    required this.topic_item_id,
    required this.score,
    required this.status,
    required this.note,
    required this.plan_num,
  });

  Map<String, Object> toJson() => {
        InspectionFields.id: id,
        InspectionFields.module_type_id: module_type_id,
        InspectionFields.plan_id: plan_id,
        InspectionFields.trans_date: trans_date,
        InspectionFields.emp_id: emp_id,
        InspectionFields.area_group_id: area_group_id,
        InspectionFields.area_id: area_id,
        InspectionFields.team_id: team_id,
        InspectionFields.topic_id: topic_id,
        InspectionFields.topic_item_id: topic_item_id,
        InspectionFields.score: score,
        InspectionFields.status: status,
        InspectionFields.note: note,
        InspectionFields.plan_num: plan_num,
      };

  static InspectionTransDB fromJson(Map<String, Object?> json) =>
      InspectionTransDB(
        id: json[InspectionFields.id].toString(),
        module_type_id: json[InspectionFields.module_type_id].toString(),
        plan_id: json[InspectionFields.plan_id].toString(),
        trans_date: json[InspectionFields.trans_date].toString(),
        emp_id: json[InspectionFields.emp_id].toString(),
        area_group_id: json[InspectionFields.area_group_id].toString(),
        area_id: json[InspectionFields.area_id].toString(),
        team_id: json[InspectionFields.team_id].toString(),
        topic_id: json[InspectionFields.topic_id].toString(),
        topic_item_id: json[InspectionFields.topic_item_id].toString(),
        score: json[InspectionFields.score].toString(),
        status: json[InspectionFields.status].toString(),
        note: json[InspectionFields.note].toString(),
        plan_num: json[InspectionFields.plan_num].toString(),
      );
}
