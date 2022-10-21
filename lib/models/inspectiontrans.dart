class InspectionTrans {
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

  InspectionTrans({
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
  });
}
