import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class newswidget extends StatefulWidget {
  @override
  State<newswidget> createState() => _newswidgetState();
}

class _newswidgetState extends State<newswidget> {
  CarouselController buttonCarouselController = CarouselController();

  List<String> items = [
    'assets/images/kizen01.jpg',
    'assets/images/kizen02.jpg'
  ];

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
        CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          items: items.map((e) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(
                      5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      e,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((image) {
            int index = items.indexOf(image);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index
                    ? Color.fromARGB(255, 45, 172, 123)
                    : Colors.grey.withOpacity(0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
