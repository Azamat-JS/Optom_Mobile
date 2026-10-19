import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

/// Yellow "slide to order" track (the reference's "Slide to Pay"): drag the
/// round thumb past 85% to confirm; letting go earlier springs it back.
/// Screen readers get a plain button with the same label.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({required this.label, required this.onConfirmed, this.enabled = true, super.key});

  final String label;
  final VoidCallback onConfirmed;
  final bool enabled;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> with SingleTickerProviderStateMixin {
  static const _height = 64.0;
  static const _thumb = 54.0;
  static const _inset = 5.0;
  static const _threshold = 0.85;

  late final _controller = AnimationController(vsync: this, duration: AppMotion.standard);
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    if (_done || !widget.enabled) return;
    _controller.value = (_controller.value + details.delta.dx / travel).clamp(0.0, 1.0);
  }

  Future<void> _onDragEnd() async {
    if (_done || !widget.enabled) return;
    if (_controller.value >= _threshold) {
      _done = true;
      HapticFeedback.mediumImpact();
      await _controller.animateTo(1, curve: AppMotion.emphasized);
      widget.onConfirmed();
      // Back to the start, in case the order fails and the user retries.
      if (mounted) {
        _done = false;
        _controller.value = 0;
      }
    } else {
      await _controller.animateBack(0, curve: AppMotion.emphasized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final fill = widget.enabled ? AppColors.brandYellow : colors.disabledFill;
    final ink = widget.enabled ? AppColors.onBrand : colors.disabledText;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.enabled ? widget.onConfirmed : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxWidth - _thumb - _inset * 2;
          return GestureDetector(
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, travel),
            onHorizontalDragEnd: (_) => _onDragEnd(),
            onHorizontalDragCancel: _onDragEnd,
            child: Container(
              height: _height,
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(_height / 2)),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(left: _thumb + _inset * 2, right: 18),
                        child: Center(
                          child: Opacity(
                            opacity: (1 - _controller.value * 1.6).clamp(0.0, 1.0),
                            // Shrinks a long label (total included) instead of cutting it.
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: BrandTheme.fontFamily,
                                  color: ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _inset + travel * _controller.value,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(
                          color: widget.enabled ? AppColors.ink : colors.disabledText,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _controller.value > 0.95 ? Icons.check_rounded : Icons.keyboard_double_arrow_right_rounded,
                          color: widget.enabled ? AppColors.brandYellow : colors.disabledFill,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
