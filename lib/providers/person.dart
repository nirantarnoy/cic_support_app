import 'package:flutter/foundation.dart';
import 'package:flutter_cic_support/models/person.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonData extends ChangeNotifier {
  final String url_person_list = "http://172.16.0.231:8080/api/person";

  late List<Person> _person;
  List<Person> get listPerson => _person;

  set listPerson(List<Person> val) {
    _person = val;
  }

  Future<dynamic> fetchPerson() async {
    notifyListeners();

    try {
      http.Response response;
      response = await http.get(Uri.parse(url_person_list));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<Person> data = [];
        if (res == null) {
          print('no data');
        } else {
          // print("ok");
          for (var i = 0; i < res['data'].length; i++) {
            final Person personRes = Person(
              id: res['data'][i]['id'].toString(),
              person_name: res['data'][i]['ad_User'].toString(),
              team_id: res['data'][i]['team_id'].toString(),
            );
            data.add(personRes);
          }
          print('${data[0].person_name}');
          listPerson = data;
          return listPerson;
        }
      } else {
        print('error');
      }
    } catch (err) {
      print("error naja is ${err}");
    }
  }
}
