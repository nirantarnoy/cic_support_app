class JobSafetyplanArea {
  final String plan_id;
  final String plan_date;
  final String plan_area_id;
  final String plan_area_name;
  final String plan_topic_check_qty;
  final String plan_topic_checked_qty;
  String status;
  String scored;
  final String plan_num;
  final String department_code;
  final String section_code;
  final String inspection_type_id;

  JobSafetyplanArea({
    required this.plan_id,
    required this.plan_date,
    required this.plan_area_id,
    required this.plan_area_name,
    required this.plan_topic_check_qty,
    required this.plan_topic_checked_qty,
    required this.status,
    required this.scored,
    required this.plan_num,
    required this.department_code,
    required this.section_code,
    required this.inspection_type_id,
  });
}
