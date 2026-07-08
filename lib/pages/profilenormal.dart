import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/pages/ai_assistant_page.dart';
import 'package:flutter_cic_support/pages/bigcleanarea.dart';
import 'package:flutter_cic_support/widgets/draggable_fab.dart';

import 'package:flutter_cic_support/pages/carlistpage.dart';
import 'package:flutter_cic_support/pages/jobplanarea.dart';

import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/pages/jobcheck.dart';
import 'package:flutter_cic_support/pages/loginpage.dart';
import 'package:flutter_cic_support/pages/memberteam.dart';
import 'package:flutter_cic_support/pages/plan.dart';
import 'package:flutter_cic_support/pages/safetycheck.dart';
import 'package:flutter_cic_support/pages/safetyplanarea.dart';
import 'package:flutter_cic_support/pages/securitycheckarea.dart';
import 'package:flutter_cic_support/pages/shirtemp.dart';
import 'package:flutter_cic_support/pages/shirtorderinform.dart';
import 'package:flutter_cic_support/pages/storeissueapprove.dart';
import 'package:flutter_cic_support/providers/shirtemp.dart';
import 'package:flutter_cic_support/providers/teamnotify.dart';
// import 'package:flutter_cic_support/pages/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_cic_support/widgets/newswidget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:googleapis/mybusinesslodging/v1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNormalPage extends StatefulWidget {
  static const routeName = "profilenormal";
  const ProfileNormalPage({Key? key}) : super(key: key);

  @override
  State<ProfileNormalPage> createState() => _ProfileNormalPageState();
}

class _ProfileNormalPageState extends State<ProfileNormalPage> {
  String current_username = "";
  String display_url = "https://img.cicsupports.com/profile/";
  String display_photo = "";
  String display_section_code = "";

  int _uniform_selected = 0;
  String _emp_level = "0";

  late Future<XFile> file;
  List<File> image2 = [];
  List<String> base64ImageList = [];
  // Future<String> _displayname() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String username = prefs.getString("user_name").toString();
  //   return username;
  // }

  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<UserData>(context, listen: false).fetchProfile();
    // Provider.of<TeamnotifyData>(context, listen: false).teamnotifyFetch();
    current_username =
        Provider.of<UserData>(context, listen: false).getCurrenUserName();
    _emp_level =
        Provider.of<UserData>(context, listen: false).emplevel.toString();

    // display_section_code =
    //     Provider.of<UserData>(context, listen: false).getCurrenUserSection();

