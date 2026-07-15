import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/pages/storeissuedetailpage.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class StoreissueApprovePage extends StatefulWidget {
  static final routeName = 'storeissueapprove';
  final String team_id;

  const StoreissueApprovePage({Key? key, required this.team_id})
      : super(key: key);
  @override
  State<StoreissueApprovePage> createState() => _StoreissueApprovePageState();
}

class _StoreissueApprovePageState extends State<StoreissueApprovePage> {
  // Future _obtainMemeberTeam() async {
  //   await Provider.of<UserData>(context, listen: false).findTeamMember();
  // }

  @override
  void initState() {
    Provider.of<StoreissueData>(context, listen: false).fetchIssuelist();

    super.initState();
  }

  Future<void> _getNewdata() async {
    setState(() {
      Provider.of<StoreissueData>(context, listen: false).fetchIssuelist();
    });
  }

  Widget _buildlist(List<Storeissue> _listcheck) {
    DateFormat dateformatter = DateFormat('dd-MM-yyyy HH:mm');
    if (_listcheck.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _getNewdata,
        color: const Color(0xFF0F9B73),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _listcheck.length,
          itemBuilder: (BuildContext context, int index) {
            final item = _listcheck[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreissuedetailPage(
                    issue_id: item.id,
                    team_id: widget.team_id,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F9B73).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_rounded,
                          color: Color(0xFF0F9B73),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.journal_no,
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF7E36)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'รออนุมัติ',
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF7E36),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.emp_full_name,
                              style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  dateformatter
                                      .format(DateTime.parse(item.trans_date)),
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "ไม่พบรายการรออนุมัติ",
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () {
            widget.team_id == ""
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    "profilenormal", (Route<dynamic> route) => false)
                : Navigator.of(context).pushNamed("profile");
          },
        ),
        title: const Text(
          "อนุมัติใบเบิกสโตร์",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<StoreissueData>(
        builder: ((context, storeData, child) =>
            _buildlist(storeData.listIssue)),
      ),
    );
  }
}
