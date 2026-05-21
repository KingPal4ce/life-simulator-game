import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

class RetroContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool hasShadow;
  final EdgeInsetsGeometry padding;

  const RetroContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF333333), // Slate grey/black
    this.borderWidth = 3.0,
    this.hasShadow = false,
    this.padding = const EdgeInsets.all(12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: NesContainer(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
