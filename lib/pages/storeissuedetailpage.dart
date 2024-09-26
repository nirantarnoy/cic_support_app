import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/storeissueline.dart';
import 'package:flutter_cic_support/pages/storeissueapprove.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class StoreissuedetailPage extends StatefulWidget {
  final issue_id;
  StoreissuedetailPage({Key? key, this.issue_id}) : super(key: key);

  @override
  State<StoreissuedetailPage> createState() => _StoreissuedetailPageState();
}

class _StoreissuedetailPageState extends State<StoreissuedetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.issue_id != null) {
      EasyLoading.show(status: "Loading ....");
      Provider.of<StoreissueData>(context, listen: false)
          .fetchIssueline(widget.issue_id);
      EasyLoading.dismiss();
    }
  }

  Widget _buildDetail(List<Storeissueline> _list) {
    return _list.isEmpty
        ? Text('No data')
        : Container(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('รหัสสินค้า')),
                  DataColumn(label: Text('ชื่อสินค้า')),
                  DataColumn(label: Text('จำนวน')),
                  DataColumn(label: Text('หน่วย')),
                  DataColumn(label: Text('หมายเหตุ')),
                ],
                rows: _list
                    .map((e) => DataRow(cells: [
                          DataCell(Text(e.product_id)),
                          DataCell(Align(
                              alignment: Alignment.centerLeft,
                              child: Text(e.product_name))),
                          DataCell(Text(e.qty)),
                          DataCell(Text(e.unit_name)),
                          DataCell(Text(e.remark)),
                        ]))
                    .toList(),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดใบเบิก')),
      body: Column(children: [
        Expanded(
          flex: 6,
          child: Consumer<StoreissueData>(
            builder: (context, _value, _) => _buildDetail(_value.listIssueLine),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 12,
                          ),
                          Icon(
                            Icons.privacy_tip_outlined,
                            size: 32,
                            color: Colors.green.shade400,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'ยืนยันการทำรายการ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  color: Color.fromARGB(255, 45, 172, 123),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  onPressed: () async {
                                    //  _timer?.cancel();
                                    await EasyLoading.show(
                                        status: "กำลังบันทึกข้อมูล");
                                    bool isSave =
                                        await Provider.of<StoreissueData>(
                                                context,
                                                listen: false)
                                            .approveissue(1, widget.issue_id);
                                    if (isSave == true) {
                                      await EasyLoading.showSuccess(
                                          'บันทึกรายการเรียบร้อย');

                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             PlancheckcompletePage()));
                                    }
                                    EasyLoading.dismiss();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StoreissueApprovePage(
                                                  team_id: "",
                                                )),
                                        (Route<dynamic> route) => false);
                                  },
                                  child: Text(
                                    'ใช่',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                child: MaterialButton(
                                  color: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text(
                                    'ไม่ใช่',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.green,
                child: Center(child: Text('อนุมัติ')),
              ),
            )),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 12,
                              ),
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 32,
                                color: Colors.green.shade400,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ยืนยันการทำรายการ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: MaterialButton(
                                      color: Color.fromARGB(255, 45, 172, 123),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () async {
                                        //  _timer?.cancel();
                                        await EasyLoading.show(
                                            status: "กำลังบันทึกข้อมูล");
                                        bool isSave =
                                            await Provider.of<StoreissueData>(
                                                    context,
                                                    listen: false)
                                                .approveissue(
                                                    3, widget.issue_id);
                                        if (isSave == true) {
                                          await EasyLoading.showSuccess(
                                              'บันทึกรายการเรียบร้อย');

                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             PlancheckcompletePage()));
                                        }
                                        EasyLoading.dismiss();
                                        // Navigator.of(context)
                                        //     .pushAndRemoveUntil(
                                        //         MaterialPageRoute(
                                        //             builder: (context) =>
                                        //                 StoreissueApprovePage(
                                        //                   team_id: "",
                                        //                 )),
                                        //         (Route<dynamic> route) =>
                                        //             false);

                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoreissueApprovePage(
                                                          team_id: "",
                                                        )),
                                                (Route<dynamic> route) =>
                                                    false);
                                      },
                                      child: Text(
                                        'ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: MaterialButton(
                                      color: Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text(
                                        'ไม่ใช่',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                      color: Colors.red,
                      child: Center(child: Text('ไม่อนุมติ')))),
            )
          ]),
        ),
      ]),
    );
  }
}
