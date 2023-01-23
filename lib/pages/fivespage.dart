import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class FivesPage extends StatelessWidget {
  List<_SalesData> data = [
    _SalesData('มค.', 1),
    _SalesData('กพ.', 3),
    _SalesData('มีค.', 10),
    _SalesData('เมย.', 4),
    _SalesData('พค.', 8)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'กิจกรรม 5 ส',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(children: <Widget>[
        SizedBox(
          height: 10,
        ),
        //Initialize the chart widget

        Expanded(
          flex: 2,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(children: <Widget>[
              SfCircularChart(
                  // primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(text: 'CAR'),
                  // Enable legend
                  legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    position: LegendPosition.bottom,
                  ),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CircularSeries<_SalesData, String>>[
                    DoughnutSeries<_SalesData, String>(
                        dataSource: data,
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        // name: 'Sales',
                        // Enable data label
                        dataLabelSettings: DataLabelSettings(isVisible: true))
                  ]),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "99",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        Text("CAR ทั้งหมด"),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 2,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "5",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "CAR คงค้าง",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [Text("")],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "อันดับ 5 ส. ล่าสุด",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                ],
              )
              // Row(
              //   children: <Widget>[
              //     GestureDetector(
              //       onTap: () {},
              //       child: Container(
              //         color: Colors.grey.withOpacity(0.15),
              //         height: 60,
              //         width: MediaQuery.of(context).size.width,
              //         child: Row(children: [
              //           Expanded(
              //             child: Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Text("แผนการตรวจ"),
              //             ),
              //           ),
              //           Expanded(
              //             child: Align(
              //                 alignment: Alignment.centerRight,
              //                 child: Icon(Icons.arrow_right)),
              //           ),
              //         ]),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 1,
              // ),
              // Row(
              //   children: <Widget>[
              //     GestureDetector(
              //       onTap: () {},
              //       child: Container(
              //         color: Colors.grey.withOpacity(0.15),
              //         height: 60,
              //         width: MediaQuery.of(context).size.width,
              //         child: Row(children: [
              //           Expanded(
              //             child: Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Text("ตรวจ"),
              //             ),
              //           ),
              //           Expanded(
              //             child: Align(
              //                 alignment: Alignment.centerRight,
              //                 child: Icon(Icons.arrow_right)),
              //           ),
              //         ]),
              //       ),
              //     ),
              //   ],
              // ),
            ]),
          ),
        )
      ]),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
