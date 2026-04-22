import 'package:flutter/material.dart';

class StretchableFooter extends StatelessWidget {
  const StretchableFooter({
    super.key,
    required this.height,
    required this.leading,
    required this.trailing,
  });

  final double height;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Row(
          children: [
            Expanded(child: leading),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
