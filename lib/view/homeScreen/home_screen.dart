import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcode/view/qrGenerateScreen/qr_generate_screen.dart';
import 'package:qrcode/view/qrScanScreen/qr_scan_screen.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();

    super.dispose();
  }

  String? result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     await player.setSource(AssetSource('bip.mp3'));
      //     await player.resume();
      //   },
      // ),
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 12,
        shadowColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                Text(result ?? 'Barkod Okutulmadı'),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  ElevatedButton(
                      onPressed: () async {
                        final backResult = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRScanScreen(),
                            ));
                        setState(() {
                          result = backResult;
                        });
                      },
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black87),
                          padding: WidgetStatePropertyAll(EdgeInsets.all(18))),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'QR Kod Tara',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRGenerateScreen(),
                            ));
                      },
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black87),
                          padding: WidgetStatePropertyAll(EdgeInsets.all(18))),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_2_sharp,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'QR Kod Oluştur',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ))
                ]),
                const Spacer(),
              ],
            ),
          )),
    );
  }
}
