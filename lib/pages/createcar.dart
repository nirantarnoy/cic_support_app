import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/nonconformselected.dart';
import 'package:flutter_cic_support/models/nonconformtitle.dart';
import 'package:flutter_cic_support/models/problemtype.dart';
import 'package:flutter_cic_support/pages/carcomplete.dart';
import 'package:flutter_cic_support/pages/carphotoview.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateCar extends StatefulWidget {
  final String plan_area_id;
  final String plan_area_name;
  const CreateCar(
      {Key? key, required this.plan_area_id, required this.plan_area_name})
      : super(key: key);

  @override
  State<CreateCar> createState() => _CreateCarState();
}

class _CreateCarState extends State<CreateCar> {
  final Map<String, dynamic> _formData = {
    'car_date': null,
    'department_id': null,
    'description': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardateText = TextEditingController();
  final TextEditingController _cardepartmentText = TextEditingController();
  final TextEditingController _cardescriptionText = TextEditingController();

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
  DateTime _date = DateTime.now();
  bool _selected = false;
  List<bool> _isNonconformChecked = [];
  List<bool> _isProblemtypeChecked = [];
  String _selectedAreaId = "3";
  String problemtypeSelected = '';
  List<NonconformSelected> nonconformSelected = [];

  late Future<XFile> file;
  List<File> image2 = [];
  List<String> base64ImageList = [];

  List<int> _deleteimage_selected = [];

  List<ProblemType> _listproblemtype = [
    ProblemType(id: "1", name: "ปัญหาใหม่(CAR ใหม่)"),
    ProblemType(id: "2", name: "ปัญหาเก่า(CAR ซ้ำ)"),
  ];

  @override
  void initState() {
    Provider.of<PlanData>(context, listen: false).fetchNonconformTitle();
    _cardateText.text = dateFormatter.format(_date).toString();
    _selectedAreaId = widget.plan_area_id;
    _cardepartmentText.text = widget.plan_area_name;
    _isNonconformChecked = List<bool>.filled(10, false);
    _isProblemtypeChecked = List<bool>.filled(2, false);

    super.initState();
  }

  Widget _buildDatepicker() {
    return TextFormField(
      cursorColor: Colors.green,
      textAlign: TextAlign.left,
      controller: _cardateText,
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
      decoration: InputDecoration(
        labelText: 'วันที่',
        contentPadding: EdgeInsets.only(
          top: 20,
        ),
        isDense: true,
        hintText: 'เลือกวันที่',
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.calendar_today_sharp),
        ),
      ),
      validator: (String? value) {
        if (value!.isEmpty || value.length < 1) {
          return 'กรุณาเลือกวันที่';
        }
      },
      onSaved: (String? value) {
        _formData['car_date'] = value;
      },
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime? _datePicker = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1947),
        lastDate: DateTime(2030));

    if (_datePicker != null && _datePicker != _date) {
      setState(() {
        _date = _datePicker;
        _cardateText.text = dateFormatter.format(_date).toString();
        _formData['car_date'] = dateFormatter.format(_date).toString();
      });
    }
  }

  Widget _buildareaText() {
    return TextFormField(
      textAlign: TextAlign.left,
      controller: _cardepartmentText,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'พื้นที่',
        contentPadding: EdgeInsets.only(
          top: 20,
        ),
        isDense: false,
        hintText: 'พื้นที่ตรวจ',
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.location_on),
        ),
      ),
    );
  }

  Widget _builddescriptionText() {
    return TextFormField(
      textAlign: TextAlign.left,
      controller: _cardescriptionText,
      maxLines: 5,
      decoration: InputDecoration(
        // labelText: 'รายละเอียด',
        contentPadding: EdgeInsets.only(
          top: 20,
        ),
        isDense: false,
        //hintText: 'รายละเอียด',
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildNonconformlist(List<NonConformTitle> _listcheck) {
    Widget cards;
    if (_listcheck.length > 0) {
      cards = ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          //    scrollDirection: Axis.vertical,
          itemCount: _listcheck.length,
          itemBuilder: (BuildContext context, int index) {
            //  return Text('${_listcheck[index].name}');
            return GestureDetector(
              child: CheckboxListTile(
                value: _isNonconformChecked[index],
                selected: _isNonconformChecked[index],
                title: Text('${_listcheck[index].name}'),
                onChanged: (bool? value) {
                  setState(() {
                    _isNonconformChecked[index] = value!;
                    if (value == true) {
                      NonconformSelected item = NonconformSelected(
                          id: _listcheck[index].id,
                          name: _listcheck[index].name);
                      nonconformSelected.add(item);
                    } else {
                      nonconformSelected.forEach((element) {
                        if (element.id == _listcheck[index].id) {
                          nonconformSelected.removeWhere(
                              (items) => items.id == _listcheck[index].id);
                        }
                      });
                    }

                    print('nonconformselecred is ${nonconformSelected}');
                  });
                },
              ),
            );
          });
      return cards;
    } else {
      return Center(
        child: Text('No Data'),
      );
    }
  }

  Widget _buildProblemTypelist(List<ProblemType> _listproblemtype) {
    Widget cards;
    if (_listproblemtype.length > 0) {
      cards = ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          //    scrollDirection: Axis.vertical,
          itemCount: _listproblemtype.length,
          itemBuilder: (BuildContext context, int index) {
            //  return Text('${_listcheck[index].name}');
            return GestureDetector(
              child: CheckboxListTile(
                value: _isProblemtypeChecked[index],
                selected: _isProblemtypeChecked[index],
                title: Text('${_listproblemtype[index].name}'),
                onChanged: (bool? value) {
                  setState(() {
                    problemtypeSelected = _listproblemtype[index].id.toString();
                    _isProblemtypeChecked[index] = value!;
                    var i = 0;
                    _isProblemtypeChecked.forEach((element) {
                      if (i != index) {
                        _isProblemtypeChecked[i] = false;
                      }
                      i += 1;
                    });
                  });
                },
              ),
            );
          });
      return cards;
    } else {
      return Center(
        child: Text('No Data'),
      );
    }
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
                                                  CarphotoviewPage(
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

  Future submitform() async {
    if (nonconformSelected.length > 0 && problemtypeSelected != '') {
      EasyLoading.show(status: "กำลังบันทึก");
      bool isSave = await Provider.of<CarData>(context, listen: false).addCar(
        _cardateText.text,
        _selectedAreaId,
        problemtypeSelected,
        _cardescriptionText.text,
        nonconformSelected,
        base64ImageList,
      );
      EasyLoading.dismiss();
      if (isSave == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CarcompletePage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 172, 123),
      appBar: AppBar(
        title: Text('ออกใบ CAR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          image2.length > 3
              ? Text("")
              : IconButton(
                  onPressed: () => chooseImage(),
                  icon: Icon(Icons.add_a_photo_outlined))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  _buildDatepicker(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _buildareaText(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "ไม่สอดคล้องตามมาตรฐานในหัวข้อ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Consumer<PlanData>(
                                          builder: (context, _nonconform, _) =>
                                              _buildNonconformlist(_nonconform
                                                  .listofnonconform_5s())),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "พบว่าเป็นปัญหา",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildProblemTypelist(
                                            _listproblemtype)),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
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
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "พบปัญหาและข้อบกพร่องดังนี้",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                _builddescriptionText()
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Consumer<PlanData>(
                  //       builder: (context, _nonconform, _) =>
                  //           _buildNonconformlist(_nonconform.listnonconform)),
                  // ),
                ]),
              ),
            ),
          ),
          Container(
            height: 60,
            alignment: Alignment.center,
            color: Color.fromARGB(255, 45, 172, 123),
            child: GestureDetector(
              onTap: () => submitform(),
              child: Text(
                'บันทึกข้อมูล',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
