import 'package:flutter/cupertino.dart';

class MagicPlusButton extends StatefulWidget {
  const MagicPlusButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<MagicPlusButton> createState() => _MagicPlusButtonState();
}

class _MagicPlusButtonState extends State<MagicPlusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2A6957),
                Color(0xFF1F4F42),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33234B3F),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            borderRadius: BorderRadius.circular(22),
            onPressed: widget.onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.add,
                  color: Color(0xFFF9F2E8),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFFF9F2E8),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
