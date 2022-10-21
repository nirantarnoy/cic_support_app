class JobCheck {
  final String person_id;
  final String check_date;
  final String area_id;
  final String area_name;
  final String total_check_count;
  final String total_finish_check_count;

  final int seq_no;

  JobCheck({
    required this.person_id,
    required this.check_date,
    required this.area_id,
    required this.area_name,
    required this.total_check_count,
    required this.total_finish_check_count,
    required this.seq_no,
  });
}
