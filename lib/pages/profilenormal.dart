import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/storeissue.dart';

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
    required List<Color> gradientColors,
    required String title,
  }) {
    return Container(
      width: 95,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            EasyLoading.showInfo('ระบบกำลังพัฒนา\nจะเปิดให้ใช้งานเร็วๆ นี้');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Prompt',
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
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
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
                            fontSize: 14,
                            fontFamily: 'Prompt',
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Prompt',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
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
      backgroundColor: const Color(0xFFF5F7FB),
      resizeToAvoidBottomInset: false,
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
          'ข้อมูลผู้ใช้งาน / Profile',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            onPressed: () => _logout(user),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A2387),
                          Color(0xFFE94057),
                          Color(0xFFF27121),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE94057).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    backgroundImage: image2.isNotEmpty
                                        ? FileImage(image2[0]) as ImageProvider
                                        : NetworkImage(display_photo),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _editBottomSheet(context),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color(0xFFE94057),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.empfullname.isNotEmpty ? user.empfullname : current_username,
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (user.emppositionname.isNotEmpty || user.emp_department_name.isNotEmpty)
                                    Text(
                                      '${user.emppositionname}${user.emppositionname.isNotEmpty && user.emp_department_name.isNotEmpty ? " • " : ""}${user.emp_department_name}',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  if (display_section_code.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Section: $display_section_code',
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (image2.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFE94057),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  elevation: 0,
                                ),
                                onPressed: () => _updatephotofrofil(context),
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('บันทึกรูปภาพ', style: TextStyle(fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 12)),
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
                                label: const Text('ยกเลิก', style: TextStyle(fontFamily: 'Prompt', fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                  child: Row(
                    children: [
                      const Text(
                        'ข้อมูลพนักงาน',
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Prompt',
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
                            fontFamily: 'Prompt',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildEmployeeInfoItem(
                        icon: Icons.local_hospital_rounded,
                        gradientColors: [const Color(0xFFFF5252), const Color(0xFFFF1744)],
                        title: 'สถานพยาบาล',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.school_rounded,
                        gradientColors: [const Color(0xFF40C4FF), const Color(0xFF00B0FF)],
                        title: 'อบรม',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.date_range_rounded,
                        gradientColors: [const Color(0xFFE040FB), const Color(0xFFD500F9)],
                        title: 'เช็ควันลา',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.health_and_safety_rounded,
                        gradientColors: [const Color(0xFF69F0AE), const Color(0xFF00E676)],
                        title: 'ตรวจสุขภาพ',
                      ),
                      _buildEmployeeInfoItem(
                        icon: Icons.account_balance_wallet_rounded,
                        gradientColors: [const Color(0xFFFFAB40), const Color(0xFFFF9100)],
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
                              gradientColors: [const Color(0xFF0F9B73), const Color(0xFF2EC89F)],
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
                            _buildMenuCard(
                              icon: Icons.fire_extinguisher_rounded,
                              gradientColors: [const Color(0xFFFF5252), const Color(0xFFFF1744)],
                              title: 'ตรวจถังดับเพลิง',
                              subtitle: 'บันทึกการตรวจสอบความปลอดภัยของถังดับเพลิง',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SecuritycheckAreaPage(),
                                ),
                              ),
                            ),
                          ],
                        ),

                      _buildMenuCard(
                        icon: Icons.accessibility_new_rounded,
                        gradientColors: [const Color(0xFF4A5AE7), const Color(0xFF6B8DF8)],
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
                  padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                  child: Text(
                    'กิจกรรม/ข่าวสาร',
                    style: TextStyle(
                      fontFamily: 'Prompt',
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

        ],
      ),
    );
  }
}
