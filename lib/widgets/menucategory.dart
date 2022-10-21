import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/fivespage.dart';

class MenuCategoryWidget extends StatefulWidget {
  @override
  State<MenuCategoryWidget> createState() => _MenuCategoryWidgetState();
}

class _MenuCategoryWidgetState extends State<MenuCategoryWidget> {
  CarouselController buttonCarouselController = CarouselController();

  List<String> items = ['5ส', 'Satety', 'Audit', 'Kizen'];

  int _current = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.map((image) {
              int index = items.indexOf(image);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    buttonCarouselController.animateToPage(index);
                  });
                },
                child: Container(
                  width: 100.0,
                  height: 40.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    // color: _current == index
                    //     ? Colors.purple
                    //     : Colors.grey.withOpacity(0.3),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _current == index
                          ? [
                              Colors.purple.withOpacity(0.5),
                              Colors.purple,
                            ]
                          : [
                              Colors.white,
                              Colors.white,
                            ],
                    ),
                  ),
                  child: Text(
                    '${image}',
                    style: TextStyle(
                        color:
                            _current == index ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 200,
              // aspectRatio: 20 / 10,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 1,
              // autoPlay: true,
              // autoPlayInterval: Duration(seconds: 10),
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          items: items.map((e) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(
                  5,
                ),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.purple.withOpacity(0.5),
                      Colors.purple,
                    ]),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${e}',
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          Text(
                            'กิจกรรม ${e}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(''),
                          ),
                          Expanded(
                            flex: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FivesPage())),
                              child: Container(
                                alignment: Alignment.center,
                                width: 100,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      20,
                                    ),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'รายละเอียด',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
