import 'package:flutter/material.dart';

class Person {
  final String id;
  final String person_name;
  final String team_id;
  final String bigclean_team_id;
  final String? emp_key;

  Person({
    required this.id,
    required this.person_name,
    required this.team_id,
    required this.bigclean_team_id,
    this.emp_key,
  });
}
