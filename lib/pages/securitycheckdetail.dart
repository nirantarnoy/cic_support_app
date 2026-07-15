import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_cic_support/models/securitycheckdatail.dart';
import 'package:flutter_cic_support/models/securitycheckedlist.dart';
import 'package:flutter_cic_support/pages/securitycheckphotoview.dart';
import 'package:flutter_cic_support/providers/securityplan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SecuritycheckDetailPage extends StatefulWidget {
  final String code;
  final String id;
  final String current_area_id;
  final String plan_id;
  SecuritycheckDetailPage({
    Key? key,
    required this.id,
    required this.code,
    required this.current_area_id,
    required this.plan_id,
  }) : super(key: key);

  @override
  State<SecuritycheckDetailPage> createState() =>
      _SecuritycheckDetailPageState();
}

class _SecuritycheckDetailPageState extends State<SecuritycheckDetailPage> {
  List<SecuritycheckedList> _checedlist = [];
  TextEditingController _remarkController = TextEditingController();

  late Future<XFile> file;
  List<File> image2 = [];
  List<String> base64ImageList = [];
  List<int> _deleteimage_selected = [];

  List<SecuritycheckDetail> check_list = [
    SecuritycheckDetail(
      id: "1",
      name: "สายฉีด",
      check_status: "",
    ),
    SecuritycheckDetail(
      id: "2",
      name: "คันบีบ",
      check_status: "",
    ),
    SecuritycheckDetail(
      id: "3",
      name: "ความดัน",
      check_status: "",
    ),
    SecuritycheckDetail(
      id: "4",
      name: "สิ่งกีดกวาง",
      check_status: "",
    ),
  ];

  _addtolist(String _topic_id, String _checkresult, String _index) {
    // print("on press me");
    Provider.of<SecurityplanData>(context, listen: false).addcheckedtopiclist(
        widget.id, _topic_id, _checkresult, _index, widget.current_area_id);
  }

