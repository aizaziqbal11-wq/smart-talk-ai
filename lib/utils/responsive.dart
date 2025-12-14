import 'package:flutter/material.dart';

class MaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidth({super.key, required this.child, this.maxWidth = 700});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= maxWidth) return child;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint;

  const ResponsiveRow({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 900,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: right),
            ],
          );
        }
        return Column(children: [left, right]);
      },
    );
  }
}
