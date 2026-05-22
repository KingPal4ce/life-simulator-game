import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

class RetroContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const RetroContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
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
