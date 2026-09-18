import 'package:flutter/material.dart';
import 'package:flutter_cic_support/app_config.dart';

class VersionInfoWidget extends StatelessWidget {
  final Color? color;
  final double fontSize;

  const VersionInfoWidget({
    Key? key,
    this.color,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = color ?? Colors.grey.shade600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Build version ${AppConfig.buildVersion}',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: 'Prompt',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Release date ${AppConfig.buildDate}',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: 'Prompt',
          ),
        ),
      ],
    );
  }
}
