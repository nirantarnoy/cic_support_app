// import 'dart:html';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SecuritycheckphotoviewPage extends StatelessWidget {
  final List<File> carphoto;
  const SecuritycheckphotoviewPage({Key? key, required this.carphoto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รูปภาพ')),
      body: Container(
        height: double.infinity,
        // width: context.size?.width,
        child: PhotoViewGallery.builder(
          itemCount: carphoto.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(io.File(carphoto[index].path)),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2);
          },
          scrollPhysics: BouncingScrollPhysics(),
          enableRotation: true,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                backgroundColor: Colors.orange,
                value: event == null ? 0 : 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
