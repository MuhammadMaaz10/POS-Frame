import 'package:flutter/material.dart';

/// Standard AppBar back control with a proper Material tap target.
class AppBarBackButton extends StatelessWidget {
  final Color color;

  const AppBarBackButton({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
