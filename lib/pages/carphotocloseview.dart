import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CarphotoCloseviewPage extends StatelessWidget {
  final String carphoto_url;
  const CarphotoCloseviewPage({Key? key, required this.carphoto_url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รูปภาพ',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: PhotoView(
            imageProvider: NetworkImage(carphoto_url),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            loadingBuilder: (context, event) => const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF0F9B73),
                  strokeWidth: 3,
                ),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white60,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'โหลดรูปภาพไม่สำเร็จ',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