    super.initState();
  }

  Future chooseCameraImage() async {
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
        this.image2.clear(); // only one photo
        this.image2.add(imageTemp);
        this.base64ImageList.clear(); // only one photo
        this.base64ImageList.add(base64Encode(imageBytes));
      });
    } catch (err) {
      print("${err}");
    }
    Navigator.of(context).pop();
  }

  Future chooseGalleryImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
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
    Navigator.of(context).pop();
  }

  void _logoutaction(Function logout) async {
    Map<String, dynamic> sucessInformation;
    sucessInformation = await logout();
    if (sucessInformation['success']) {
      print('logout success');
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LoginPage()));
      //Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushNamedAndRemoveUntil(
          context, 'loginpage', (Route<dynamic> route) => false);
    }
  }

  void _logout(UserData users) {
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
                Icons.mood_bad_outlined,
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
                'ต้องการออกจากระบบใช่หรือไม่ ?',
                style: TextStyle(fontWeight: FontWeight.normal),
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
                        _logoutaction(users.logout);
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

  void _editBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'เลือกรูปโปรไฟล์จาก / Select photo from',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => chooseCameraImage(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.camera_alt_rounded, size: 36, color: Color(0xFF2DAC7B)),
                              SizedBox(height: 12),
                              Text('กล้องถ่ายรูป / Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => chooseGalleryImage(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.photo_library_rounded, size: 36, color: Color(0xFF2DAC7B)),
                              SizedBox(height: 12),
                              Text('คลังภาพ / Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _updatephotofrofil(BuildContext context) async {
    if (base64ImageList.isNotEmpty) {
      EasyLoading.show(status: "กำลังบันทึก");
      bool isSave = await Provider.of<UserData>(context, listen: false)
          .updatePhotoprofilenormal(
        base64ImageList,
      );
      EasyLoading.dismiss();
      if (isSave == true) {
        setState(() {
          print("successsssssssssssssss");
          Provider.of<UserData>(context, listen: false).fetchProfileNormal();
          image2.clear();
        });
      } else {
        print("nooooooooooooooooo");
        image2.clear();
      }
    }
  }

  Widget _buildEmployeeInfoItem({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            EasyLoading.showInfo('ระบบกำลังพัฒนา\nจะเปิดให้ใช้งานเร็วๆ นี้');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context);
    
    display_photo = user.getCurrenUserPhoto();
    display_photo = display_url + display_photo;

    display_section_code = user.getCurrenUserSection();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF073F2F),
        elevation: 0,
        title: const Text(
          'User Profile / ข้อมูลผู้ใช้งาน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            onPressed: () => _logout(user),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF073F2F), Color(0xFF1E8F68)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 16),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: image2.isNotEmpty
                                  ? FileImage(image2[0]) as ImageProvider
                                  : NetworkImage(display_photo),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editBottomSheet(context),
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2DAC7B),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.empfullname,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (user.emppositionname.isNotEmpty || user.emp_department_name.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${user.emppositionname}${user.emppositionname.isNotEmpty && user.emp_department_name.isNotEmpty ? " • " : ""}${user.emp_department_name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (image2.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () => _updatephotofrofil(context),
                              icon: const Icon(Icons.check_circle_outline, size: 16),
                              label: const Text('Update Photo'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                setState(() {
                                  image2.clear();
                                  base64ImageList.clear();
                                });
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
                  child: Row(
                    children: [
                      const Text(
                        'ข้อมูลพนักงาน',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          'ยังไม่เปิดใช้งาน',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildEmployeeInfoItem(
                        icon: Icons.local_hospital_rounded,
                        color: Colors.red.shade400,
                        title: 'สถานพยาบาล',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.school_rounded,
                        color: Colors.blue.shade400,
                        title: 'อบรม',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.date_range_rounded,
                        color: Colors.purple.shade400,
                        title: 'เช็ควันลา',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.health_and_safety_rounded,
                        color: Colors.green.shade400,
                        title: 'ตรวจสุขภาพ',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.orange.shade400,
                        title: 'เงินกู้สวัสดิการ',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      if (_emp_level != "3")
                        Column(
                          children: [
                            _buildMenuCard(
                              icon: Icons.approval_rounded,
                              iconColor: Colors.green,
                              title: 'อนุมัติใบเบิก',
                              subtitle: 'ตรวจสอบและอนุมัติใบเบิกวัสดุอุปกรณ์',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const StoreissueApprovePage(
                                    team_id: '',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuCard(
                              icon: Icons.fire_extinguisher_rounded,
                              iconColor: Colors.red,
                              title: 'ตรวจถังดับเพลิง',
                              subtitle: 'บันทึกการตรวจสอบความปลอดภัยของถังดับเพลิง',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SecuritycheckAreaPage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      _buildMenuCard(
                        icon: Icons.accessibility_new_rounded,
                        iconColor: Colors.blue,
                        title: 'ระบุเบอร์เสื้อ',
                        subtitle: 'บันทึกข้อมูลและเลือกขนาดเสื้อเครื่องแบบพนักงาน',
                        onTap: () async {
                          await Provider.of<ShirtempData>(context, listen: false).fetchEmpuniform();
                          _uniform_selected = Provider.of<ShirtempData>(context, listen: false).shirtselected;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ShirtempPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                  child: Text(
                    'กิจกรรม/ข่าวสาร',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: newswidget(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          DraggableFAB(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIAssistantPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