  Widget _buildList(List<SecuritycheckDetail> listcheck) {
    Widget cardlist;
    if (listcheck.length > 0) {
      cardlist = ListView.builder(
          itemCount: listcheck.length,
          itemBuilder: (BuildContext contex, int index) {
            // int total_topic_counted =
            //     getAreacheckCount(listcheck[index].plan_area_id);
            String _ischecked_line =
                Provider.of<SecurityplanData>(context, listen: false)
                    .checkhaschecklist(
                        widget.id, listcheck[index].id, index.toString());

            Color _bgcolor = Colors.grey.shade300;
            Color _line_color = Colors.black;
            Icon _showIcon = Icon(Icons.question_mark_outlined);

            if (_ischecked_line != "") {
              // print("check has count data is ${_ischecked_line}");
              _bgcolor = Colors.green.shade50;
              if (_ischecked_line == "1") {
                _showIcon = Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                );
              } else {
                _showIcon = Icon(
                  Icons.error_outline_outlined,
                  color: Colors.red,
                );
              }
            }

            return Slidable(
              key: const ValueKey(0),
              enabled: true,
              // startActionPane: ActionPane(
              //   motion: const ScrollMotion(),
              //   // dismissible: DismissiblePane(onDismissed: () {}),
              //   children: [
              //     // SlidableAction(
              //     //   onPressed: doNothing,
              //     //   backgroundColor: Colors.green,
              //     //   foregroundColor: Colors.white,
              //     //   icon: Icons.check_circle,
              //     //   label: 'Yes',
              //     // ),
              //     // SlidableAction(
              //     //   onPressed: doNothing,
              //     //   backgroundColor: Colors.red,
              //     //   foregroundColor: Colors.white,
              //     //   icon: Icons.error,
              //     //   label: 'No',
              //     // ),
              //     // SlidableAction(
              //     //   onPressed: doNothing,
              //     //   backgroundColor: Colors.green,
              //     //   foregroundColor: Colors.white,
              //     //   icon: Icons.share,
              //     //   label: 'Share',
              //     // )
              //   ],
              // ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    key: const ValueKey(1),
                    onPressed: (BuildContext context) {
                      _addtolist(listcheck[index].id, "1", index.toString());
                    },
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.check_circle,
                    label: 'Yes',
                  ),
                  SlidableAction(
                    key: const ValueKey(2),
                    onPressed: (BuildContext context) {
                      _addtolist(listcheck[index].id, "0", index.toString());
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.error,
                    label: 'No',
                  ),
                  // SlidableAction(
                  //   // flex: 2,
                  //   // onPressed:
                  //   //     _removecheckeditem(listcheck[index].plan_area_id),
                  //   onPressed: (BuildContext context) {
                  //     print("you pressed meeee");
                  //     //  _removecheckeditem(listcheck[index].id);
                  //   },
                  //   backgroundColor: Colors.red,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.delete,
                  //   label: 'Clear',
                  // ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.red,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.delete,
                  //   label: 'Delete',
                  // ),
                  // SlidableAction(
                  //   onPressed: doNothing,
                  //   backgroundColor: Colors.green,
                  //   foregroundColor: Colors.white,
                  //   icon: Icons.share,
                  //   label: 'Share',
                  // )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                        color: _bgcolor,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: ListTile(
                      leading: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: Center(
                            child: Text(
                          "${(index + 1).toString()}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                      title: Text(
                        '${listcheck[index].name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _line_color,
                        ),
                      ),
                      trailing: _showIcon,
                      // subtitle: Text(
                      //     '${listcheck[index].section_name} : ${listcheck[index].location_name}'),
                      // trailing: Text(
                      //   "${total_topic_counted}/${total_topic}",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: _line_color,
                      //   ),
                      // ),
                    ),
                  ),
                  // onTap: () {
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (context) => SecuritycheckDetailPage(
                  //         id: listcheck[index].id,
                  //         code: listcheck[index].code,
                  //       ),
                  //     ),
                  //   );
                  // }
                ),
              ),
            );
          });
      return cardlist;
      //return Text('data');
    } else {
      return Text('No data');
    }
  }

  void doNothing(BuildContext context) {}
  doYes(index, check_status) {
    //setState(() {
    check_list[index].check_status = "Yes";
    //});
  }

  _submitform() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                color: Colors.red,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ต้องการบันทึกข้อมูลใช่หรือไม่ ?',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Colors.green.shade800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () async {
                        EasyLoading.show(status: "กำลังบันทึกข้อมูล");
                        bool res = await Provider.of<SecurityplanData>(context,
                                listen: false)
                            .submitSecuritycheck(
                                widget.id,
                                _remarkController.text,
                                base64ImageList,
                                widget.plan_id);
                        EasyLoading.dismiss();
                        if (res == true) {
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
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      'บันทึกรายการเรียบร้อย',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: MaterialButton(
                                            color: Colors.green.shade300,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'ตกลง',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                        }
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
  }

  Future chooseImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 60,
          // maxHeight: 400,
          // maxWidth: 400,
          preferredCameraDevice: CameraDevice.rear);

      if (image == null) return;
      final imageTemp = File(image.path);
      List<int> imageBytes = imageTemp.readAsBytesSync();

      setState(() {
        this.image2.add(imageTemp);
        this.base64ImageList.add(base64Encode(imageBytes));
      });
    } catch (err) {
      print("${err}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('${widget.code}'),
        actions: [
          IconButton(
              onPressed: () => chooseImage(), icon: Icon(Icons.camera_front)),
        ],
      ),
      body: Column(children: [
        Expanded(flex: 4, child: _buildList(check_list)),
        Expanded(
            flex: 1,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            "รูปภาพ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                        ],
                      ),
                      image2.length == 0
                          ? Center(child: Text('No Photo'))
                          : GestureDetector(
                              onTap: () => this.image2.length > 0
                                  ? _editBottomSheet(context, image2)
                                  : null,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 5),
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: this.image2.length > 0
                                        ? Colors.green
                                        : Colors.white),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "จำนวนรูป ${this.image2.length}",
                                      style: TextStyle(
                                        color: this.image2.length > 0
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    )),
                              ),
                            ),
                    ]),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(3),
            child: TextField(
              controller: _remarkController,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: 'คำอธิบายเพิ่มเติม',
                  labelText: 'คำอธิบายเพิ่มเติม'),
              onSubmitted: (value) {
                setState(() {
                  _remarkController.text = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => _submitform(),
            child: Container(
                height: 20,
                width: double.infinity,
                color: Colors.green,
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'บันทึกรายการ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ))),
          ),
        )
      ]),
    );
  }

  void _editBottomSheet(
    context,
    List<File> _image2,
  ) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              //  height: MediaQuery.of(context).size.height * 0.9,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Icon(
                      //   Icons.check,
                      //   color: Colors.green,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(' ** กดค้างที่รูปที่ต้องการลบ'),
                      ),
                      SizedBox(width: 10),
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.cancel,
                              color: Colors.orange, size: 25),
                          onPressed: () => Navigator.of(context).pop())
                    ],
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                          itemCount: _image2.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(children: [
                              Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onLongPress: () {
                                      if (_deleteimage_selected.length > 0) {
                                        if (_deleteimage_selected
                                            .contains(index)) {
                                          setState(() {
                                            _deleteimage_selected.removeWhere(
                                                (item) => item == index);
                                          });
                                        } else {
                                          setState(() {
                                            _deleteimage_selected.add(index);
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _deleteimage_selected.add(index);
                                        });
                                      }
                                      print(_deleteimage_selected);
                                    },
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SecuritycheckphotoviewPage(
                                                      carphoto: _image2)));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(_image2[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _deleteimage_selected.contains(index)
                                  ? Positioned(
                                      top: 0,
                                      right:
                                          0, //give the values according to your requirement
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Text(''),
                            ]);
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _deleteimage_selected.length <= 0
                          ? Text('')
                          : GestureDetector(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade400,
                                ),
                                child: Center(
                                  child: Text(
                                    "ลบ ${_deleteimage_selected.length} รูป",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                _deleteimage_selected.forEach((element) {
                                  this.setState(() {
                                    // set main state outside bottomsheet
                                    base64ImageList.removeAt(element);
                                    image2.removeAt(element);
                                  });
                                });
                                setState(() {
                                  _deleteimage_selected.clear();
                                });
                                if (_image2.length <= 0) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
