import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/carlist.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:provider/provider.dart';

class CarlistPage extends StatefulWidget {
  const CarlistPage({Key? key}) : super(key: key);

  @override
  State<CarlistPage> createState() => _CarlistPageState();
}

class _CarlistPageState extends State<CarlistPage> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<CarData>(context, listen: false).getCarlistByEmpId();
    super.initState();
  }

  Widget _buildcarlist(List<CarList> listcar) {
    Widget cards;
    if (listcar.length > 0) {
      cards = ListView.builder(
          itemCount: listcar.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('${listcar[index].area_name}'),
            );
          });
      return cards;
    } else {
      return Center(
        child: Text("No Data"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายการใบ CAR"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateCar(
                            plan_area_id: '',
                            plan_area_name: '',
                          ))),
              icon: Icon(Icons.add_outlined))
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Consumer<CarData>(
                builder: ((context, value, _) =>
                    _buildcarlist(value.listcaritem)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
