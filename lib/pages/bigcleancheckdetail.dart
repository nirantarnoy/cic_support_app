import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/bigcheckdetail.dart';
import 'package:flutter_cic_support/models/inspectiontrans.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BigCleanCheckDetailPage extends StatefulWidget {
  final String plan_id;
  final String plan_area_id;
  final String plan_area_name;
  final String plan_num;
  const BigCleanCheckDetailPage({
    Key? key,
    required this.plan_id,
    required this.plan_area_id,
    required this.plan_area_name,
    required this.plan_num,
  }) : super(key: key);

  @override
  State<BigCleanCheckDetailPage> createState() =>
      _BigCleanCheckDetailPageState();
}

class _BigCleanCheckDetailPageState extends State<BigCleanCheckDetailPage> {

  @override
  void initState() {
    super.initState();
  }

  Widget _buildlist(List<BigCheckDetail> _elementsx) {
    Widget carditem;
    if (_elementsx.isNotEmpty) {
      carditem = ListView.builder(
        itemCount: _elementsx.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          String has_line_score = Provider.of<PlanData>(context, listen: false)
              .checkBigLineScore(
                  _elementsx[index].topicid, widget.plan_area_id);
          
          bool isScored = int.parse(has_line_score) > -1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: isScored ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isScored ? Colors.green.shade100 : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Slidable(
                  key: ValueKey(_elementsx[index].topicid),
                  endActionPane: ActionPane(
                    extentRatio: 0.85,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          _showConfirmZeroDialog(context, _elementsx[index]);
                        },
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        label: '0',
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          _addselected("1", _elementsx[index].topicid,
                              _elementsx[index].topicid);
                        },
                        backgroundColor: const Color(0xFFFFAD3B),
                        foregroundColor: Colors.white,
                        label: '1',
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          _addselected("2", _elementsx[index].topicid,
                              _elementsx[index].topicid);
                        },
                        backgroundColor: const Color(0xFFF1C40F),
                        foregroundColor: Colors.white,
                        label: '2',
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          _addselected("3", _elementsx[index].topicid,
                              _elementsx[index].topicid);
                        },
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        label: '3',
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          _addselected("4", _elementsx[index].topicid,
                              _elementsx[index].topicid);
                        },
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        label: '4',
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Optional interactive guide trigger
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isScored ? Colors.white : Colors.grey.shade50,
                              ),
                              child: Center(
                                child: Icon(
                                  isScored
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isScored ? const Color(0xFF0F9B73) : Colors.grey.shade400,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _elementsx[index].topicname,
                                style: const TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isScored)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F9B73).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "คะแนน: $has_line_score",
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F9B73),
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              Text(
                                "สไลด์เพื่อประเมิน",
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.swipe_left_rounded,
                              color: Colors.grey,
                              size: 16,
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
        },
      );

      return carditem;
    } else {
      return const Center(
        child: Text(
          'ไม่พบข้อมูลการตรวจ',
          style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
        ),
      );
    }
  }

  void _showConfirmZeroDialog(BuildContext context, BigCheckDetail item) {
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
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.report_problem_rounded,
                  size: 40,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ต้องการให้คะแนนเป็น 0 ใช่หรือไม่ ?',
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
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _addselected(
                            "0",
                            item.topicid,
                            item.topicid);
                        if (context.mounted) {
                          Navigator.of(context).pop(false);
                        }
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

  void _addselected(String score, dynamic topic_id, dynamic topic_item_id) {
    if (score != '') {
      InspectionTrans _inspec = InspectionTrans(
        area_group_id: '0',
        emp_id: '0',
        plan_id: widget.plan_id,
        plan_num: widget.plan_num,
        area_id: widget.plan_area_id,
        score: score.toString(),
        status: '1',
        team_id: '0',
        topic_id: topic_id,
        topic_item_id: topic_item_id,
        module_type_id: '1',
        note: '',
        trans_date: DateTime.now().toIso8601String(),
      );

      Provider.of<PlanData>(context, listen: false)
          .addBigInspectionTrans(_inspec);
      setState(() {});
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
          'หัวข้อการตรวจ',
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A5AE7).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF4A5AE7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'พื้นที่รับผิดชอบตรวจ',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.plan_area_name,
                              style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<PlanData>(
                    builder: (context, topicitems, _) => _buildlist(
                        topicitems.getBigcleanTopicitem(widget.plan_area_id))),
              ),
            ],
          )),
    );
  }
}
