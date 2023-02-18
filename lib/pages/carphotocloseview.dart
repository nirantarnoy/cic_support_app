// import 'dart:html';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CarphotoCloseviewPage extends StatelessWidget {
  final String carphoto_url;
  const CarphotoCloseviewPage({Key? key, required this.carphoto_url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('รูปภาพ')),
        body: Container(
          height: double.infinity,
          // width: context.size?.width,
          child: Image.network(
            carphoto_url,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
