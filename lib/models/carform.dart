class CarForm {
  final String department_id;
  final String trans_date;
  final String area_id;
  final String car_description;
  final String problem_see_type;
  final String nonconform_type_id;
  late String? nonconform_text;
  final String car_inform_user;

  CarForm(
      {required this.department_id,
      required this.trans_date,
      required this.area_id,
      required this.car_description,
      required this.problem_see_type,
      required this.nonconform_type_id,
      this.nonconform_text,
      required this.car_inform_user});
}
