import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class newswidget extends StatefulWidget {
  @override
  State<newswidget> createState() => _newswidgetState();
}

class _newswidgetState extends State<newswidget> {
  CarouselController buttonCarouselController = CarouselController();
  List<dynamic> newsList = [];
  bool isLoading = true;
  int _current = 0;

  // URL from user request
  final String apiUrl = "http://172.16.0.231:3000/api/qa-news";

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString("token") ?? "";
      print("QA News Fetch - URL: $apiUrl");
      print("QA News Fetch - Token: $token");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("QA News Fetch - Status Code: ${response.statusCode}");
      print("QA News Fetch - Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            newsList = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching QA news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (newsList.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            "ไม่มีกิจกรรม/ข่าวสารในขณะนี้",
            style: TextStyle(fontFamily: 'Prompt', color: Colors.grey),
          ),
        ),
      );
    }

    // Flatten images into individual slides
    List<Map<String, dynamic>> slideList = [];
    for (var news in newsList) {
      List<dynamic> images = news['images'] ?? [];
      if (images.isEmpty) {
        slideList.add({
          'news': news,
          'image': null,
        });
      } else {
        for (var img in images) {
          slideList.add({
            'news': news,
            'image': img,
          });
        }
      }
    }

    return Column(
      children: [
        CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          items: slideList.map((slide) {
            var news = slide['news'];
            String? image = slide['image'];

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
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
                    child: Stack(
                      children: [
                        // Background Image
                        image != null
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey.shade200),
                              )
                            : Container(
                                color: const Color(0xFF0F9B73).withOpacity(0.05),
                                child: const Center(
                                  child: Icon(Icons.article_outlined,
                                      size: 60, color: Color(0xFF0F9B73)),
                                ),
                              ),

                        // Gradient Overlay for readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),

                        // Text Content
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Prompt',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                news['details'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontFamily: 'Prompt',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
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
          children: slideList.asMap().entries.map((entry) {
            int index = entry.key;
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
