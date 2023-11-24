import 'package:flutter/material.dart';
import 'package:qrcode/view/qrGenerateScreen/qr_generate_screen.dart';
import 'package:qrcode/view/qrScanScreen/qr_scan_screen.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRScanScreen(),
                            ));
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black87),
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(18))),
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
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black87),
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(18))),
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
          )),
    );
  }
}
