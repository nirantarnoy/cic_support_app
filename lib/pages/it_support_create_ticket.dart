import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_cic_support/providers/user.dart';

class ITSupportCreateTicketPage extends StatefulWidget {
  final String initialCategory;

  const ITSupportCreateTicketPage({Key? key, this.initialCategory = ''})
      : super(key: key);

  @override
  State<ITSupportCreateTicketPage> createState() =>
      _ITSupportCreateTicketPageState();
}

class _ITSupportCreateTicketPageState extends State<ITSupportCreateTicketPage> {
  final _formKey = GlobalKey<FormState>();

  String? _workType;

  // --- Common Fields ---
  final TextEditingController _problemDescController = TextEditingController();

  // --- Hardware / Workrequest Fields ---
  String? _workPriority = 'NORMAL';
  String? _siteCode;
  String? _departmentNo;
  String? _locationNo;
  String? _assetNo;
  DateTime _requiredDate = DateTime.now();
  
  // Assets Data from API
  List<Map<String, dynamic>> _assetsList = [];
  bool _isLoadingAssets = true;

  // --- Program Request Fields ---
  String? _programIssueType = 'งานทั่วไป';

  // --- User Request Fields ---
  String? _userReqFor;
  String? _userReqType;
  String? _userReqObjective;
  String? _userReqReason;
  String? _empName;
  String? _username;
  String? _password;
  String? _jobPosition;
  String? _jobResponsibility;
  String? _replaceEmpName;

  final List<String> _workTypes = [
    'แจ้งการใช้งานโปรแกรม',
    'แจ้งอุปกรณ์คอมพิวเตอร์',
    'แจ้งร้องขอรายงาน',
    'แจ้งร้องขอผู้ใช้งาน',
    'กล้องวงจรปิด',
    'กู้ข้อมูล',
    'โทรศัพท์',
    'อินเทอร์เน็ต',
    'อื่นๆ'
  ];

