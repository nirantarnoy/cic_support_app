import 'package:flutter/material.dart';

class DraggableFAB extends StatefulWidget {
  final VoidCallback onTap;

  const DraggableFAB({Key? key, required this.onTap}) : super(key: key);

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  double? xPosition;
  double? yPosition;
  bool isInitialized = false;

  final double buttonSize = 56.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;

      // Default position: Bottom right
      xPosition = screenWidth - buttonSize - 16.0;
      yPosition = screenHeight - buttonSize - 100.0;
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // Boundary constraints
    const minX = 16.0;
    final maxX = screenWidth - buttonSize - 16.0;
    final minY = statusBarHeight + 16.0;
    final maxY = screenHeight - buttonSize - bottomPadding - 16.0;

    // Guard positions
    xPosition = xPosition?.clamp(minX, maxX) ?? maxX;
    yPosition = yPosition?.clamp(minY, maxY) ?? maxY;

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            xPosition = (xPosition! + details.delta.dx).clamp(minX, maxX);
            yPosition = (yPosition! + details.delta.dy).clamp(minY, maxY);
          });
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8A2387),
                Color(0xFFE94057),
                Color(0xFFF27121),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE94057).withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
