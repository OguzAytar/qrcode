import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({
    super.key,
    this.cutOutHeight,
    this.cutOutWidth,
  });

  final double? cutOutHeight;
  final double? cutOutWidth;

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? result;
  bool isScanning = true;
  AudioPlayer player = AudioPlayer();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text('QR Kod Tara'),
        actions: [
          FutureBuilder(
            future: controller?.getFlashStatus(),
            builder: (context, snapshot) {
              bool flashStatus = snapshot.data ?? false;
              Icon flashIcon = _getFlashIcon(flashStatus);
              return IconButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {
                    flashStatus = !flashStatus;
                    flashIcon = _getFlashIcon(flashStatus);
                  });
                },
                icon: flashIcon,
              );
            },
          ),
          FutureBuilder(
            future: controller?.getFlashStatus(),
            builder: (context, snapshot) {
              return IconButton(
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.flip_camera_ios_outlined,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: _buildQrView(context),
    );
  }

  Icon _getFlashIcon(bool flashStatus) {
    return flashStatus ? const Icon(Icons.flash_on, color: Colors.white) : const Icon(Icons.flash_off, color: Colors.white);
  }

  Widget _buildQrView(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Yükseklik ve genişlik kontrolü yapıyoruz
    double cutOutHeight = widget.cutOutHeight ??
        (isPortrait
            ? (isTablet ? MediaQuery.sizeOf(context).height * 0.3 : MediaQuery.sizeOf(context).height * 0.17)
            : (isTablet ? MediaQuery.sizeOf(context).height * 0.4 : MediaQuery.sizeOf(context).height * 0.25));

    double cutOutWidth = widget.cutOutWidth ??
        (isPortrait
            ? (isTablet ? MediaQuery.sizeOf(context).width * 0.7 : MediaQuery.sizeOf(context).width * 0.95)
            : (isTablet ? MediaQuery.sizeOf(context).width * 0.6 : MediaQuery.sizeOf(context).width * 0.8));

    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCamera,
      overlay: QrScannerOverlayShape(
        overlayColor: Colors.black87,
        borderColor: Theme.of(context).appBarTheme.backgroundColor!,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutHeight: cutOutHeight,
        cutOutWidth: cutOutWidth,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  void onQRViewCamera(QRViewController controller) async {
    try {
      this.controller = controller;

      controller.scannedDataStream.listen((scandata) async {
        await player.setSource(AssetSource('bip.mp3'));
        await player.resume();
        await controller.pauseCamera();
        if (isScanning) {
          setState(() {
            result = scandata;
            isScanning = false;
          });

          Navigator.of(context).pop(result?.code ?? '');
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    player.dispose();
    super.dispose();
  }
}
