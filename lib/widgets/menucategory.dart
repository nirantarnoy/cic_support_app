import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/fivedetailpage.dart';
import 'package:flutter_cic_support/pages/fivespage.dart';

class MenuCategoryWidget extends StatefulWidget {
  @override
  State<MenuCategoryWidget> createState() => _MenuCategoryWidgetState();
}

class _MenuCategoryWidgetState extends State<MenuCategoryWidget> {
  CarouselController buttonCarouselController = CarouselController();

  List<String> items = ['5ส', 'Safety', 'Audit', 'Kizen'];

  int _current = 0;

  Gradient _getCategoryGradient(String category) {
    switch (category) {
      case '5ส':
        return const LinearGradient(
          colors: [Color(0xFF0F9B73), Color(0xFF2EC89F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Safety':
        return const LinearGradient(
          colors: [Color(0xFFE94057), Color(0xFFF27121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Audit':
        return const LinearGradient(
          colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Kizen':
      default:
        return const LinearGradient(
          colors: [Color(0xFF8A2387), Color(0xFFE94057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '5ส':
        return Icons.auto_awesome_rounded;
      case 'Safety':
        return Icons.security_rounded;
      case 'Audit':
        return Icons.assignment_turned_in_rounded;
      case 'Kizen':
      default:
        return Icons.lightbulb_rounded;
    }
  }

  String _getCategorySubtitle(String category) {
    switch (category) {
      case '5ส':
        return 'กิจกรรมสะสาง สะดวก สะอาด สุขลักษณะ สร้างนิสัย';
      case 'Safety':
        return 'กิจกรรมตรวจประเมินความปลอดภัยในพื้นที่ปฏิบัติงาน';
      case 'Audit':
        return 'กิจกรรมตรวจสอบคุณภาพมาตรฐานและความเรียบร้อย';
      case 'Kizen':
      default:
        return 'กิจกรรมการปรับปรุงงานอย่างต่อเนื่องและการพัฒนาไอเดีย';
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category) {
      case '5ส':
        return const Color(0xFF0F9B73);
      case 'Safety':
        return const Color(0xFFE94057);
      case 'Audit':
        return const Color(0xFF1A2980);
      case 'Kizen':
      default:
        return const Color(0xFF8A2387);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.map((image) {
              int index = items.indexOf(image);
              bool isSelected = _current == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    buttonCarouselController.animateToPage(index);
                  });
                },
                child: Container(
                  width: 90.0,
                  height: 38.0,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.grey.shade300, width: 1),
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF0F9B73),
                              Color(0xFF2EC89F),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F9B73).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    image,
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 180,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 0.9,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          items: items.map((e) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _getCategoryGradient(e),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -20,
                    child: Icon(
                      _getCategoryIcon(e),
                      size: 130,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(e),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Prompt',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getCategorySubtitle(e),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontFamily: 'Prompt',
                            height: 1.4,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FiveDetailPage(),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'รายละเอียด',
                                      style: TextStyle(
                                        color: _getCategoryTextColor(e),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Prompt',
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: _getCategoryTextColor(e),
                                      size: 14,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
