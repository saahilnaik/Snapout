import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Entrance animation — fades and slides a child up on first build.
/// Use [delay] to stagger a column of elements.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: AppMotion.medium);
  late final Animation<double> _curved =
      CurvedAnimation(parent: _c, curve: AppMotion.curve);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) => Opacity(
        opacity: _curved.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curved.value) * widget.offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
