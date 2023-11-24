import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? result;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
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
                  icon: flashIcon);
            },
          ),

          // ElevatedButton(
          //   onPressed: () async {
          //     await controller?.toggleFlash();
          //     setState(() {
          //       flashStatus = !flashStatus;
          //     });
          //   },
          //   child: FutureBuilder(
          //     future: controller?.getFlashStatus(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         // Veri yüklenene kadar gösterilecek widget
          //         return const Icon(
          //             Icons.flash_on); // Veya başka bir yükleme animasyonu
          //       } else if (snapshot.hasError) {
          //         // Hata durumunda gösterilecek widget
          //         return Text('Hata: ${snapshot.error}');
          //       } else {
          //         return Row(
          //       }
          //     },
          //   ),
          // ),

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
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text('QR DATA: ${result!.code}')
                    : const Text('QR Kod Tarayın'),
              ))
        ],
      ),
    );
  }

  Icon _getFlashIcon(bool flashstatusData) {
    return flashstatusData
        ? const Icon(
            Icons.flash_on,
            color: Colors.white,
          )
        : const Icon(
            Icons.flash_off,
            color: Colors.white,
          );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 350.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCamera,
      overlay: QrScannerOverlayShape(
          overlayColor: Colors.black87,
          borderColor: Colors.blueGrey,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void onQRViewCamera(
    QRViewController controller,
  ) {
    this.controller = controller;
    controller.scannedDataStream.listen((scandata) {
      setState(() {
        result = scandata;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
