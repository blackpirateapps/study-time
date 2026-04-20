import 'package:flutter/cupertino.dart';

class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F3EA),
            Color(0xFFF2E6D2),
            Color(0xFFEBDCC7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _GlowBlob(
              diameter: 260,
              color: const Color(0x55B4D3BE),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -60,
            child: _GlowBlob(
              diameter: 220,
              color: const Color(0x66E6B084),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.diameter,
    required this.color,
  });

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
