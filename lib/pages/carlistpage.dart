import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/carlist.dart';
import 'package:flutter_cic_support/pages/cardetail.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class CarlistPage extends StatefulWidget {
  const CarlistPage({Key? key}) : super(key: key);

  @override
  State<CarlistPage> createState() => _CarlistPageState();
}

class _CarlistPageState extends State<CarlistPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<CarData>(context, listen: false).getCarlistByEmpId();
    Provider.of<PlanData>(context, listen: false).fetchNonconformTitle();
    EasyLoading.dismiss();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);

    super.initState();
  }

  Widget _buildcarlist(List<CarList> listcar, String status) {
    Widget cards;
    if (listcar.isNotEmpty) {
      List<CarList> _listcar = [];

      listcar.forEach((element) {
        if (element.status == status) {
          CarList _item = CarList(
            area_id: element.area_id,
            area_name: element.area_name,
            car_date: element.car_date,
            car_id: element.car_id,
            car_no: element.car_no,
            description: element.description,
            module_type_id: element.module_type_id,
            problem_type: element.problem_type,
            status: element.status,
            is_new: element.is_new,
            target_finish_date: element.target_finish_date,
            responsibility: element.responsibility,
            car_non_conform: element.car_non_conform,
          );

          _listcar.add(_item);
        }
      });

      if (_listcar.isNotEmpty) {
        cards = ListView.builder(
            itemCount: _listcar.length,
            itemBuilder: (BuildContext context, int index) {
              String status_name =
                  _listcar[index].status == "1" ? "Pending" : "Open";
              Color status_color =
                  _listcar[index].status == "1" ? Colors.orange : Colors.green;

              return GestureDetector(
                child: Card(
                  child: ListTile(
                    title: Text(
                        '${_listcar[index].car_no} ${_listcar[index].area_name}'),
                    subtitle: Text(
                        '${_listcar[index].description} \n ${_listcar[index].car_date}'),
                    trailing: Text(
                      "${status_name}",
                      style: TextStyle(color: status_color),
                    ),
                  ),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CarDetailPage(
                              car_id: _listcar[index].car_id,
                              area_id: _listcar[index].area_id,
                              area_name: _listcar[index].area_name,
                              car_date: _listcar[index].car_date,
                              car_no: _listcar[index].car_no,
                              car_description: _listcar[index].description,
                              is_new: _listcar[index].is_new,
                              target_finish_date:
                                  _listcar[index].target_finish_date,
                              responsibility: _listcar[index].responsibility,
                              car_non_conform: _listcar[index].car_non_conform,
                              car_status: _listcar[index].status,
                            ))),
              );
            });
      } else {
        cards = Center(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(""),
              ),
              Expanded(
                flex: 3,
                child: Column(children: [
                  Icon(
                    Icons.block,
                    size: 50,
                    color: Color.fromARGB(255, 45, 172, 123),
                  ),
                  Center(
                      child: Text(
                    'ไม่พบรายการตรวจ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  )),
                ]),
              ),
              Expanded(
                flex: 2,
                child: Text(""),
              ),
            ],
          ),
        );
      }

      return cards;
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(""),
            ),
            Expanded(
              flex: 3,
              child: Column(children: [
                Icon(
                  Icons.block,
                  size: 50,
                  color: Color.fromARGB(255, 45, 172, 123),
                ),
                Center(
                    child: Text(
                  'ไม่พบรายการตรวจ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                )),
              ]),
            ),
            Expanded(
              flex: 2,
              child: Text(""),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายการใบ CAR"),
        backgroundColor: Color.fromARGB(153, 161, 12, 24),
        // actions: [
        //   IconButton(
        //       onPressed: () => Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => CreateCar(
        //                     plan_area_id: '',
        //                     plan_area_name: '',
        //                   ))),
        //       icon: Icon(Icons.add_outlined))
        // ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              // icon: Icon(Icons.list_outlined),
              text: "รอดำเนินการ",
            ),
            Tab(
              //icon: Icon(Icons.calendar_month),
              text: "คงค้าง",
            ),
            Tab(
              text: "ดำเนินการแล้ว",
            )
          ],
        ),
      ),
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(
              child: Consumer<CarData>(
                builder: ((context, value, _) =>
                    _buildcarlist(value.listcaritem, "1")),
              ),
            ),
            Container(
              child: Consumer<CarData>(
                builder: ((context, value, _) =>
                    _buildcarlist(value.listcaritem, "2")),
              ),
            ),
            Container(
              child: Consumer<CarData>(
                builder: ((context, value, _) =>
                    _buildcarlist(value.listcaritem, "3")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
