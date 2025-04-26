import 'dart:developer';
import 'dart:io';
import 'dart:ui';

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

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? result;
  bool isScanning = true;
  AudioPlayer player = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

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
    // Tema renklerini alıyoruz
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final accentColor = theme.colorScheme.secondary;
    final backgroundColor = theme.colorScheme.surface;
    final scanGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryColor, accentColor],
    );

    return Scaffold(
      body: Stack(
        children: [
          // Kamera görünümü
          _buildQrView(context),

          // Üst bilgi paneli (blur efektli app bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 8,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.appBarTheme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: accentColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Geri butonu
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: theme.appBarTheme.foregroundColor),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Başlık
                      Text(
                        'QR Kod Tarayıcı',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.appBarTheme.foregroundColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Kamera ayarları butonu
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: theme.appBarTheme.foregroundColor),
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                bool flashStatus = snapshot.data ?? false;
                                return ListTile(
                                  leading: Icon(
                                    flashStatus ? Icons.flash_on : Icons.flash_off,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  title: Text(
                                    flashStatus ? 'Flaşı Kapat' : 'Flaşı Aç',
                                    style: TextStyle(color: theme.colorScheme.onPrimary),
                                  ),
                                  onTap: () async {
                                    await controller?.toggleFlash();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.flip_camera_ios, color: theme.colorScheme.onPrimary),
                              title: Text(
                                'Kamerayı Çevir',
                                style: TextStyle(color: theme.colorScheme.onPrimary),
                              ),
                              onTap: () async {
                                await controller?.flipCamera();
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Alt bilgi paneli
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hızlı erişim butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(
                            icon: Icons.flash_on,
                            label: 'Flaş',
                            onTap: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            theme: theme,
                            scanGradient: scanGradient,
                          ),
                          const SizedBox(width: 36),
                          _buildActionButton(
                            icon: Icons.flip_camera_ios,
                            label: 'Çevir',
                            onTap: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            theme: theme,
                            scanGradient: scanGradient,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Bilgi metni
                      Text(
                        'QR kodu tarama çerçevesine yerleştirin',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aksiyon butonu widget'ı
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required LinearGradient scanGradient,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: scanGradient,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.onSecondary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final theme = Theme.of(context);

    // Yükseklik ve genişlik kontrolü yapıyoruz
    double cutOutHeight = widget.cutOutHeight ??
        (isPortrait
            ? (isTablet ? MediaQuery.sizeOf(context).height * 0.3 : MediaQuery.sizeOf(context).height * 0.17)
            : (isTablet ? MediaQuery.sizeOf(context).height * 0.4 : MediaQuery.sizeOf(context).height * 0.25));

    double cutOutWidth = widget.cutOutWidth ??
        (isPortrait
            ? (isTablet ? MediaQuery.sizeOf(context).width * 0.7 : MediaQuery.sizeOf(context).width * 0.95)
            : (isTablet ? MediaQuery.sizeOf(context).width * 0.6 : MediaQuery.sizeOf(context).width * 0.8));

    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: onQRViewCamera,
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),

        // Animasyonlu tarama çizgisi
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(cutOutWidth, cutOutHeight),
                    painter: ScanLinePainter(
                      progress: _animation.value,
                      primaryColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Köşe indikatörleri
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: SizedBox(
                width: cutOutWidth + 16,
                height: cutOutHeight + 16,
                child: CustomPaint(
                  painter: CornerPainter(color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kamera erişim izni gerekli'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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

          // Başarılı tarama animasyonu
          _showSuccessOverlay().then((_) {
            Navigator.of(context).pop(result?.code ?? '');
          });
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  // Başarılı tarama animasyonu
  Future<void> _showSuccessOverlay() async {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: theme.colorScheme.onPrimary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'QR Kod Başarıyla Tarandı',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sonuç İşleniyor...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).timeout(
      const Duration(milliseconds: 800),
      onTimeout: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    player.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Tarama çizgisi çizim sınıfı
class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  ScanLinePainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.0),
          primaryColor,
          primaryColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 3));

    final y = size.height * progress;

    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) => true;
}

// Köşe indikatörü çizim sınıfı
class CornerPainter extends CustomPainter {
  final Color color;
  final double cornerSize = 20;
  final double lineWidth = 4;

  CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // Sol üst köşe
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerSize, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerSize),
      paint,
    );

    // Sağ üst köşe
    canvas.drawLine(
      Offset(width, 0),
      Offset(width - cornerSize, 0),
      paint,
    );
    canvas.drawLine(
      Offset(width, 0),
      Offset(width, cornerSize),
      paint,
    );

    // Sol alt köşe
    canvas.drawLine(
      Offset(0, height),
      Offset(cornerSize, height),
      paint,
    );
    canvas.drawLine(
      Offset(0, height),
      Offset(0, height - cornerSize),
      paint,
    );

    // Sağ alt köşe
    canvas.drawLine(
      Offset(width, height),
      Offset(width - cornerSize, height),
      paint,
    );
    canvas.drawLine(
      Offset(width, height),
      Offset(width, height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(CornerPainter oldDelegate) => false;
}
