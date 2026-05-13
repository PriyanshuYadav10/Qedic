import 'package:flutter/material.dart';
import 'package:qedic/utility/HexColor.dart';

class EmployeeGoalFieldCard extends StatelessWidget {
  const EmployeeGoalFieldCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(blurRadius: 1, color: Colors.grey, offset: Offset(0, 0)),
        ],
      ),
      child: child,
    );
  }
}

class EmployeeGoalPrimaryButton extends StatelessWidget {
  const EmployeeGoalPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: HexColor(HexColor.primarycolor),
        foregroundColor: HexColor(HexColor.white),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      onPressed: onPressed,
      child: icon == null
          ? Text(text)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
    );
  }
}

class EmployeeGoalStatusChip extends StatefulWidget {
  const EmployeeGoalStatusChip({
    super.key,
    required this.label,
    this.highlight = false,
  });

  final String label;
  final bool highlight;

  @override
  State<EmployeeGoalStatusChip> createState() => _EmployeeGoalStatusChipState();
}

class _EmployeeGoalStatusChipState extends State<EmployeeGoalStatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _flash = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant EmployeeGoalStatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlight != widget.highlight) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.highlight) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.highlight
        ? HexColor(HexColor.red_color)
        : HexColor(HexColor.primary_s);
    return AnimatedBuilder(
      animation: _flash,
      builder: (context, child) {
        final flashValue = widget.highlight ? _flash.value : 0.0;
        return Transform.scale(
          scale: 1 + (flashValue * 0.035),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: color.withValues(alpha: 0.15 + (flashValue * 0.12)),
              border: widget.highlight
                  ? Border.all(color: color.withValues(alpha: 0.75))
                  : null,
              boxShadow: widget.highlight
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18 + flashValue * 0.3),
                        blurRadius: 5 + flashValue * 10,
                        spreadRadius: flashValue * 2,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 12,
                color: color,
                fontFamily: widget.highlight
                    ? 'montserrat_bold'
                    : 'montserrat_regular',
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmployeeGoalInfoRow extends StatelessWidget {
  const EmployeeGoalInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.iconSize = 20,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? HexColor(HexColor.primary_s),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: HexColor(HexColor.black),
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
