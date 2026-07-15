import 'dart:io';
// import 'package:universal_io/io.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_cic_support/models/carclosephotolist.dart';
import 'package:flutter_cic_support/models/carphotolist.dart';
import 'package:flutter_cic_support/pages/carcomplete.dart';
import 'package:flutter_cic_support/pages/carphotocloseview.dart';
import 'package:flutter_cic_support/pages/carphotoview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class CarDetailPage extends StatefulWidget {
  final String id;
  final String car_id;
  final String car_no;
  final String car_date;
  final String area_id;
  final String area_name;
  final String car_description;
  final String is_new;
  final String target_finish_date;
  final String responsibility;
  final String car_non_conform;
  final String car_status;
  const CarDetailPage({
    Key? key,
    required this.id,
    required this.car_id,
    required this.car_no,
    required this.car_date,
    required this.area_id,
    required this.area_name,
    required this.car_description,
    required this.is_new,
    required this.target_finish_date,
    required this.responsibility,
    required this.car_non_conform,
    required this.car_status,
  }) : super(key: key);
  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  // String txt = "[{'id': '2'},{'id': '3'},{'id': '4'}]";

  late Future<XFile> file;
  List<File> image2 = [];
  List<String> base64ImageList = [];

  List<int> _deleteimage_selected = [];
  List<int> _deleteimageweb_selected = [];

  int is_load_open = 0;
  int is_load_close = 0;

  Uint8List webImage = Uint8List(8);
  List<Uint8List> imageweb2 = [];

  @override
  void initState() {
    // TODO: implement initState
    // _getNonConform();
    Provider.of<CarData>(context, listen: false).getCarPhotoById(widget.car_id);
    Provider.of<CarData>(context, listen: false)
        .getCarClosePhotoById(widget.car_id);
    //_checkIsWeb();

    super.initState();
  }

  Future chooseImage() async {
    bool isWeb = GetPlatform.isWeb;
    if (!isWeb) {
      try {
        final image = await ImagePicker().pickImage(
            source: ImageSource.camera,
            imageQuality: 60,
            // maxHeight: 400,
            // maxWidth: 400,
            preferredCameraDevice: CameraDevice.rear);

        if (image == null) return;

        //print("not web");
        final imageTemp = File(image.path);
        List<int> imageBytes = imageTemp.readAsBytesSync();

        setState(() {
          this.image2.add(imageTemp);
          this.base64ImageList.add(base64Encode(imageBytes));
        });
      } catch (err) {
        print("${err}");
      }
    } else {
      print('you run app on web');
      XFile? imageweb = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        // maxHeight: 400,
        // maxWidth: 400,
      );
      if (imageweb == null) return;
      var imageBytes = await imageweb.readAsBytes();

      setState(() {
        this.imageweb2.add(imageBytes);
        this.base64ImageList.add(base64Encode(imageBytes));
      });
      print("image web lenght is ${imageweb2.length}");
    }
  }

  // Future<CameraImage> takePicture() async {
  //   final videoWidth = videoElement.videoWidth;
  //   final videoHeight = videoElement.videoHeight;
  //   final canvas = html.CanvasElement(
  //     width: videoWidth,
  //     height: videoHeight,
  //   );
  //   canvas.context2D
  //     ..translate(videoWidth, 0)
  //     ..scale(-1, 1)
  //     ..drawImageScaled(videoElement, 0, 0, videoWidth, videoHeight);
  //   final blob = await canvas.toBlob();
  //   return CameraImage(
  //     data: html.Url.createObjectUrl(blob),
  //     width: videoWidth,
  //     height: videoHeight,
  //   );
  // }

  Widget _getIsnew() {
    String isnewtext = '';
    if (widget.is_new == "1") {
      isnewtext = "ปัญหาใหม่";
    } else {
      isnewtext = "ปัญหาเดิม";
    }
    return Text(
      "${isnewtext}",
      style: TextStyle(fontSize: 15),
    );
  }

  void _checkIsWeb() {
    // if (kIsWeb) {
    //   print("running on the web!");
    // } else {
    //   print("running on  not the web naja");
    // }
    bool isWeb = GetPlatform.isWeb;
    if (isWeb) {
      print("this is web");
    } else {
      print("not web");
    }
  }

  void _getNonConform() {
    String aStr = "[{'id': '2'},{'id': '3'},{'id': '4'}]"
        .replaceAll(new RegExp(r'[^0-9]'), '');
    // print("string replace is ${aStr}");
    // print("string replace lenght is ${aStr.length}");
    // for (var i = 0; i <= aStr.length; i++) {
    //   String x = aStr.substring(1, i);
    //   print("split string is ${x}");
    // }
    List<String> xx = aStr.split("");
    // print("sr is ${xx}");
  }

  Widget _getNoncomformName(List<String> _string) {
    String _name = "";
    if (_string.isNotEmpty) {
      int x = 0;
      _string.forEach((element) {
        String _namex = Provider.of<PlanData>(context, listen: false)
            .getNonconformName(element);
        if (_namex != '') {
          if (x == 0) {
            _name = _namex;
          } else {
            _name = _name + "," + _namex;
          }
        }
        x += 1;
      });
    }

    return Text(
      _name,
      style: TextStyle(fontSize: 15),
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
                                    imageweb2.removeAt(element);
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

  void _editBottomSheetWeb(
    context,
    List<Uint8List> _image2,
    bool isWeb,
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
                                      if (_deleteimageweb_selected.length > 0) {
                                        if (_deleteimageweb_selected
                                            .contains(index)) {
                                          setState(() {
                                            _deleteimageweb_selected
                                                .removeWhere(
                                                    (item) => item == index);
                                          });
                                        } else {
                                          setState(() {
                                            _deleteimageweb_selected.add(index);
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _deleteimageweb_selected.add(index);
                                        });
                                      }
                                      print(_deleteimageweb_selected);
                                    },
                                    // onTap: () {
                                    //   Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //           builder: (context) =>
                                    //               CarphotoviewPage(
                                    //                   carphoto: _image2)));
                                    // },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(_image2[index],
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              _deleteimageweb_selected.contains(index)
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
                      child: _deleteimageweb_selected.length <= 0
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
                                    "ลบ ${_deleteimageweb_selected.length} รูป",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                _deleteimageweb_selected.forEach((element) {
                                  print("will delete index is ${element}");
                                  this.setState(() {
                                    // set main state outside bottomsheet
                                    base64ImageList.removeAt(element);
                                    imageweb2.removeAt(element);
                                  });
                                });
                                setState(() {
                                  _deleteimageweb_selected.clear();
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

  Widget _buildcarphoto(List<CarPhotoList> _carphoto) {
    if (_carphoto.isNotEmpty) {
      return ListView.separated(
        itemCount: _carphoto.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String image_url =
              'http://img.cicsupport.net/upload/${_carphoto[index].image}';
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CarphotoCloseviewPage(carphoto_url: image_url))),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image_url,
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8.0);
        },
      );
    } else {
      return const Center(child: Text('No Data', style: TextStyle(fontFamily: 'Prompt')));
    }
  }

  Widget _buildcarclosephoto(List<CarClosePhotoList> _carphoto) {
    if (_carphoto.isNotEmpty) {
      return ListView.separated(
        itemCount: _carphoto.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String image_url =
              'http://img.cicsupport.net/upload/${_carphoto[index].image}';
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CarphotoCloseviewPage(carphoto_url: image_url))),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image_url,
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8.0);
        },
      );
    } else {
      return const Center(child: Text('No Data', style: TextStyle(fontFamily: 'Prompt')));
    }
  }

  Future _closecar() async {
    bool isSave = await Provider.of<CarData>(context, listen: false)
        .closeCar(widget.car_id, 'Close', base64ImageList);

    if (isSave) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CarcompletePage()));
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
                    'กรุณาตรวจสอบการอีกครั้ง?',
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

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("is open is ${is_load_open}");
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
    String aStr = widget.car_non_conform.replaceAll(new RegExp(r'[^0-9]'), '');

    bool isWeb = GetPlatform.isWeb;
    List<String> xx = aStr.split("");

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
          "รายละเอียดใบ CAR",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          widget.car_status != "2"
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.015),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow("เลขที่ใบ CAR / CAR No.", widget.car_no),
                            _buildDetailRow(
                              "วันที่ตรวจพบ / Date Detected",
                              dateFormatter.format(DateTime.parse(widget.car_date)),
                            ),
                            _buildDetailRow("แผนก/พื้นที่ / Department & Area", widget.area_name),
                            _buildDetailRow("ประเภทปัญหา / Issue Status", _getIsnew()),
                            _buildDetailRow("รายละเอียดปัญหา / Description", widget.car_description),
                            _buildDetailRow("มาตรฐานหัวข้อที่ไม่สอดคล้อง / Nonconformity Section", _getNoncomformName(xx)),
                            _buildDetailRow("ผู้รับผิดชอบแก้ไข / Person in Charge", widget.responsibility),
                            _buildDetailRow("กำหนดส่งงานแก้ไข / Target Finish Date", widget.target_finish_date),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: Text(
                          'รูปภาพแนบขณะตรวจพบ / Detection Photos',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<CarData>(
                        builder: ((context, _car, child) => _car.listcarphoto.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: _buildcarphoto(_car.listcarphoto),
                              )
                            : Container(
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
                                    Text(
                                      'ไม่มีรูปภาพแนบ / No Photos',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: Text(
                          'รูปภาพหลังดำเนินการแก้ไข / Resolution Photos',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<CarData>(
                        builder: ((context, _car, child) => _car.listcarclosephoto.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: _buildcarclosephoto(_car.listcarclosephoto),
                              )
                            : Container(
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
                                    Icon(Icons.check_circle_outline_rounded, color: Colors.grey.shade300, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ยังไม่มีรูปภาพปิดงาน / No Resolution Photos',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ),
                      const SizedBox(height: 16),
                      image2.isEmpty
                          ? imageweb2.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => imageweb2.isNotEmpty
                                      ? _editBottomSheetWeb(context, imageweb2, isWeb)
                                      : null,
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 8),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF0F9B73),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "จำนวนรูปที่เลือก: ${imageweb2.length} รูป (แตะเพื่อจัดการ)",
                                        style: const TextStyle(
                                          fontFamily: 'Prompt',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () => image2.isNotEmpty
                                  ? _editBottomSheet(context, image2)
                                  : null,
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 8),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF0F9B73),
                                ),
                                child: Center(
                                  child: Text(
                                    "จำนวนรูปที่เลือก: ${image2.length} รูป (แตะเพื่อจัดการ)",
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            widget.car_status == "2"
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 40,
                                        color: Color(0xFF0F9B73),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'ยืนยันการทำรายการ',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'ต้องการทำการปิดใบ CAR นี้ใช่หรือไม่?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F9B73),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _closecar();
                                            },
                                            child: const Text(
                                              'ใช่',
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.black54,
                                              side: BorderSide(color: Colors.grey.shade300),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text(
                                              'ไม่ใช่',
                                              style: TextStyle(
                                                fontFamily: 'Prompt',
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
                          ),
                          child: const Center(
                            child: Text(
                              "ปิดใบ CAR",
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
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
