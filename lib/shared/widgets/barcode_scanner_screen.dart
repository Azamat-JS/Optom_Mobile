import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:bsmart/core/l10n/l10n.dart';

/// Full-screen camera barcode scanner. Pops with the first detected code, or
/// `null` if the user cancels. Reused by the product list's "scan to find"
/// action now, and by POS (Milestone 4) later — this is the direct native
/// replacement for the reference web app's ZXing-WASM camera workaround.
///
/// Builds and runs on the iOS Simulator since `mobile_scanner` 7.x (Apple
/// Vision instead of ML Kit), but the simulator has no camera — verify actual
/// scanning on a real device.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, this.title});

  /// Defaults to the localized "Scan a barcode".
  final String? title;

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.code128, BarcodeFormat.ean13, BarcodeFormat.ean8]);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? context.l10n.scannerTitle),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
