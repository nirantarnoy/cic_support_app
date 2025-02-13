import 'package:googleapis/youtube/v3.dart';

class SecuritycheckData {
  final String id;
  final String code;
  final String description;
  final String location_id;
  final String location_name;
  final String building_id;
  final String status;
  final String assign_emp_id;
  final String section_name;
  String checked_status;
  final String plan_id;

  SecuritycheckData({
    required this.id,
    required this.code,
    required this.description,
    required this.location_id,
    required this.location_name,
    required this.building_id,
    required this.status,
    required this.assign_emp_id,
    required this.section_name,
    required this.checked_status,
    required this.plan_id,
  });
}
