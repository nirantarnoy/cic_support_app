import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SecurityPointPage extends StatefulWidget {
  const SecurityPointPage({Key? key}) : super(key: key);

  @override
  State<SecurityPointPage> createState() => _SecurityPointPageState();
}

class _SecurityPointPageState extends State<SecurityPointPage> {
  final Map<String, dynamic> _formData = {
    'point_no': null,
    'point_latlong': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController pointNoText = TextEditingController();

  // Future<Position> _getGeoLocationPosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     await Geolocator.openLocationSettings();
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }

  // Future<String> _currentlocation() async {
  //   Position position = await _getGeoLocationPosition();
  //   //String location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
  //   String location = '${position.latitude},${position.longitude}';
  //   // print('my location is ${location}');
  //   return location;
  // }

  Widget buildPointNoField() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black45,
              ),
              border: InputBorder.none,
              hintText: 'จุดที่'),
          controller: pointNoText,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 1) {
              return 'กรอกหมายเลขจุดก่อนนะ';
            }
          },
          onSaved: (String? value) {
            _formData['point_no'] = value;
          },
        ),
      ),
    );
  }

  Widget buildLatlongField() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black45,
              ),
              border: InputBorder.none,
              hintText: 'LatLong'),
          controller: pointNoText,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 1) {
              return 'กรอก LatLong';
            }
          },
          onSaved: (String? value) {
            _formData['point_latlong'] = value;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ข้อมูลจุดตรวจ')),
      body: Column(children: [
        SizedBox(
          height: 15,
        ),
        buildPointNoField(),
        SizedBox(
          height: 5,
        ),
        buildLatlongField(),
        SizedBox(
          height: 5,
        ),
        ElevatedButton(onPressed: () {}, child: Text('ดึงข้อมูลพื้นที่'))
      ]),
    );
  }
}
