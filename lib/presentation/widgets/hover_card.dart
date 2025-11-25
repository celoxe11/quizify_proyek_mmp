import 'package:flutter/material.dart';

// Hoverable card wrapper used for web/desktop to animate border, shadow and slight lift on pointer hover.
class HoverCardWrapper extends StatefulWidget {
  final Widget child;
  const HoverCardWrapper({required this.child, super.key});

  @override
  State<HoverCardWrapper> createState() => HoverCardWrapperState();
}

class HoverCardWrapperState extends State<HoverCardWrapper> {
  bool _hover = false;

  void _setHover(bool h) {
    if (_hover == h) return;
    setState(() {
      _hover = h;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxShadow = _hover
        ? [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ];
    final transform = _hover
        ? (Matrix4.identity()..translate(0.0, -6.0, 0.0))
        : Matrix4.identity();

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: transform,
        // Keep wrapper transparent so the inner card can provide its own background color.
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: boxShadow,
        ),
        child: widget.child,
      ),
    );
  }
}
