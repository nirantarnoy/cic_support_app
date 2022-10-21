class JobplanArea {
  final String plan_id;
  final String plan_date;
  final String plan_area_id;
  final String plan_area_name;
  final String plan_topic_check_qty;
  final String plan_topic_checked_qty;
  String status;
  String scored;
  final String topic_id;
  final String topic_name;
  final String topic_item_id;
  final String topic_item_name;
  final String is_enable;
  final String seq_sort;
  final String seq_sort_item;

  JobplanArea({
    required this.plan_id,
    required this.plan_date,
    required this.plan_area_id,
    required this.plan_area_name,
    required this.plan_topic_check_qty,
    required this.plan_topic_checked_qty,
    required this.status,
    required this.topic_id,
    required this.topic_name,
    required this.topic_item_id,
    required this.topic_item_name,
    required this.scored,
    required this.is_enable,
    required this.seq_sort,
    required this.seq_sort_item,
  });
}
