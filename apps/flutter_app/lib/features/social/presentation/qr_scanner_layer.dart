import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerLayer extends StatefulWidget {
  const QrScannerLayer({super.key, required this.onUidScanned});

  final ValueChanged<String> onUidScanned;

  @override
  State<QrScannerLayer> createState() => _QrScannerLayerState();
}

class _QrScannerLayerState extends State<QrScannerLayer> {
  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        _hasScanned = true;
        HapticFeedback.vibrate();
        widget.onUidScanned(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Scan QR Code'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: MobileScanner(
          onDetect: _onDetect,
        ),
      ),
    );
  }
}
