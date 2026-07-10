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

  String _getCurrentDateString() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    final String currentDateStr = _getCurrentDateString();
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
          'Release date $currentDateStr',
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
