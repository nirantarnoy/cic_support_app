import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/bigplanarea.dart';
import 'package:flutter_cic_support/pages/bigcleancheckdetail.dart';
import 'package:flutter_cic_support/pages/plancheckcomplete.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BigcleanAreaPage extends StatefulWidget {
  const BigcleanAreaPage({Key? key}) : super(key: key);

  @override
  State<BigcleanAreaPage> createState() => _BigcleanAreaPageState();
}

class _BigcleanAreaPageState extends State<BigcleanAreaPage> {
  String current_section_code = '';

  @override
  void initState() {
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<PlanData>(context, listen: false).fetchBigcleanplan();
    EasyLoading.dismiss();
    super.initState();
  }

  Widget _buildList(List<BigplanArea> listcheck) {
    Widget cardlist;
    if (listcheck.isNotEmpty) {
      cardlist = ListView.builder(
          itemCount: listcheck.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext contex, int index) {
            int total_topic = 3;
            int total_topic_counted = Provider.of<PlanData>(contex, listen: false)
                .countCheckedTopicBigcleanitem(listcheck[index].plan_area_id);

            Color _bgcolor = Colors.white;
            Color _line_color = Colors.black87;
            Color _status_color = const Color(0xFF4A5AE7); // Default blue
            String _status_text = 'ยังไม่ได้ตรวจ / Tap to inspect';

            if (total_topic_counted <= 0) {
              _bgcolor = Colors.white;
              _status_color = const Color(0xFF4A5AE7); // Blue
              _status_text = 'ยังไม่ได้ตรวจ / Tap to inspect';
            } else if (total_topic_counted > 0 &&
                total_topic_counted < total_topic) {
              _bgcolor = const Color(0xFFFFF8E1); // Soft yellow
              _status_color = const Color(0xFFFFAD3B); // Yellow
              _status_text = 'ตรวจค้างอยู่ / In progress';
            } else if (total_topic_counted == total_topic) {
              _bgcolor = const Color(0xFFE8F5E9); // Soft green
              _status_color = const Color(0xFF0F9B73); // Green
              _status_text = 'ตรวจเสร็จสิ้น / Completed';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _bgcolor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Slidable(
                    key: ValueKey(listcheck[index].plan_area_id),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _removecheckeditem(listcheck[index].plan_area_id);
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_rounded,
                          label: 'Clear',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _removecheckeditem(listcheck[index].plan_area_id);
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_rounded,
                          label: 'Clear',
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BigCleanCheckDetailPage(
                                plan_area_id: listcheck[index].plan_area_id,
                                plan_id: listcheck[index].plan_id,
                                plan_num: listcheck[index].plan_id,
                                plan_area_name: listcheck[index].plan_area_name,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                          child: Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontFamily: 'Prompt',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listcheck[index].plan_area_name,
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _line_color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _status_text,
                                      style: TextStyle(
                                        fontFamily: 'Prompt',
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _status_color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$total_topic_counted/$total_topic",
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    color: _status_color,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
      return cardlist;
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cleaning_services_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'ไม่พบแผนงาน Big Cleaning',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _removecheckeditem(String area_id) {
    Provider.of<PlanData>(context, listen: false)
        .removeBigCleaninspectionitem(area_id);
  }

  void _showWarningDialog(BuildContext context, PlanData plans) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'แจ้งให้ทราบ',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'พบข้อมูลการตรวจไม่ครบหัวข้อ ต้องการดำเนินการต่อใช่หรือไม่ ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        'ไม่ใช่',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _submitInspection(plans);
                      },
                      child: const Text(
                        'ใช่',
                        style: TextStyle(
                          fontFamily: 'Prompt',
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

  void _showConfirmDialog(BuildContext context, PlanData plans) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 40,
                  color: Colors.green.shade600,
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
                'ต้องการดำเนินการต่อใช่หรือไม่ ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        'ไม่ใช่',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F9B73),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _submitInspection(plans);
                      },
                      child: const Text(
                        'ใช่',
                        style: TextStyle(
                          fontFamily: 'Prompt',
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

  Future<void> _submitInspection(PlanData plans) async {
    await EasyLoading.show(status: "กำลังบันทึกข้อมูล");
    bool isSave = await plans.submitBigcleanInspection();
    if (isSave == true) {
      await EasyLoading.showSuccess('บันทึกรายการเรียบร้อย');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PlancheckcompletePage()),
        );
      }
    } else {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    current_section_code =
        Provider.of<UserData>(context, listen: false).getCurrenUserSection();
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
          "แผน Big Cleaning",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF5F7FB),
        width: double.infinity,
        child: Column(children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Consumer<PlanData>(
              builder: ((context, _plans, _) => _plans.finishedcheck > 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ไม่พบรายการตรวจ หรือ ตรวจครบแล้ว',
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildList(
                      _plans.getBigAreaTitle(),
                    )),
            ),
          ),
          Consumer<PlanData>(
            builder: ((context, _plans, _) => _plans.hasBigcleanArea() > 0
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9B73).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            int MustChekAll = _plans.getBigAllMushCheckTopic();
                            int AllChecked = _plans.getBigAllCheckedTopic();
                            if (AllChecked < MustChekAll) {
                              _showWarningDialog(context, _plans);
                            } else {
                              _showConfirmDialog(context, _plans);
                            }
                          },
                          child: const Center(
                            child: Text(
                              "ยืนยันการตรวจ",
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
                : const SizedBox()),
          ),
        ]),
      ),
    );
  }
}
