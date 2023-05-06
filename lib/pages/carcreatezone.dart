import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobplanareasaved.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:provider/provider.dart';

class CarcreateZone extends StatefulWidget {
  @override
  State<CarcreateZone> createState() => _CarcreateZoneState();
}

class _CarcreateZoneState extends State<CarcreateZone> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<PlanData>(context, listen: false).fetchJobplanSaved();
    super.initState();
  }

  Widget _buildlist(List<JobplanAreaSaved> list) {
    Widget _card;
    if (list.isNotEmpty) {
      _card = ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCar(
                      plan_area_id: list[index].plan_area_id,
                      plan_area_name: list[index].plan_area_name),
                ),
              ),
              child: Card(
                child: ListTile(
                  title: Text('${list[index].plan_area_name}'),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            );
          });
      return _card;
    } else {
      return Center(
        child: Text('ไม่พบข้อมูล'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกแผนก'),
        backgroundColor: Color.fromARGB(153, 161, 12, 24),
      ),
      body: Container(
        child: Column(children: [
          Expanded(
            child: Consumer<PlanData>(
              builder: (contex, _data, _) =>
                  _buildlist(_data.listJobplanAreaSaved),
            ),
          ),
        ]),
      ),
    );
  }
}
