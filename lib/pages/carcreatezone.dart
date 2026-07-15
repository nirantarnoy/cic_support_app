import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/jobplanareasaved.dart';
import 'package:flutter_cic_support/pages/createcar.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:provider/provider.dart';

class CarcreateZone extends StatefulWidget {
  const CarcreateZone({Key? key}) : super(key: key);

  @override
  State<CarcreateZone> createState() => _CarcreateZoneState();
}

class _CarcreateZoneState extends State<CarcreateZone> {
  @override
  void initState() {
    Provider.of<PlanData>(context, listen: false).fetchJobplanSaved();
    super.initState();
  }

  Widget _buildlist(List<JobplanAreaSaved> list) {
    if (list.isNotEmpty) {
      return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final areaItem = list[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCar(
                          plan_area_id: areaItem.plan_area_id,
                          plan_area_name: areaItem.plan_area_name,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F9B73).withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  areaItem.plan_area_name,
                                  style: const TextStyle(
                                    fontFamily: 'Prompt',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'แตะเพื่อออกใบ CAR สำหรับแผนกนี้',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey.shade400,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ไม่พบข้อมูลแผนก',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
          'เลือกแผนก',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<PlanData>(
                builder: (contex, _data, _) =>
                    _buildlist(_data.listJobplanAreaSaved),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
