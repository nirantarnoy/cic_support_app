import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/carlist.dart';
import 'package:flutter_cic_support/pages/carcreatezone.dart';
import 'package:flutter_cic_support/pages/cardetail.dart';
import 'package:flutter_cic_support/providers/car.dart';
import 'package:flutter_cic_support/providers/plan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class CarlistPage extends StatefulWidget {
  const CarlistPage({Key? key}) : super(key: key);

  @override
  State<CarlistPage> createState() => _CarlistPageState();
}

class _CarlistPageState extends State<CarlistPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    EasyLoading.show(status: "โหลดข้อมูล");
    Provider.of<CarData>(context, listen: false).getCarlistByEmpId();
    Provider.of<PlanData>(context, listen: false).fetchNonconformTitle();
    EasyLoading.dismiss();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);

    super.initState();
  }

  Widget _buildcarlist(List<CarList> listcar, String status) {
    if (listcar.isNotEmpty) {
      List<CarList> filteredList = listcar.where((element) => element.status == status).toList();

      if (filteredList.isNotEmpty) {
        return ListView.builder(
            itemCount: filteredList.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final carItem = filteredList[index];
              String statusName = "";
              Color statusColor = Colors.grey;
              List<Color> gradientColors = [Colors.grey, Colors.grey.shade400];

              if (carItem.status == "1") {
                statusName = "Pending";
                statusColor = const Color(0xFFFF9800); // Orange
                gradientColors = [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
              } else if (carItem.status == "2") {
                statusName = "Open";
                statusColor = const Color(0xFF0F9B73); // Green
                gradientColors = [const Color(0xFF0F9B73), const Color(0xFF2EC89F)];
              } else if (carItem.status == "3") {
                statusName = "Closed";
                statusColor = const Color(0xFFE53935); // Red
                gradientColors = [const Color(0xFFE53935), const Color(0xFFEF5350)];
              }

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
                              builder: (context) => CarDetailPage(
                                    id: carItem.id,
                                    car_id: carItem.car_id,
                                    area_id: carItem.area_id,
                                    area_name: carItem.area_name,
                                    car_date: carItem.car_date,
                                    car_no: carItem.car_no,
                                    car_description: carItem.description,
                                    is_new: carItem.is_new,
                                    target_finish_date: carItem.target_finish_date,
                                    responsibility: carItem.responsibility,
                                    car_non_conform: carItem.car_non_conform,
                                    car_status: carItem.status,
                                  ))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
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
                                    '${carItem.car_no} - ${carItem.area_name}',
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    carItem.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        carItem.car_date,
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusName,
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 12,
                                ),
                              ),
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
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ไม่พบรายการในหมวดนี้',
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
                Icons.block_flipped,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ไม่พบรายการตรวจใบ CAR',
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
          "รายการใบ CAR",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarcreateZone()),
            ),
            icon: const Icon(
              Icons.post_add_rounded,
              color: Colors.black87,
              size: 26,
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0F9B73),
          indicatorWeight: 3,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black38,
          labelStyle: const TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const <Widget>[
            Tab(
              text: "รอดำเนินการ",
            ),
            Tab(
              text: "คงค้าง",
            ),
            Tab(
              text: "ดำเนินการแล้ว",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Consumer<CarData>(
            builder: ((context, value, _) =>
                _buildcarlist(value.listcaritem, "1")),
          ),
          Consumer<CarData>(
            builder: ((context, value, _) =>
                _buildcarlist(value.listcaritem, "2")),
          ),
          Consumer<CarData>(
            builder: ((context, value, _) =>
                _buildcarlist(value.listcaritem, "3")),
          ),
        ],
      ),
    );
  }
}
