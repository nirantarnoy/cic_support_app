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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          items: items.map((e) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      e,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((image) {
            int index = items.indexOf(image);
            bool isSelected = _current == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 16.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected
                    ? const Color(0xFF0F9B73)
                    : Colors.grey.withOpacity(0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
