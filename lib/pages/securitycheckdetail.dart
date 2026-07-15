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
    if (listcheck.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: listcheck.length,
        itemBuilder: (BuildContext context, int index) {
          String _ischecked_line =
              Provider.of<SecurityplanData>(context, listen: false)
                  .checkhaschecklist(
                      widget.id, listcheck[index].id, index.toString());

          Color _iconColor = Colors.grey;
          Color _iconBgColor = Colors.grey.shade100;
          IconData _iconData = Icons.help_outline_rounded;
          String _statusText = "ยังไม่ได้ตรวจ";

          if (_ischecked_line != "") {
            if (_ischecked_line == "1") {
              _iconColor = const Color(0xFF0F9B73);
              _iconBgColor = const Color(0xFF0F9B73).withOpacity(0.1);
              _iconData = Icons.check_circle_rounded;
              _statusText = "ปกติ";
            } else {
              _iconColor = const Color(0xFFE53935);
              _iconBgColor = const Color(0xFFE53935).withOpacity(0.1);
              _iconData = Icons.cancel_rounded;
              _statusText = "ผิดปกติ";
            }
          }

          return Slidable(
            key: ValueKey(listcheck[index].id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    _addtolist(listcheck[index].id, "1", index.toString());
                  },
                  backgroundColor: const Color(0xFF0F9B73),
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline_rounded,
                  label: 'ปกติ',
                ),
                SlidableAction(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onPressed: (BuildContext context) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    _addtolist(listcheck[index].id, "0", index.toString());
                  },
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  icon: Icons.highlight_off_rounded,
                  label: 'ผิดปกติ',
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        color: _iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${listcheck[index].name}',
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _iconColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(_iconData, color: _iconColor, size: 24),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูลการตรวจ',
          style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
        ),
      );
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
      backgroundColor: const Color(0xFFF5F7FB),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.code,
          style: const TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => chooseImage(),
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildList(check_list),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "รูปภาพประกอบ",
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (image2.isNotEmpty)
                              GestureDetector(
                                onTap: () => _editBottomSheet(context, image2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F9B73)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${image2.length} รูป",
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F9B73),
                                    ),
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () => chooseImage(),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add_a_photo_rounded,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "เพิ่มรูปภาพ",
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _remarkController,
                          maxLines: 2,
                          style: const TextStyle(
                              fontFamily: 'Prompt', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'เพิ่มคำอธิบาย (ถ้ามี)...',
                            hintStyle: const TextStyle(
                                fontFamily: 'Prompt', color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              _remarkController.text = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F9B73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _submitform(),
                            child: const Text(
                              'บันทึกรายการตรวจ',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
