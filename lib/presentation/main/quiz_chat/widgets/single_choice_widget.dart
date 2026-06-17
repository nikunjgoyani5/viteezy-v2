import 'package:flutter/material.dart';

class SingleChoiceWidget extends StatelessWidget {

  final bool selected;
  final Widget child;
  final VoidCallback onTap;

  const SingleChoiceWidget({
    super.key,
    required this.selected,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.teal
                : Colors.transparent,
          ),
        ),
        child: child,
      ),
    );
  }
}