  @override
  void initState() {
    super.initState();
    if (_workTypes.contains(widget.initialCategory)) {
      _workType = widget.initialCategory;
    } else {
      _workType = _workTypes[1]; // Default to Hardware
    }

    // Fetch assets when the form is for Hardware (แจ้งอุปกรณ์คอมพิวเตอร์)
    if (_workType == 'แจ้งอุปกรณ์คอมพิวเตอร์') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAssetsFromNodeAPI();
      });
    }
  }

  @override
  void dispose() {
    _problemDescController.dispose();
    super.dispose();
  }

  // ดึงข้อมูล Asset ของแผนก User ปัจจุบัน จาก Node API (http://localhost:3000)
  Future<void> _fetchAssetsFromNodeAPI() async {
    setState(() {
      _isLoadingAssets = true;
    });

    try {
      // ดึงรหัสแผนกของ User ที่ล็อกอินอยู่จาก Provider
      final userProvider = Provider.of<UserData>(context, listen: false);
      final String userDept = userProvider.empdepartmentid.toString();

      // ชี้ไปยัง Server ที่รัน Node.js อยู่ (ตาม IP ที่ระบุ)
      final String apiUrl = 'http://192.168.60.34:3000/api/assets?department=$userDept'; 
      // หรือ url ที่ถูกต้องของ Node.js Paperless ของคุณ

      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _assetsList = data.map((e) => {
            'value': e['AssetNumber']?.toString() ?? e['id']?.toString() ?? '',
            'text': e['AssetDescription']?.toString() ?? e['name']?.toString() ?? 'Unknown Asset',
          }).toList();
        });
      } else {
        // Mockup fallback data if API returns error (สำหรับทดสอบ)
        _loadMockAssets();
      }
    } catch (e) {
      print('Error fetching assets: $e');
      // Mockup fallback data if API is unreachable (สำหรับทดสอบ)
      _loadMockAssets();
    } finally {
      setState(() {
        _isLoadingAssets = false;
      });
    }
  }

  void _loadMockAssets() {
    setState(() {
      _assetsList = [
        {'value': 'NB-001', 'text': 'Notebook Dell Latitude 3420'},
        {'value': 'PC-005', 'text': 'PC Lenovo ThinkCentre'},
        {'value': 'PR-002', 'text': 'Printer Brother MFC-L2700DW'},
      ];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requiredDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0072FF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _requiredDate) {
      setState(() {
        _requiredDate = picked;
      });
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Prompt',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Prompt',
        fontSize: 13,
        color: Colors.grey,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0072FF), width: 1.5),
      ),
    );
  }

  // ----------------------------------------------------
  // Dynamic Form Builders
  // ----------------------------------------------------

  Widget _buildHardwareForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Request No (เลขที่ใบแจ้งซ่อม)'),
        TextFormField(
          initialValue: 'IT-AUTO-GENERATE',
          readOnly: true,
          style: const TextStyle(fontFamily: 'Prompt', color: Colors.black54),
          decoration: _inputDecoration('Request No').copyWith(fillColor: Colors.grey.shade100),
        ),
        _buildLabel('Problem Desc (รายละเอียดปัญหา) *'),
        TextFormField(
          controller: _problemDescController,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'Prompt'),
          decoration: _inputDecoration('กรอกรายละเอียดปัญหา...'),
          validator: (v) => v!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
        ),
        _buildLabel('Problem Date (วันที่แจ้ง)'),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_requiredDate.day}/${_requiredDate.month}/${_requiredDate.year}", style: const TextStyle(fontFamily: 'Prompt')),
                const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.black54),
              ],
            ),
          ),
        ),
        _buildLabel('Work Priority (ความเร่งด่วน) *'),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('NORMAL (ทั่วไป/ไม่เร่งด่วน)', style: TextStyle(fontFamily: 'Prompt', fontSize: 13)),
                value: 'NORMAL', groupValue: _workPriority,
                onChanged: (v) => setState(() => _workPriority = v),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text('URGENT (ด่วน/เบรคดาวน์)', style: TextStyle(fontFamily: 'Prompt', fontSize: 13)),
                value: 'URGENT', groupValue: _workPriority,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _workPriority = v),
              ),
            ],
          ),
        ),
        
        // Asset Dropdown from API
        _buildLabel('Asset (อุปกรณ์ไอทีของแผนกคุณ) *'),
        _isLoadingAssets
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: _assetNo,
                isExpanded: true,
                decoration: _inputDecoration('เลือกอุปกรณ์ไอที'),
                items: _assetsList.map((asset) {
                  return DropdownMenuItem<String>(
                    value: asset['value'],
                    child: Text('${asset['value']} | ${asset['text']}', style: const TextStyle(fontFamily: 'Prompt', fontSize: 13), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _assetNo = v),
                validator: (v) => v == null ? 'กรุณาเลือกอุปกรณ์' : null,
              ),

        // Hidden or prepopulated based on user in future
        _buildLabel('Location (ที่ตั้งของอุปกรณ์ไอที)'),
        TextFormField(
          style: const TextStyle(fontFamily: 'Prompt'),
          decoration: _inputDecoration('เช่น ออฟฟิศชั้น 2, ไลน์ผลิต A'),
          onChanged: (v) => _locationNo = v,
        ),
      ],
    );
  }

  Widget _buildProgramForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('ประเภทงาน *'),
        DropdownButtonFormField<String>(
          value: _programIssueType,
          decoration: _inputDecoration('เลือกประเภทงาน'),
          items: ['งานทั่วไป', 'ปัญหาเข้าใช้งานโปรแกรม Ax ไม่ได้'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Prompt')))).toList(),
          onChanged: (v) => setState(() => _programIssueType = v),
        ),
        if (_programIssueType == 'ปัญหาเข้าใช้งานโปรแกรม Ax ไม่ได้')
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('หัวข้อ "ปัญหาเข้าใช้งานโปรแกรม Ax ไม่ได้" ใช้ได้แค่กรณีเข้าใช้งาน Ax ไม่ได้เท่านั้น', style: TextStyle(fontFamily: 'Prompt', color: Colors.red, fontSize: 12)),
          ),
        _buildLabel('รายละเอียด *'),
        TextFormField(
          controller: _problemDescController,
          maxLines: 6,
          style: const TextStyle(fontFamily: 'Prompt'),
          decoration: _inputDecoration('กรอกรายละเอียด...'),
          validator: (v) => v!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
        ),
      ],
    );
  }

  Widget _buildUserRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('ใช้งานสำหรับ *'),
              DropdownButtonFormField<String>(
                value: _userReqFor,
                decoration: _inputDecoration('เลือก'),
                items: ['พนักงานประจำ', 'นักศึกษาฝึกงาน', 'ผู้รับเหมา'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Prompt')))).toList(),
                onChanged: (v) => setState(() => _userReqFor = v),
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('ประเภทการร้องขอ *'),
              DropdownButtonFormField<String>(
                value: _userReqType,
                decoration: _inputDecoration('เลือก'),
                items: ['เพิ่มสิทธิ์', 'ยกเลิกสิทธิ์', 'แก้ไขสิทธิ์'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Prompt')))).toList(),
                onChanged: (v) => setState(() => _userReqType = v),
              ),
            ])),
          ],
        ),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('วัตถุประสงค์ *'),
              DropdownButtonFormField<String>(
                value: _userReqObjective,
                decoration: _inputDecoration('เลือก'),
                items: ['เพื่อใช้งาน', 'เพื่อทดสอบ', 'อื่นๆ'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Prompt')))).toList(),
                onChanged: (v) => setState(() => _userReqObjective = v),
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('เนื่องจาก *'),
              DropdownButtonFormField<String>(
                value: _userReqReason,
                decoration: _inputDecoration('เลือก'),
                items: ['ลาออก', 'ย้ายตำแหน่ง', 'ไม่ระบุ'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Prompt')))).toList(),
                onChanged: (v) => setState(() => _userReqReason = v),
              ),
            ])),
          ],
        ),
        const Divider(height: 32),
        _buildLabel('ชื่อ - นามสกุล *'),
        TextFormField(
          style: const TextStyle(fontFamily: 'Prompt'),
          decoration: _inputDecoration('ค้นหา ชื่อ - นามสกุล'),
          onChanged: (v) => _empName = v,
          validator: (v) => v!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
        ),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Username'),
              TextFormField(style: const TextStyle(fontFamily: 'Prompt'), decoration: _inputDecoration('Username'), onChanged: (v) => _username = v),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Password'),
              TextFormField(obscureText: true, style: const TextStyle(fontFamily: 'Prompt'), decoration: _inputDecoration('Password'), onChanged: (v) => _password = v),
            ])),
          ],
        ),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('ตำแหน่งงาน'),
              TextFormField(style: const TextStyle(fontFamily: 'Prompt'), decoration: _inputDecoration('ตำแหน่ง'), onChanged: (v) => _jobPosition = v),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('ความรับผิดชอบ'),
              TextFormField(style: const TextStyle(fontFamily: 'Prompt'), decoration: _inputDecoration('ความรับผิดชอบ'), onChanged: (v) => _jobResponsibility = v),
            ])),
          ],
        ),
        const Divider(height: 32),
        _buildLabel('ชื่อพนักงานที่ลาออก หรือ ย้ายตำแหน่ง'),
        TextFormField(style: const TextStyle(fontFamily: 'Prompt'), decoration: _inputDecoration('ระบุชื่อ (ถ้ามี)'), onChanged: (v) => _replaceEmpName = v),
      ],
    );
  }

  Widget _buildGenericForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('รายละเอียด *'),
        TextFormField(
          controller: _problemDescController,
          maxLines: 6,
          style: const TextStyle(fontFamily: 'Prompt'),
          decoration: _inputDecoration('กรอกรายละเอียดความต้องการ...'),
          validator: (v) => v!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
        ),
      ],
    );
  }

  Widget _buildDynamicFormContent() {
    if (_workType == 'แจ้งอุปกรณ์คอมพิวเตอร์') {
      return _buildHardwareForm();
    } else if (_workType == 'แจ้งการใช้งานโปรแกรม') {
      return _buildProgramForm();
    } else if (_workType == 'แจ้งร้องขอผู้ใช้งาน') {
      return _buildUserRequestForm();
    } else {
      return _buildGenericForm();
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('ร้องขอ / แจ้งซ่อมไอที', style: TextStyle(color: Colors.black87, fontFamily: 'Prompt', fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('หมวดหมู่แจ้งซ่อม/ร้องขอ (Category) *'),
                DropdownButtonFormField<String>(
                  value: _workType,
                  decoration: _inputDecoration('หมวดหมู่').copyWith(fillColor: Colors.grey.shade200),
                  style: const TextStyle(fontFamily: 'Prompt', color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
                  items: _workTypes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: null, // Locked so user can't change it manually inside the form
                ),
                const SizedBox(height: 8),
                const Divider(),
                
                // --- Dynamic Form Render ---
                _buildDynamicFormContent(),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0072FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลการแจ้งร้องขอสำเร็จ', style: TextStyle(fontFamily: 'Prompt')), backgroundColor: Colors.green));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('บันทึกข้อมูล (Create)', style: TextStyle(fontFamily: 'Prompt', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
