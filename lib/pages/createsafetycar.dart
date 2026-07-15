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

class CreateSafetyCar extends StatefulWidget {
  final String plan_area_id;
  final String plan_area_name;
  const CreateSafetyCar(
      {Key? key, required this.plan_area_id, required this.plan_area_name})
      : super(key: key);

  @override
  State<CreateSafetyCar> createState() => _CreateSafetyCarState();
}

class _CreateSafetyCarState extends State<CreateSafetyCar> {
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
      cursorColor: const Color(0xFF0F9B73),
      textAlign: TextAlign.left,
      controller: _cardateText,
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
      style: const TextStyle(fontFamily: 'Prompt', fontSize: 14),
      decoration: InputDecoration(
        labelText: 'วันที่ตรวจพบ',
        labelStyle: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade600),
        hintStyle: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        isDense: true,
        hintText: 'เลือกวันที่',
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFF0F9B73), width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        prefixIcon: Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 20),
      ),
      validator: (String? value) {
        if (value!.isEmpty || value.length < 1) {
          return 'กรุณาเลือกวันที่';
        }
        return null;
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
      style: const TextStyle(fontFamily: 'Prompt', fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'แผนก/พื้นที่',
        labelStyle: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade600),
        hintStyle: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        isDense: true,
        hintText: 'พื้นที่ตรวจ',
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFF0F9B73), width: 1.5),
        ),
        prefixIcon: Icon(Icons.location_on_rounded, color: Colors.grey.shade400, size: 20),
      ),
    );
  }

  Widget _builddescriptionText() {
    return TextFormField(
      textAlign: TextAlign.left,
      controller: _cardescriptionText,
      maxLines: 4,
      style: const TextStyle(fontFamily: 'Prompt', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'ระบุรายละเอียดปัญหาและข้อบกพร่อง...',
        hintStyle: TextStyle(fontFamily: 'Prompt', color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.all(16),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFF0F9B73), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildProblemTypelist(List<ProblemType> _listproblemtype) {
    if (_listproblemtype.isNotEmpty) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _listproblemtype.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final isChecked = _isProblemtypeChecked[index];
          return Container(
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF0F9B73).withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isChecked ? const Color(0xFF0F9B73) : Colors.grey.shade200,
                width: isChecked ? 1.5 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: isChecked,
              selected: isChecked,
              activeColor: const Color(0xFF0F9B73),
              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              title: Text(
                _listproblemtype[index].name,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
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
        },
      );
    } else {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No Data', style: TextStyle(fontFamily: 'Prompt')),
        ),
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
    if (problemtypeSelected != '') {
      EasyLoading.show(status: "กำลังบันทึก");
      bool isSave = await Provider.of<CarData>(context, listen: false).addCar(
        _cardateText.text,
        _selectedAreaId,
        problemtypeSelected,
        _cardescriptionText.text,
        nonconformSelected,
        base64ImageList,
        2,
      );
      EasyLoading.dismiss();
      if (isSave == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CarcompletePage()));
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Icons.mood_bad_outlined,
                  size: 32,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'พบข้อผิดพลาด',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                  child: Text(
                    'กรุณาตรวจสอบการเลือกหัวข้อไม่สอดคล้องและประเภทปัญหา ?',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MaterialButton(
                        color: Colors.red.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onPressed: () {
                          Navigator.of(context).pop(false);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ออกใบ CAR Safety',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          image2.length > 3
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () => chooseImage(),
                  icon: const Icon(Icons.add_a_photo_outlined, color: Colors.black87),
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDatepicker(),
                              const SizedBox(height: 16),
                              _buildareaText(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            "พบว่าเป็นปัญหา / Issue Category",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildProblemTypelist(_listproblemtype),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            "รูปภาพแนบ / Photos",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        image2.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_outlined, color: Colors.grey.shade300, size: 32),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'ยังไม่ได้เลือกรูปภาพ / No Photos Selected',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () => image2.isNotEmpty
                                    ? _editBottomSheet(context, image2)
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF0F9B73),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "จำนวนรูปภาพที่เลือก: ${image2.length} รูป (แตะเพื่อจัดการ)",
                                      style: const TextStyle(
                                        fontFamily: 'Prompt',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            "พบปัญหาและข้อบกพร่องดังนี้ / Description",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _builddescriptionText(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F9B73).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => submitform(),
                    child: const Center(
                      child: Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
