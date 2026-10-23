import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';

/// Full-screen camera barcode scanner. Pops with the first detected code, or
/// `null` if the user cancels. Reused by the product list's "scan to find"
/// action now, and by POS (Milestone 4) later — this is the direct native
/// replacement for the reference web app's ZXing-WASM camera workaround.
///
/// Builds and runs on the iOS Simulator since `mobile_scanner` 7.x (Apple
/// Vision instead of ML Kit), but the simulator has no camera — verify actual
/// scanning on a real device.
///
/// Phase 9: dark camera view with a framed scan window; the frame is only a
/// visual guide, detection still uses the whole picture.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, this.title});

  /// Defaults to the localized "Scan a barcode".
  final String? title;

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  static const _windowSize = Size(290, 180);

  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.code128, BarcodeFormat.ean13, BarcodeFormat.ean8],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _CameraError(message: l10n.scannerCameraError),
            ),
            const IgnorePointer(child: CustomPaint(painter: _ScanWindowPainter(_windowSize))),
            Center(
              child: IgnorePointer(
                child: SizedBox(
                  width: _windowSize.width - 40,
                  height: _windowSize.height - 24,
                  child:
                      Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.brandYellow,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: const [BoxShadow(color: Color(0x99FFC904), blurRadius: 12)],
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          // Offsets are fractions of the box's height: top edge → bottom edge.
                          .slideY(begin: 0, end: 0.98, duration: 1600.ms, curve: Curves.easeInOut),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _GlassButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          widget.title ?? l10n.scannerTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, state, _) {
                          if (state.torchState == TorchState.unavailable) return const SizedBox(width: 48);
                          final on = state.torchState == TorchState.on;
                          return _GlassButton(
                            icon: on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            tooltip: l10n.scannerTorch,
                            highlight: on,
                            onTap: () => _controller.toggleTorch(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: _windowSize.height + 56),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: AppColors.brandYellow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.scannerHint,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round translucent button over the camera picture (yellow when [highlight]).
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.tooltip, required this.onTap, this.highlight = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? AppColors.brandYellow : Colors.black45,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: highlight ? AppColors.onBrand : Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Darkens everything outside a centred rounded window and draws yellow
/// corner brackets around it.
class _ScanWindowPainter extends CustomPainter {
  const _ScanWindowPainter(this.window);

  final Size window;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: window.width, height: window.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rrect)),
      Paint()..color = const Color(0x99000000),
    );

    const arm = 34.0;
    const r = 22.0;
    final paint = Paint()
      ..color = AppColors.brandYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final l = rect.left, t = rect.top, rt = rect.right, b = rect.bottom;
    canvas
      ..drawPath(
        Path()
          ..moveTo(l, t + arm)
          ..lineTo(l, t + r)
          ..arcToPoint(Offset(l + r, t), radius: const Radius.circular(r))
          ..lineTo(l + arm, t),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(rt - arm, t)
          ..lineTo(rt - r, t)
          ..arcToPoint(Offset(rt, t + r), radius: const Radius.circular(r))
          ..lineTo(rt, t + arm),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(rt, b - arm)
          ..lineTo(rt, b - r)
          ..arcToPoint(Offset(rt - r, b), radius: const Radius.circular(r))
          ..lineTo(rt - arm, b),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(l + arm, b)
          ..lineTo(l + r, b)
          ..arcToPoint(Offset(l, b - r), radius: const Radius.circular(r))
          ..lineTo(l, b - arm),
        paint,
      );
  }

  @override
  bool shouldRepaint(_ScanWindowPainter oldDelegate) => oldDelegate.window != window;
}

/// Shown instead of the picture when the camera can't start (no permission,
/// no camera — e.g. the iOS Simulator).
class _CameraError extends StatelessWidget {
  const _CameraError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 0, 40, _BarcodeScannerScreenState._windowSize.height + 160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_rounded, color: Colors.white54, size: 44),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
