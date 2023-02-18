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
    Widget _items;
    if (!_carphoto.isEmpty) {
      _items = ListView.separated(
        itemCount: _carphoto.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          // print(
          //     'car image list is http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}');
          String image_url =
              'http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}';
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CarphotoCloseviewPage(carphoto_url: image_url))),
            child: SizedBox(
              height: 100,
              width: 100,
              child: Image.network(
                "http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}",
                fit: BoxFit.fill,
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 5.0,
          );
        },
      );
    } else {
      _items = Text('No Data');
    }

    return _items;
  }

  Widget _buildcarclosephoto(List<CarClosePhotoList> _carphoto) {
    Widget _items;
    if (!_carphoto.isEmpty) {
      _items = ListView.separated(
        itemCount: _carphoto.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          // print(
          //     'car image list is http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}');
          String image_url =
              'http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}';
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CarphotoCloseviewPage(carphoto_url: image_url))),
            child: SizedBox(
              height: 100,
              width: 100,
              child: Image.network(
                "http://172.16.0.231/cicsupport/backend/web/uploads/${_carphoto[index].image}",
                fit: BoxFit.fill,
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 5.0,
          );
        },
      );
    } else {
      _items = Text('No Data');
    }

    return _items;
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

  @override
  Widget build(BuildContext context) {
    print("is open is ${is_load_open}");
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
    String aStr = widget.car_non_conform.replaceAll(new RegExp(r'[^0-9]'), '');
    // print("string replace is ${aStr}");
    // print("string replace lenght is ${aStr.length}");
    // for (var i = 0; i <= aStr.length; i++) {
    //   String x = aStr.substring(1, i);
    //   print("split string is ${x}");
    // }

    bool isWeb = GetPlatform.isWeb;
    // if (isWeb) {
    //   //print("this is web");
    // } else {
    //   //print("not web");
    // }
    List<String> xx = aStr.split("");
    // print("sr is ${xx}");
    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดใบ CAR"),
        backgroundColor: Color.fromARGB(153, 161, 12, 24),
        actions: <Widget>[
          widget.car_status != "2"
              ? Text("")
              : IconButton(
                  onPressed: () => chooseImage(),
                  icon: Icon(Icons.add_a_photo_outlined))
        ],
      ),
      body: Column(children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "เลขที่",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.car_no}',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("วันที่",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        "${dateFormatter.format(DateTime.parse(widget.car_date))}",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("แผนก/พื้นที่",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.area_name}",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("พบปัญหาและข้อบกพร่องดังนี้",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: _getIsnew(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("รายละเอียด",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.car_description}",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("ไม่สอดคล้องตามมาตรฐานในหัวข้อ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: _getNoncomformName(xx),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("ผู้รับผิดชอบ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.responsibility}",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("กำหนดเสร็จ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.target_finish_date}",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 4,
            child: Column(
              children: [
                Text('รูปภาพ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(
                  height: 10,
                ),
                Consumer<CarData>(
                  builder: ((context, _car, child) => _car.listcarphoto.length >
                          0
                      ? Consumer<CarData>(
                          builder: ((context, _car, child) => _car
                                      .listcarphoto.length >
                                  0
                              ? Container(
                                  padding: EdgeInsets.all(4),
                                  width: double.infinity,
                                  height: 100,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: _buildcarphoto(_car.listcarphoto)))
                              : Center(
                                  child: Text('No Photo'),
                                )),
                        )
                      : Center(
                          child: Text('No Photo'),
                        )),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('รูปภาพปิด CAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                Consumer<CarData>(
                  builder: ((context, _car, child) =>
                      _car.listcarclosephoto.length > 0
                          ? Consumer<CarData>(
                              builder: ((context, _car, child) =>
                                  _car.listcarphoto.length > 0
                                      ? Container(
                                          padding: EdgeInsets.all(4),
                                          width: double.infinity,
                                          height: 100,
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: _buildcarclosephoto(
                                                  _car.listcarclosephoto)))
                                      : Center(
                                          child: Text(''),
                                        )),
                            )
                          : Center(
                              child: Text('No Photo'),
                            )),
                ),
                image2.length == 0
                    ? imageweb2.length > 0
                        ? GestureDetector(
                            onTap: () => this.imageweb2.length > 0
                                ? _editBottomSheetWeb(context, imageweb2, isWeb)
                                : null,
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 5),
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: this.imageweb2.length > 0
                                      ? Colors.green
                                      : Colors.white),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "จำนวนรูป ${this.imageweb2.length}",
                                    style: TextStyle(
                                      color: this.imageweb2.length > 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  )),
                            ),
                          )
                        : Center(
                            child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No Photo'),
                          ))
                    : GestureDetector(
                        onTap: () => this.image2.length > 0
                            ? _editBottomSheet(context, image2)
                            : null,
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 5),
                          height: 50,
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
              ],
            )),
        Expanded(
          flex: 1,
          child: widget.car_status == "2"
              ? Container(
                  height: 40,
                  alignment: Alignment.center,
                  color: Color.fromARGB(255, 45, 172, 123),
                  child: GestureDetector(
                    onTap: () => showDialog(
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
                                Icons.mood_outlined,
                                size: 32,
                                color: Colors.green,
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
                                'ต้องการทำการปิดใบ CAR นี้ใช่หรือไม่ ?',
                                style: TextStyle(fontWeight: FontWeight.normal),
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
                                      // onPressed: () async {
                                      //   Navigator.of(context)
                                      //       .popUntil((route) => route.isFirst);
                                      // },
                                      onPressed: () => _closecar(),
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
                    ),
                    child: Text(
                      'ปิดใบ CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Text(""),
        ),
      ]),
    );
  }
}
