class SafetyTopicItem {
  String topic_id;
  String topic_name;
  String module_type_id;
  String topic_item_id;
  String topic_item_name;
  String seq_sort;

  SafetyTopicItem({
    required this.topic_id,
    required this.topic_name,
    required this.module_type_id,
    required this.topic_item_id,
    required this.topic_item_name,
    required this.seq_sort,
  });

  SafetyTopicItem.fromJson(Map<String, dynamic> json)
      : topic_id = json['topic_id'],
        topic_name = json['topic_name'],
        topic_item_id = json['topic_item_id'],
        topic_item_name = json['topic_item_name'],
        module_type_id = json['module_type_id'],
        seq_sort = json['seq_sort'];

  Map toJson() => {
        "topic_id": topic_id,
        "topic_name": topic_name,
        "topic_item_id": topic_item_id,
        "topic_item_name": topic_item_name,
        "module_type_id": module_type_id,
        "seq_sort": seq_sort,
      };
}
