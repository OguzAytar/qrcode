import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerateScreen extends StatefulWidget {
  const QRGenerateScreen({super.key});

  @override
  State<QRGenerateScreen> createState() => _QRGenerateScreenState();
}

class _QRGenerateScreenState extends State<QRGenerateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('QR Kod Oluştur'),
        centerTitle: true,
      ),
      body: const Buildbody(),
    );
  }
}

class Buildbody extends StatefulWidget {
  const Buildbody({super.key});

  @override
  State<Buildbody> createState() => _BuildbodyState();
}

class _BuildbodyState extends State<Buildbody> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(children: [
        SizedBox(
            height: 200,
            child: controller.text.isEmpty
                ? null
                : QrImageView(data: controller.text)),
        TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'QR Kod Verisini Giriniz'),
          controller: controller,
          onChanged: (value) {
            setState(() {});
          },
        )
      ]),
    );
  }
}
